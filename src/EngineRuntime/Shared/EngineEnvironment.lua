local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--- @class EngineEnvironmentManager
local envManager = {}
local loadedModules = {}

print("[VEngine::EngineEnvironmentManager] Initializing Environment Manager...")

local EngineUtilities = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

function envManager:PushEngineModule(engineModule: BaseEngineModule)
	loadedModules[engineModule.ModuleName] = engineModule
end

function envManager:GetEngineModule(moduleName: string)
	return loadedModules[moduleName]
end

function envManager:GetLoadedModules()
	-- Sort by load priority
	table.sort(loadedModules, function(s: BaseEngineModule, o: BaseEngineModule)
		return s.LoadOrder < o.LoadOrder
	end)

	return loadedModules
end
--
function envManager:GetStandardEnvironment(runningOn: LuaSourceContainer)
	return {
		-- Deprecated globals are not included, you may choose to add them at your own volition.
		-- Roblox Globals -> https://create.roblox.com/docs/reference/engine/globals/RobloxGlobals
		Enum = Enum,
		game = game,
		workspace = workspace,
		script = runningOn,

		require = function(...)
			print(
				string.format(
					"[VEngine::Hooks::require] Requiring Instance -> '%s' | Issuer: '%s'",
					typeof(select(1, ...)) == "Instance" and select(1, ...):GetFullName(),
					RunService:IsClient() and "Roblox Client" or "Roblox Server"
				)
			)
			return require(...)
		end,
		tick = tick,
		time = time,
		typeof = typeof,
		warn = warn,
		UserSettings = UserSettings,
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

		-- Additional API tables.
		TweenInfo = TweenInfo,

		Ray = Ray,
		RaycastParams = RaycastParams,

		RotationCurveKey = RotationCurveKey,

		CFrame = CFrame,

		Vector3 = Vector3,
		Vector3int16 = Vector3int16,

		Vector2 = Vector2,
		Vector2int16 = Vector2int16,

		UDim = UDim,
		UDim2 = UDim2,

		Color3 = Color3,
		ColorSequence = ColorSequence,
		ColorSequenceKeypoint = ColorSequenceKeypoint,
		BrickColor = BrickColor,

		Font = Font,
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

	--- RedSharedEvents, abstracted into an Engine construct.
	nEnv["EngineRemoteEvent"] = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineRemoteEvent"))

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
