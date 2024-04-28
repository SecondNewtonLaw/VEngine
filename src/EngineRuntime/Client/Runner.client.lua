local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoggerModule = require(ReplicatedStorage:WaitForChild("EngineShared"):WaitForChild("Logger"))
local logger = LoggerModule.new("VEngine::ClientRunner", true, 2)

logger:PrintInformation("Waiting for all client scripts and VEngine components...")
local scripts = ReplicatedStorage:WaitForChild("ClientCore")
local engineShared = ReplicatedStorage:WaitForChild("EngineShared")
local engineRequire = require(engineShared:WaitForChild("EngineRequire"))
local engineEnvironmentManager = require(engineShared:WaitForChild("EngineEnvironment"))

logger:PrintInformation("Executing init scripts:")
for _, moduleScript in scripts:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		print(`- Client/{moduleScript.Name}`)
	end
end

local initializedModules = 0
local moduleCount = #scripts:GetChildren()
for _, moduleScript in scripts:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		local m: BaseEngineModule = engineRequire.protected(moduleScript)

		-- m is assumed to be a BaseEngineModule script, and it is also assumed it complies with its constraints, but, just to be sure, we validate it.

		if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
			logger:PrintError(
				"Cowardly refusing to initialize a module that does not comply with the BaseEngineModule definition!"
			)
			continue
		end

		logger:PrintInformation(
			string.format(
				"Running initialization routine for %s (Module: Client/%s)...",
				m.ModuleName,
				moduleScript.Name
			)
		)

		local _, msg = pcall(function()
			local l = LoggerModule.new(string.format("VEngine::Implementation::'%s'", m.ModuleName), true, 4)
			l:PolluteEnvironment(m.Initialize)
			m:Initialize(engineEnvironmentManager) -- Env table cannot be modified either way; it is frozen.
			l:RestoreEnvironment(m.Initialize)
		end)

		if msg then
			logger:PrintError(
				string.format(
					"Failed to initialize VEngine module '%s' (Module: Client/%s);\nError: %s",
					m.ModuleName,
					moduleScript.Name,
					msg
				)
			)
		else
			initializedModules += 1
		end
	end
end

if moduleCount ~= initializedModules then
	logger:PrintError("Some engine modules failed to initialize correctly...")
end
