local keybindMap

keybindMap = {
	Running = {
		Value = 1,
		Name = "Running",
		EnumType = keybindMap,
	},
	TiltRight = {
		Value = 2,
		Name = "TiltRight",
		EnumType = keybindMap,
	},
	TiltLeft = {
		Value = 3,
		Name = "TiltLeft",
		EnumType = keybindMap,
	},
}
function keybindMap.GetDefaultKeybinds()
	return {
		Running = Enum.KeyCode.LeftShift,
		TiltLeft = Enum.KeyCode.Q,
		TiltRight = Enum.KeyCode.E,
	}
end

return table.freeze(keybindMap)
