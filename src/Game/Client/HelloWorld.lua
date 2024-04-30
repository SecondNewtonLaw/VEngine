local module =
	require(game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineModule")).new()

module.ModuleName = "Hello, World!"

function module:Initialize(environmentManager: EngineEnvironmentManager)
	print("Hello from the initialization routine!")
	warn("Hello, this is a warning from inside a polluted environment!")
	error("This is an error from inside a polluted environment!")
	task.delay(5, function()
		require(game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineAntiTamper")):Initialize(
			environmentManager
		)
	end)
	critical("This is a critical error from the inside of a polluted environment!")

end

return module
