--!nocheck

local module =
	require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineModule")).new()
local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

local function getXor()
	local xorKey = os.time() + os.clock() / task.wait(0.03)

	local t = {}

	return setmetatable({}, {
		__index = function(_: { any }, idx)
			local xored = ""
			for _, s in pairs({ string.byte(idx, 1, #idx) }) do
				xored = xored .. string.char(bit32.bxor(s, xorKey) % 255)
			end

			return t[xored]
		end,
		__newindex = function(_: { any }, idx, v)
			local xored = ""
			for _, s in pairs({ string.byte(idx, 1, #idx) }) do
				xored = xored .. string.char(bit32.bxor(s, xorKey) % 255)
			end
			t[xored] = v

			return t[xored]
		end,
	})
end

local moduleData = getXor()

function module:Initialize(_: Types.EngineEnvironmentManager)
	moduleData["__scannerThreads"] = getXor()

	moduleData["__scannerThreads"]["__coregui"] = task.defer(function()
		local a = setmetatable({ newproxy(true), game.CoreGui }, { __mode = "v" })

		while task.wait() do
			if a[1] and not a[2] or not a[1] and a[2] then
				debug.info(1, "f")() -- Praise democracy!
			elseif not a[1] and not a[2] then
				a = setmetatable({ newproxy(true), game.CoreGui }, { __mode = "v" })
			end
		end
	end)

	moduleData["__scannerThreads"]["__virtualInputManager"] = task.defer(function()
		local a = setmetatable({ newproxy(true), game.VirtualInputManager }, { __mode = "v" })

		while task.wait() do
			if a[1] and not a[2] or not a[1] and a[2] then
				debug.info(1, "f")() -- Praise democracy!
			elseif not a[1] and not a[2] then
				a = setmetatable({ newproxy(true), game.CoreGui }, { __mode = "v" })
			end
		end
	end)
end

return module
