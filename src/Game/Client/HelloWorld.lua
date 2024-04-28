local module = require(game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineModule"))

module.ModuleName = "Hello, World!"

function module:Initialize(environmentManager: EngineEnvironmentManager)
	local env = environmentManager.GetEngineGlobals()
end

return module
