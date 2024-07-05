local ReplicatedFirst = game:GetService("ReplicatedFirst")

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local EngineKeybinds =
	require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineKeybinds")) :: EngineTypes.EngineKeybinds

local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))

local module = moduleBaseConstructor.new()

module.ModuleName = "ServerInitialization"

function module:Initialize(_: EngineTypes.EngineEnvironmentManager)
	print("Engine Keybinds: Initializing...")
	EngineKeybinds:Initialize()
end

return module
