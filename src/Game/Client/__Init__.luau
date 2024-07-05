local ReplicatedFirst = game:GetService("ReplicatedFirst")

local engineKeybinds

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))

local module = moduleBaseConstructor.new()

module.ModuleName = "ClientInitialization"

function module:Initialize(_: EngineTypes.EngineEnvironmentManager)
	print("Resolving requires...")
	engineKeybinds =
		require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineKeybinds")) :: EngineTypes.EngineKeybinds
	print("Requires resolved!")

	print("Engine Keybinds: Initializing...")
	engineKeybinds:Initialize()
end

return module
