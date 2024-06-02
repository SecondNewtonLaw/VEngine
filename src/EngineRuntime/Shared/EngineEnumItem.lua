local b
b = {
	[""] = {
		Value = 0,
		Name = "",
		EnumType = b,
	},
}

--- @cdass EngineEnumItem
local _ = {
	--- @type number
	Value = 0,
	--- @type string
	Name = "",
	EnumType = b,
}

local enumBase = {}

function enumBase:CreateEnumItem(name: string, value: number, enumType: EngineEnum)
	return table.freeze({
		Name = name,
		Value = value,
		EnumType = enumType,
	})
end

return enumBase
