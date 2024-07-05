--[[
    LoggerModule - Copyright (c) 2023 Dottik
]]

local RunService = game:GetService("RunService")
local engineEnvironmentManager =
	require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineEnvironment"))
local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

local logger = {}

--- Construct a Logger.
--- @param loggerName string The name of the logger. Used when printing to trace logs.
--- @param studioOnly boolean If true, the logs will only show up on Roblox Studio.
--- @param stackTraceDepth number When printing a critical error, this will be the amount of stack trace printed. Optional, if nil, the entire stack trace will be emitted..
--- @return Logger logger An instance of af a logger, ready to be used.
function logger.new(loggerName: string, studioOnly: boolean, stackTraceDepth: number?): Types.Logger
	if stackTraceDepth == nil then
		stackTraceDepth = 999
	end

	if typeof(loggerName) ~= "string" then
		error("[CRITICAL/VEngine::Logger::new] Cannot initialize. Logger name is not a string!")
	end

	--- @class Logger
	local _self = {
		--- The name of the logger, used when building it.
		LoggerName = loggerName,
		--- Whether or not the logger should only print when it is on studio
		StudioOnly = studioOnly,
		--- The depth of the stack trace on errors when printing Critical error messages.
		StackTraceDepth = stackTraceDepth,
	}

	--- Will modify the environment of the caller, replacing the standard print, warn and error functions with the ones belonging to the logger.
	--- || Note: This is not ideal, and other scripts intending to, for example, error, will not end execution. Please consider not doing this when using foreign code not aware of this convention.
	--- If you wish to restore the polluted environment, use Logger:RestoreEnvironment, which will restore the environment to the one you had the last time you called Logger:RestoreEnvironment.
	--- @param self Logger
	function _self:PolluteEnvironment(f: number | () -> ())
		local rEnv = engineEnvironmentManager:GetStandardEnvironment(script)

		rEnv["print"] = function(...)
			self:PrintInformation(...)
		end

		rEnv["warn"] = function(...)
			self:PrintWarning(...)
		end

		rEnv["lighterror"] = function(...)
			self:PrintError(...)
		end

		rEnv["error"] = function(...)
			self:PrintCritical(...)
		end

		setfenv(typeof(f) == "number" and f ~= 0 and f + 1 or f, rEnv)
	end

	--- Restores a polluted environment.
	--- @param self Logger
	function _self:RestoreEnvironment(f: number | () -> ())
		if typeof(f) == "number" and f ~= 0 then
			f += 1
		end
		local x = getfenv(f)
		local nEnv = x
		for i, v in pairs(engineEnvironmentManager:GetStandardEnvironment(script)) do
			nEnv[i] = v -- Rewrite globals to be back to env if rewritten.
		end
		setfenv(f, nEnv)
	end

	--- Emits a print into the console. Labeled as an Information level print.
	--- @param message string The message to be printed.
	function _self:PrintInformation(message: string, ...)
		if self.StudioOnly and not RunService:IsStudio() then
			return
		end
		print(("[INFO/%s] %s "):format(self.LoggerName, tostring(message)), ...)
	end

	--- Emits a print into the console. Labeled as an Warning level print.
	--- @param self Logger
	--- @param message string The message to be printed.
	function _self:PrintWarning(message: string, ...)
		if self.StudioOnly and not RunService:IsStudio() then
			return
		end
		warn(("[WARN/%s] %s"):format(self.LoggerName, tostring(message)), ...)
	end

	--- Emits a warning into the console. Labeled as an Error level print.
	--- @param self Logger
	--- @param message string The message to be warned.
	function _self:PrintError(message: string, ...)
		if self.StudioOnly and not RunService:IsStudio() then
			return
		end
		warn(("[ERROR/%s] %s"):format(self.LoggerName, tostring(message)), ...)
	end

	--- Emits an error into the console. Labeled as an Critical level print.
	--- Remarks: This will stop the caller thread.
	--- @param self Logger
	--- @param message string The message to be errored with.
	function _self:PrintCritical(message: string)
		if self.StudioOnly and not RunService:IsStudio() then
			return
		end
		error(("[CRITICAL/%s] %s"):format(self.LoggerName, tostring(message)), self.StackTraceDepth)
	end

	return table.freeze(_self) -- Freeze.
end

return logger
