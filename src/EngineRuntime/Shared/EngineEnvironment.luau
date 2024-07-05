local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--- @class EngineEnvironmentManager
local envManager = {}
local loadedModules = {}

print("[VEngine::EngineEnvironmentManager] Initializing Environment Manager...")

local Types = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineTypes"))
local EngineUtilities = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

function envManager:PushEngineModule(engineModule: Types.BaseEngineModule)
	loadedModules[engineModule.ModuleName] = engineModule
end

function envManager:GetEngineModule(moduleName: string)
	return loadedModules[moduleName]
end

function envManager:GetLoadedModules()
	-- Sort by load priority
	table.sort(loadedModules, function(s: Types.BaseEngineModule, o: Types.BaseEngineModule)
		return s.LoadOrder < o.LoadOrder
	end)

	return loadedModules
end
--
function envManager:GetStandardEnvironment(runningOn: LuaSourceContainer)
	local isStudio = RunService:IsStudio()
	local env
	env = {
		-- Roblox Globals -> https://create.roblox.com/docs/reference/engine/globals/RobloxGlobals
		Enum = Enum,
		game = game
		-- Incredibly experimental. Works, but breaks some things, like when using game directly, it will give the table instead of the DataModel, breaking anything expecting DataModel on the C side of Roblox.
		--[[= setmetatable({}, {
			__index = function(_, idx)
				if typeof(game[idx]) == "function" then
					print(
						string.format(
							"[VEngine::Hooks::DataModel] __namecall -> %s; Emitting thunk for handling __namecall operations!",
							tostring(idx)
						)
					)
					return function(...)
						local nArgs = {}
						for i, v in { ... } do
							if i == 1 then
								continue
							end
							table.insert(nArgs, v)
						end
						return (game[idx] :: any)(game, unpack(nArgs))
					end
				end

				return game[idx]
			end,
			__newindex = game,
			__tostring = game,

			__metatable = getmetatable(game :: any),
		})]],
		workspace = workspace,
		script = runningOn,

		require = function(...)
			env.task.synchronize() -- Use hooked task.synchronize
			if isStudio then
				print(
					string.format(
						"[VEngine::Hooks::require] Requiring Instance -> '%s' | Issuer: '%s'",
						typeof(select(1, ...)) == "Instance" and select(1, ...):GetFullName(),
						RunService:IsClient() and "Roblox Client" or "Roblox Server"
					)
				)
			end
			local m = require(...)

			if typeof(m) == "table" and typeof(m.ModuleName) == "string" then
				error(
					"WARNING! You are requiring a module whilist it being a VEngine module. This is not intended behaviour. You should use the EngineEnvironmentManager to get the module instead!"
				)
				return nil
			end
			return m
		end,
		tick = tick,
		time = time,
		typeof = typeof,
		warn = warn,
		UserSettings = UserSettings,
		elapsedTime = elapsedTime,
		gcinfo = gcinfo,

		bit32 = bit32,
		debug = debug,
		math = math,
		SharedTable = SharedTable,
		OverlapParams = OverlapParams,
		task = {
			cancel = task.cancel,
			spawn = function(f: thread | () -> (), ...)
				local t = task.spawn(f, ...)
				if isStudio then
					print(
						string.format(
							"[VEngine::Hook::task_spawn] Initializing new thread from '%s'. Running @ '%s' ",
							tostring(f),
							tostring(t)
						)
					)
				end
				return t
			end,
			defer = task.defer,
			wait = task.wait,
			delay = task.delay,
			desynchronize = function()
				if isStudio then
					print(
						string.format(
							"[VEngine::Hooks::task_desynchronize] Desynchronizing '%s' into the next parallel cycle.",
							tostring(coroutine.running())
						)
					)
				end
				task.desynchronize()
			end,
			synchronize = function()
				if isStudio then
					print(
						string.format(
							"[VEngine::Hooks::task_synchronize] Synchronizing '%s' into the next serial cycle.",
							tostring(coroutine.running())
						)
					)
				end
				task.synchronize()
			end,
		},
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
		-- Deprecated, do not use, this is a sin.
		-- _G = _G,
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
		Random = Random,
	}

	return env
end

local function ConstructEngineEnvironment(baseEnvironment: {}): Types.VEngineEnv
	--- Table containing all the environment of VEngine.
	local nEnv = EngineUtilities.DeepClone(baseEnvironment) :: Types.RBXEnvBase

	-- Copy the globals of the Standard environment into nEnv, they aren't pushed by default.
	for i, v in pairs(envManager:GetStandardEnvironment(script)) do
		nEnv[i] = v
	end

	--- The Red networking library.
	nEnv["RedNetworking"] = require(ReplicatedStorage:WaitForChild("ThirdPartyShared"):WaitForChild("Red"))

	nEnv["RedSignal"] = require(ReplicatedStorage:WaitForChild("ThirdPartyShared"):WaitForChild("signal"))

	--- Factory for EventOptions (Part of Red Networking)
	nEnv["EventOptions"] = {
		---	Construct a EventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table eventOptions Instance of EventOptions
		new = function(eventName: string, unreliable: boolean?): Types.EventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	--- Factory for SharedEventOptions (Part of Red Networking)
	nEnv["SharedEventOptions"] = {
		---	Construct a SharedEventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table sharedEventOptions Instance of SharedEventOptions
		new = function(eventName: string, unreliable: boolean?): Types.SharedEventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	--- RedSharedEvents, abstracted into an Engine construct.
	nEnv["EngineSharedReplicatedEvent"] =
		require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineSharedReplicatedEvent"))

	return nEnv
end

function envManager.GetEngineGlobals(): Types.VEngineEnv
	return (table.freeze(ConstructEngineEnvironment({})) :: any) :: Types.VEngineEnv
end

function envManager.ModifyEnvironment(func: () -> ())
	if typeof(func) == "number" and func ~= 0 then
		func += 1 -- Assume the given number was the level of the caller. Increase by one to access the callers' instead of ours.
	end
	setfenv(func, ConstructEngineEnvironment(getfenv(func)))
end

return (table.freeze(envManager) :: any) :: Types.EngineEnvironmentManager
