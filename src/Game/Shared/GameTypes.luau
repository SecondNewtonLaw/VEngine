--[[
    This is where your game's types live.
]]
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)

export type ExampleManager = {} & EngineTypes.BaseEngineModule

export type ExampleStructureFactory = {
	new: (ferris: string, foo: number) -> ExampleStructure,
}

export type ExampleStructure = {
	Ferris: string,
	Foo: number,
}

return {}
