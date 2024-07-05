--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local GameTypes = require(ReplicatedFirst.Shared.GameTypes)

local struct = {} :: GameTypes.ExampleStructureFactory

function struct.new(ferris: string, foo: number): GameTypes.ExampleStructure
	return table.freeze({
		Ferris = ferris,
		Foo = foo,
	})
end

return table.freeze(struct)
