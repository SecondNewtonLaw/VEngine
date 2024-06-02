local module =
	require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineModule")).new()

local xorKey = os.time() + os.clock() / task.wait(0.03)

local __moduleData = {}

local moduleData = setmetatable({}, {
	__index = function(self, idx)
		local xored = ""
		for _, s in pairs({ string.byte(idx, 1, #idx) }) do
			xored = xored .. string.char(bit32.bxor(s, xorKey) % 255)
		end

		return __moduleData[xored]
	end,
	__newindex = function(self, idx, v)
		local xored = ""
		for _, s in pairs({ string.byte(idx, 1, #idx) }) do
			xored = xored .. string.char(bit32.bxor(s, xorKey) % 255)
		end
		__moduleData[xored] = v

		return __moduleData[xored]
	end,
})

function module:Initialize(engineEnvironmentManager: EngineEnvironmentManager)
	local LoggerModule = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("Logger"))

	moduleData["Time"] = os.time()
	print(__moduleData)
	print(moduleData)
	moduleData["Time"] = os.time()
	print(__moduleData)
	print(moduleData)
	print(moduleData["Time"]) -- Xorstring test.

	moduleData["__scannerThreads"] = {} -- TODO: Implement helper function to emit Xorstring metatables, improve detections other than weaktables (Our beloved!)

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
				a = setmetatable({ newproxy(true), game.VirtualInputManager }, { __mode = "v" })
			end
		end
	end)
end

return module
