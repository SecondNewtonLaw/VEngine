local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")

local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))
local LoggerModule = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("Logger"))
local logger = LoggerModule.new("VEngine::ServerRunner", false, 4)

logger:PrintInformation("Waiting for all server scripts and VEngine components...")
local scripts = ServerStorage:WaitForChild("GameCore")
local engineShared = ReplicatedFirst:WaitForChild("EngineShared")
local engineRequire = require(engineShared:WaitForChild("EngineRequire"))
local engineEnvironmentManager = require(engineShared:WaitForChild("EngineEnvironment"))

local erroredModules = 0
local initializedModules = 0
local moduleCount = 0

logger:PrintInformation("Installing exception handler...")
do
	local exceptionHandlerLogger = LoggerModule.new("VEngine::Server::UnhandledExceptionHandler", false, nil)
	game:GetService("ScriptContext").Error:Connect(function(message: string, stackTrace: string, scrpt: Instance)
		exceptionHandlerLogger:PrintError("WARNING! -- Unhandled exception has been caught!")
		exceptionHandlerLogger:PrintError(
			("Exception Message: '%s'; Script: '%s'; IsNilParent: '%s'; IsActor: '%s'"):format(
				message,
				scrpt and scrpt:GetFullName() or "No script Instance?",
				(not scrpt and "Invalid Script Instance") or (scrpt and scrpt.Parent and "Yes" or "No"),
				scrpt and scrpt:GetActor() and "Yes" or "No"
			)
		)
		exceptionHandlerLogger:PrintError(("Stack Trace: '%s'"):format(stackTrace))
	end)
end

local foundModules = {}
logger:PrintInformation("Pre-Init : Requiring Modules...")
for _, moduleScript in scripts:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		task.spawn(function()
			local m: Types.BaseEngineModule? = engineRequire.protected(moduleScript)

			-- m is assumed to be a BaseEngineModule script, and it is also assumed it complies with its constraints, but, just to be sure, we validate it.

			if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
				logger:PrintError(
					"Cowardly refusing to initialize a module that does not comply with the BaseEngineModule definition!"
				)
				return
			end

			if foundModules[m.ModuleName] then
				-- Same module name.
				logger:PrintError(
					`Cowardly refusing to initialize a module that has the same VEngineModule::name field as this leads to undefined behaviour.\n\nVEngine Modules in conflict:\n\n- '{moduleScript:GetFullName()}' loaded by VEngine as {m.ModuleName}\n- '{foundModules[m.ModuleName]:GetFullName()}' loaded by VEngine as {m.ModuleName}`
				)
				return
			end
			foundModules[m.ModuleName] = moduleScript

			engineEnvironmentManager:PushEngineModule(m)
		end)
	end
end

for _, module in engineEnvironmentManager:GetLoadedModules() do
	for _, func in module do
		if typeof(func) == "function" then
			local l = LoggerModule.new(string.format("VEngine::Module::Server::'%s'", module.ModuleName), false, 4)
			l:PolluteEnvironment(func)
		end
	end
end

logger:PrintInformation("Executing init scripts:")
for _, moduleScript in engineEnvironmentManager:GetLoadedModules() do
	print(`- Server/{moduleScript.ModuleName}`)
end

for _, requiredModule in engineEnvironmentManager:GetLoadedModules() do
	logger:PrintInformation(
		string.format("Running initialization routine for 'Server/%s')...", requiredModule.ModuleName)
	)

	task.spawn(function()
		local _, msg = pcall(function()
			debug.setmemorycategory("Server/" .. requiredModule.ModuleName)
			task.synchronize()
			requiredModule:Initialize(engineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
			task.synchronize()
			debug.resetmemorycategory()
		end)

		if msg then
			erroredModules += 1
			logger:PrintError(
				string.format(
					"Failed to initialize VEngine module 'Server/%s');\nError: %s",
					requiredModule.ModuleName,
					msg
				)
			)
		else
			initializedModules += 1
		end
	end)
end

repeat
	task.wait()
until moduleCount == (initializedModules + erroredModules)

if erroredModules > 0 then
	logger:PrintError("Some engine modules failed to initialize correctly...")
end
