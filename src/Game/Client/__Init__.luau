--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local engineKeybinds

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))

local module = moduleBaseConstructor.new()

module.ModuleName = "ClientInitialization"

function module:PreInitialize(_: EngineTypes.EngineEnvironmentManager)
	print("Pre-Initiaialization step...")
	engineKeybinds =
		require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineKeybinds")) :: EngineTypes.EngineKeybinds
	engineKeybinds:Initialize()
end

function module:Initialize(_: EngineTypes.EngineEnvironmentManager) end

return module
