--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local ModuleBaseConstructor = require(ReplicatedFirst.EngineShared.EngineModule)

local module = ModuleBaseConstructor.new()

module.ModuleName = "Shared/Managers/ExampleManager"

function module:PreInitialize(_: EngineTypes.EngineEnvironmentManager)
	print("Hello, from preinit!")
end

function module:Initialize(_: EngineTypes.EngineEnvironmentManager)
	print("Hello, from init!")
end

return module