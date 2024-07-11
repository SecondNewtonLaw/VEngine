--!native
--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))
local LoggerModule = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("Logger"))
local RunnerLogger = LoggerModule.new("VEngine::ClientRunner", false, 4)

local EngineRequire = require(ReplicatedFirst.EngineShared.EngineRequire)
local EngineEnvironmentManager = require(ReplicatedFirst.EngineShared.EngineEnvironment)

RunnerLogger:PrintInformation("Installing exception handler...")
do
	local exceptionHandlerLogger = LoggerModule.new("VEngine::Client::UnhandledExceptionHandler", false, nil)
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

--[[
	ReplicatedFirst scripts must run before us. Wait until we are signaled.
]]
RunnerLogger:PrintInformation("Waiting for the preload phase to complete...")
while not ReplicatedFirst:GetAttribute("Loaded__Preload") do
	task.wait()
end
RunnerLogger:PrintInformation("Preload phase completed! Beginning VEngine::Client")

RunnerLogger:PrintInformation("Phase 1/2: Building Shared...")
do
	local totalModuleCount = 0
	local erroredModules = 0
	local initializedModules = 0
	local loadedModules = {}
	local compatibleSharedModules = {}

	RunnerLogger:PrintInformation("Composing modules compatible with the BaseEngineModule signature...")
	for _, moduleScript in ReplicatedFirst.Shared:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			task.spawn(function()
				local m: Types.BaseEngineModule? = EngineRequire.protected(moduleScript)

				-- m is assumed to be a BaseEngineModule script, and it is also assumed it complies with its constraints, but, just to be sure, we validate it.

				if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
					return -- Not a BaseEngineModule compatible module.
				end

				if compatibleSharedModules[m.ModuleName] then
					-- Same module name.
					RunnerLogger:PrintError(
						`Cowardly refusing to initialize a module that has the same VEngineModule::name field as this leads to undefined behaviour.\n\nVEngine Modules in conflict:\n\n- '{moduleScript:GetFullName()}' loaded by VEngine as {m.ModuleName}\n- '{compatibleSharedModules[m.ModuleName]:GetFullName()}' loaded by VEngine as {m.ModuleName}`
					)
					return
				end
				compatibleSharedModules[m.ModuleName] = moduleScript

				table.insert(loadedModules, m)

				EngineEnvironmentManager:PushEngineModule(m)
				totalModuleCount += 1
			end)
		end
	end

	RunnerLogger:PrintInformation("Modules composed. Executing Pre-Initialization routine...")

	for _, moduleScript in loadedModules do
		print(`- Shared/{moduleScript.ModuleName}`)
	end

	-- Pollute their environment with the Hooked functions and a custom VEngine logger.
	for _, module in loadedModules do
		for _, func in module do
			if typeof(func) == "function" then
				local l =
					LoggerModule.new(string.format("VEngine::SharedModule::Client::'%s'", module.ModuleName), false, 4)
				l:PolluteEnvironment(func :: () -> ())
			end
		end
	end

	for _, requiredModule in loadedModules do
		RunnerLogger:PrintInformation(
			string.format("Running preinitialization routine for 'Shared/%s')...", requiredModule.ModuleName)
		)

		task.spawn(function()
			local _, msg = pcall(function()
				debug.setmemorycategory("Shared/" .. requiredModule.ModuleName)
				task.synchronize()
				requiredModule:PreInitialize(EngineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
				task.synchronize()
				debug.resetmemorycategory()
			end)

			if msg then
				erroredModules += 1
				RunnerLogger:PrintError(
					string.format(
						"Failed to preinitialize VEngine module 'Shared/%s');\nError: %s",
						requiredModule.ModuleName,
						msg
					)
				)
			else
				initializedModules += 1
			end
		end)
	end

	RunnerLogger:PrintInformation("Waiting for all Pre-Initialization scripts to complete...")

	repeat
		task.wait()
	until initializedModules == totalModuleCount
	initializedModules = 0

	RunnerLogger:PrintInformation("Modules Pre-Initialized. Executing Initialization routine...")

	for _, requiredModule in loadedModules do
		RunnerLogger:PrintInformation(
			string.format("Running initialization routine for 'Shared/%s')...", requiredModule.ModuleName)
		)

		task.spawn(function()
			local _, msg = pcall(function()
				debug.setmemorycategory("Shared/" .. requiredModule.ModuleName)
				task.synchronize()
				requiredModule:Initialize(EngineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
				task.synchronize()
				debug.resetmemorycategory()
			end)

			if msg then
				erroredModules += 1
				RunnerLogger:PrintError(
					string.format(
						"Failed to initialize VEngine module 'Shared/%s');\nError: %s",
						requiredModule.ModuleName,
						msg
					)
				)
			else
				initializedModules += 1
			end
		end)
	end

	RunnerLogger:PrintInformation("Shared modules initialization completed!")
end

RunnerLogger:PrintInformation("Phase 2/2: Building Client-Exclusive...")
do
	local clientScripts = ReplicatedFirst:WaitForChild("ClientCore")

	local erroredModules = 0
	local initializedModules = 0
	local totalModuleCount = 0
	local loadedModules = {}
	local foundModules = {}

	RunnerLogger:PrintInformation("Requiring Client-Exclusive Modules...")
	for _, moduleScript in clientScripts:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			task.spawn(function()
				local m: Types.BaseEngineModule? = EngineRequire.protected(moduleScript)

				-- m is assumed to be a BaseEngineModule script, and it is also assumed it complies with its constraints, but, just to be sure, we validate it.

				if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
					RunnerLogger:PrintError(
						"Cowardly refusing to initialize a module that does not comply with the BaseEngineModule definition!"
					)
					return
				end

				if foundModules[m.ModuleName] then
					-- Same module name.
					RunnerLogger:PrintError(
						`Cowardly refusing to initialize a module that has the same VEngineModule::name field as this leads to undefined behaviour.\n\nVEngine Modules in conflict:\n\n- '{moduleScript:GetFullName()}' loaded by VEngine as {m.ModuleName}\n- '{foundModules[m.ModuleName]:GetFullName()}' loaded by VEngine as {m.ModuleName}`
					)
					return
				end
				foundModules[m.ModuleName] = moduleScript
				table.insert(loadedModules, m)

				EngineEnvironmentManager:PushEngineModule(m)
				totalModuleCount += 1
			end)
		end
	end

	for _, module in EngineEnvironmentManager:GetLoadedModules() do
		for _, func in module do
			if typeof(func) == "function" then
				local l = LoggerModule.new(string.format("VEngine::Module::Client::'%s'", module.ModuleName), false, 4)
				l:PolluteEnvironment(func :: () -> ())
			end
		end
	end

	RunnerLogger:PrintInformation("Executing Client Exclusive preinitialization scripts:")
	for _, moduleScript in loadedModules do
		print(`- Client/{moduleScript.ModuleName}`)
	end

	for _, requiredModule in loadedModules do
		RunnerLogger:PrintInformation(
			string.format("Running preinitialization routine for 'Client/%s')...", requiredModule.ModuleName)
		)

		task.spawn(function()
			local _, msg = pcall(function()
				debug.setmemorycategory("Client/" .. requiredModule.ModuleName)
				task.synchronize()
				requiredModule:PreInitialize(EngineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
				task.synchronize()
				debug.resetmemorycategory()
			end)

			if msg then
				erroredModules += 1
				RunnerLogger:PrintError(
					string.format(
						"Failed to preinitialize VEngine module 'Client/%s');\nError: %s",
						requiredModule.ModuleName,
						msg
					)
				)
			else
				initializedModules += 1
			end
		end)
	end

	RunnerLogger:PrintInformation("Waiting for all Pre-Initialization scripts to complete...")

	repeat
		task.wait()
	until initializedModules == totalModuleCount
	initializedModules = 0

	for _, requiredModule in loadedModules do
		RunnerLogger:PrintInformation(
			string.format("Running initialization routine for 'Client/%s')...", requiredModule.ModuleName)
		)

		task.spawn(function()
			local _, msg = pcall(function()
				debug.setmemorycategory("Client/" .. requiredModule.ModuleName)
				task.synchronize()
				requiredModule:Initialize(EngineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
				task.synchronize()
				debug.resetmemorycategory()
			end)

			if msg then
				erroredModules += 1
				RunnerLogger:PrintError(
					string.format(
						"Failed to initialize VEngine module 'Client/%s');\nError: %s",
						requiredModule.ModuleName,
						msg
					)
				)
			else
				initializedModules += 1
			end
		end)
	end
end