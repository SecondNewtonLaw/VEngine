local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))

local engineRemoteEvent = moduleBaseConstructor.new()

local IsInitialized = false

local function InitializeIfUninitialized()
	if not IsInitialized then
		engineRemoteEvent:Initialize(
			require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineEnvironment"))
		)
	end
end

engineRemoteEvent.ModuleName = "Engine/Networking/EngineRemoteEventFactory"

function engineRemoteEvent:CreateEvent<T...>(eventName: string | SharedEventOptions)
	InitializeIfUninitialized()

	if self.EventMap[eventName] then
		return self.EventMap[eventName]
	end

	local backingEvent = self.EngineEnvironment.RedNetworking.SharedSignalEvent(eventName, function(...)
		return ...
	end)
	local event = {
		RedEvent = backingEvent,
	}

	local function ThrowIfClient()
		if RunService:IsClient() then
			(critical or error)("You may not invoke this function from the Client! This function is Server only!")
		end
	end

	local function ThrowIfServer()
		if RunService:IsServer() then
			(critical or error)("You may not invoke this function from the Server! This function is Client only!")
		end
	end

	function event:FireServer(...: T...)
		ThrowIfServer()
		self.RedEvent:FireServer(...)
	end

	function event:FireClient(player: Player, ...: T...)
		ThrowIfClient()

		self.RedEvent:FireClient(player, ...)
	end

	function event:FireAllClients(...: T...)
		ThrowIfClient()

		self.RedEvent:FireAllClients(...)
	end

	function event:FireForClients(players: { Player }, ...: T...)
		ThrowIfClient()

		self.RedEvent:FireClients(players, ...)
	end

	--- Connects a callback for when the event is invoked. Can be used by both Client and Server, and will connect respectively to the correct signals.
	--- @param callback function TypeSig: ((Player, T...) -> ()) | ((T...) -> ()) | Callback that will execute when the event is invoked.
	--- @return EngineEventConnection disconnectHandler An RBXScriptConnection equivalent.
	function event:OnFire(
		callback: (Player, T...) -> () | (T...) -> ()
	): EngineEventConnection -- Engine "Clone" of RBXScriptConnection.
		--- @class EngineEventConnection
		local connection = {
			Connected = true,
		}

		local disconnectClosure = function() end
		if RunService:IsClient() then
			connection.Disconnect = function(_self)
				if not _self.Connected then
					return
				end
				_self.Connected = false
				disconnectClosure()
			end
			disconnectClosure = self.RedEvent:OnClient(callback)
		else
			connection.Disconnect = function(_self)
				if not _self.Connected then
					return
				end
				_self.Connected = false
				disconnectClosure()
			end
			disconnectClosure = self.RedEvent:OnServer(callback)
		end

		return connection
	end

	--- Connects a callback for when the event is invoked, but only once. Can be used by both Client and Server, and will connect respectively to the correct signals.
	--- @param callback function TypeSig: ((Player, T...) -> ()) | ((T...) -> ()) | Callback that will execute when the event is invoked.
	--- @return EngineEventConnection disconnectHandler An RBXScriptConnection equivalent.
	function event:OnceOnFire(
		callback: (Player, T...) -> () | (T...) -> ()
	): EngineEventConnection -- Engine "Clone" of RBXScriptConnection.
		--- @class EngineEventConnection
		local connection = {
			Connected = true,
		}

		local disconnectClosure = function() end
		if RunService:IsClient() then
			connection.Disconnect = function(_self)
				if not _self.Connected then
					return
				end
				_self.Connected = false
				disconnectClosure()
			end
			disconnectClosure = self.RedEvent:OnClient(function(...)
				callback(...)
				disconnectClosure()
			end)
		else
			connection.Disconnect = function(_self)
				if not _self.Connected then
					return
				end
				_self.Connected = false
				disconnectClosure()
			end
			disconnectClosure = self.RedEvent:OnServer(function(...)
				callback(...)
				disconnectClosure()
			end)
		end

		return connection
	end

	self.EventMap[eventName] = event

	return self.EventMap[eventName]
end

function engineRemoteEvent:Initialize(envManager: EngineEnvironmentManager)
	engineRemoteEvent.EngineEnvironment = envManager:GetEngineGlobals()
	engineRemoteEvent.EventMap = {}
end

return engineRemoteEvent
