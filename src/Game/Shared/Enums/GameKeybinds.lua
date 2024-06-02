--[[
	Here you may define keybinds to use with the EngineKeybinds module.
]]

local keybindMap

keybindMap = {
	Running = {
		Value = 1,
		Name = "Running",
		EnumType = keybindMap,
	},
}
function keybindMap.GetDefaultKeybinds()
	return {
		Running = Enum.KeyCode.LeftShift,
	}
end

return keybindMap
