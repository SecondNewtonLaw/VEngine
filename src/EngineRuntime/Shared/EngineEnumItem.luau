local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

local b
b = {
	[""] = {
		Value = 0,
		Name = "",
		EnumType = b,
	},
} :: Types.EngineEnum

local enumBase = {}

function enumBase:CreateEnumItem(name: string, value: number, enumType: Types.EngineEnum): Types.EngineEnumItem
	return table.freeze({
		Name = name,
		Value = value,
		EnumType = enumType,
	}) :: Types.EngineEnumItem
end

return enumBase
