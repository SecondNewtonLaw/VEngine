local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")

local LoggerModule = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("Logger"))
local logger = LoggerModule.new("VEngine::ServerRunner", true, 2)

logger:PrintInformation("Waiting for all server scripts and VEngine components...")
local scripts = ServerStorage:WaitForChild("GameCore")
local engineShared = ReplicatedFirst:WaitForChild("EngineShared")
local engineRequire = require(engineShared:WaitForChild("EngineRequire"))
local engineEnvironmentManager = require(engineShared:WaitForChild("EngineEnvironment"))

local erroredModules = 0
local initializedModules = 0
local moduleCount = 0
logger:PrintInformation("Executing init scripts:")
for _, moduleScript in scripts:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		print(`- Server/{moduleScript.Name}`)
		moduleCount += 1
	end
end

logger:PrintInformation("Pre-Init : Requiring Modules...")
for _, moduleScript in scripts:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		task.spawn(function()
			local m: BaseEngineModule = engineRequire.protected(moduleScript)

			-- m is assumed to be a BaseEngineModule script, and it is also assumed it complies with its constraints, but, just to be sure, we validate it.

			if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
				logger:PrintError(
					"Cowardly refusing to initialize a module that does not comply with the BaseEngineModule definition!"
				)
			end

			engineEnvironmentManager:PushEngineModule(m)
		end)
	end
end

for _, requiredModule in engineEnvironmentManager:GetLoadedModules() do
	logger:PrintInformation(
		string.format("Running initialization routine for 'Server/%s')...", requiredModule.ModuleName)
	)

	task.spawn(function()
		local _, msg = pcall(function()
			debug.setmemorycategory("Server/" .. requiredModule.ModuleName)
			local l = LoggerModule.new(
				string.format("VEngine::Implementation::Server::'%s'", requiredModule.ModuleName),
				true,
				4
			)
			l:PolluteEnvironment(requiredModule.Initialize)
			requiredModule:Initialize(engineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
			l:RestoreEnvironment(requiredModule.Initialize)
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
