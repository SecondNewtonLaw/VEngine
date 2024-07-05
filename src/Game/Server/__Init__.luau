--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local EngineKeybinds = require(ReplicatedFirst.EngineShared.EngineKeybinds) :: any
local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)

local moduleBaseConstructor = require(ReplicatedFirst.EngineShared.EngineModule)

local module = moduleBaseConstructor.new()

module.ModuleName = "ServerInitialization"

function module:PreInitialize(_: EngineTypes.EngineEnvironmentManager)
	print("Pre-init server")
end

function module:Initialize(_: EngineTypes.EngineEnvironmentManager)
	print("Engine Keybinds: Initializing...")
	EngineKeybinds:Initialize()
end

return module
