local module =
	require(game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineModule")).new()

module.ModuleName = "Hello, World!"

function module:Initialize(_)
	-- On ReplicatedFirst. the EngineEnvironmentManager is NOT available!
	print("HELLO")
end

return module
