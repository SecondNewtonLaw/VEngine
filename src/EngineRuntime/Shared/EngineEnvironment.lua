local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- @class EngineEnvironmentManager
local envManager = {}

print("[VEngine::EngineEnvironmentManager] Initializing Environment Manager...")

local EngineUtilities = require(ReplicatedStorage:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

--
function envManager:GetStandardEnvironment(runningOn: LuaSourceContainer)
	return {
		-- Roblox Globals -> https://create.roblox.com/docs/reference/engine/globals/RobloxGlobals
		Enum = Enum,
		game = game,
		workspace = workspace,
		script = runningOn,

		require = require,
		time = time,
		typeof = typeof,
		warn = warn,
		UserSettings = UserSettings,
		elapsedTime = elapsedTime,
		gcinfo = gcinfo,

		bit32 = bit32,
		debug = debug,
		math = math,
		task = task,
		table = table,
		os = os,
		string = string,
		utf8 = utf8,
		coroutine = coroutine,
		Instance = Instance,

		-- Lua 5.1.4 Globals -> https://create.roblox.com/docs/reference/engine/globals/LuaGlobals

		getfenv = getfenv,
		setfenv = setfenv,

		xpcall = xpcall,
		pcall = pcall,

		ipairs = ipairs,
		pairs = pairs,
		next = next,

		newproxy = newproxy,
		loadstring = loadstring, -- This shouldn't really work. But its a roblox global.

		print = print,
		error = error,

		collectgarbage = collectgarbage, -- This is not really going to invoke the GC.
		select = select,

		getmetatable = getmetatable,
		setmetatable = setmetatable,
		rawget = rawget,
		rawset = rawset,
		rawlen = rawlen,

		tonumber = tonumber,
		tostring = tostring,

		type = type,

		assert = assert,

		unpack = unpack,
		_G = _G,
		_VERSION = _VERSION,
	}
end

local function ConstructEngineEnvironment(baseEnvironment: table)
	--- Table containing all the environment of VEngine.
	local nEnv = EngineUtilities.DeepClone(baseEnvironment)

	-- Copy the globals of the Standard environment into nEnv, they aren't pushed by default.
	for i, v in pairs(envManager:GetStandardEnvironment(script)) do
		nEnv[i] = v
	end

	--- The Red networking library.
	nEnv["RedNetworking"] = require(ReplicatedStorage:WaitForChild("ThirdPartyShared"):WaitForChild("Red"))

	--- Factory for EventOptions (Part of Red Networking)
	nEnv["EventOptions"] = {
		---	Construct a EventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table eventOptions Instance of EventOptions
		new = function(eventName: string, unreliable: boolean?): EventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	--- Factory for SharedEventOptions (Part of Red Networking)
	nEnv["SharedEventOptions"] = {
		---	Construct a SharedEventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table sharedEventOptions Instance of SharedEventOptions
		new = function(eventName: string, unreliable: boolean?): SharedEventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	return nEnv
end

function envManager.GetEngineGlobals()
	return table.freeze(ConstructEngineEnvironment({}))
end

function envManager.ModifyEnvironment(func: () -> ())
	if typeof(func) == "number" then
		func += 1 -- Assume the given number was the level of the caller. Increase by one to access the callers' instead of ours.
	end
	setfenv(func, ConstructEngineEnvironment(getfenv(func)))
end

return table.freeze(envManager)
