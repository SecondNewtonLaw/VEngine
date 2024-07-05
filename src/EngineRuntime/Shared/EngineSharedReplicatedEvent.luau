--!strict

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))
local Types = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

local engineEvent: Types.EngineSharedReplicatedEventFactory =
	moduleBaseConstructor.new() :: Types.EngineSharedReplicatedEventFactory

local IsInitialized = false

local function InitializeIfUninitialized()
	if not IsInitialized then
		engineEvent:Initialize(
			require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineEnvironment")) :: any -- Break cyclic dependency.
		)
	end
end

engineEvent.ModuleName = "Engine/Networking/EngineSharedReplicatedEventFactory"

engineEvent.Validators = {
	NoArgumentsValidator = function(...)
		if typeof(select(1, ...)) ~= "nil" then
			error(
				"[VEngine::EngineSharedReplicatedEvent::Validators::NoArgumentsValidator/CRITICAL]: EngineSharedReplicatedEvent has been invoked with arguments, whilist not requiring them."
			)
			return ...
		end

		return ...
	end,
} :: { [string]: <T>(...T) -> ...T }

function engineEvent.CreateEvent<T...>(
	_self: Types.EngineSharedReplicatedEventFactory,
	eventName: string | Types.SharedEventOptions,
	validate: (T...) -> T...
): Types.EngineSharedReplicatedEvent
	InitializeIfUninitialized()

	if typeof(eventName) == "string" and _self.EventMap[eventName] then
		return _self.EventMap[eventName]
	end

	local function ThrowIfClient()
		if RunService:IsClient() then
			error("You may not invoke this function from the Client! This function is Server only!")
		end
	end

	local function ThrowIfServer()
		if RunService:IsServer() then
			error("You may not invoke this function from the Server! This function is Client only!")
		end
	end
	local backingRemoteEvent = (_self.EngineEnvironment :: any).RedNetworking.SharedSignalEvent(eventName, validate)
	local localSignal = _self.EngineEnvironment.RedSignal()
	local remoteEvent = (
		{
			RedRemoteEvent = backingRemoteEvent,
			LocalEvent = localSignal,
		} :: any
	) :: EngineTypes.EngineSharedReplicatedEvent

	do
		function remoteEvent:FireServer<T>(...)
			ThrowIfServer()
			validate(...)
			self.LocalEvent:Fire(nil, ...)
			self.RedRemoteEvent:FireServer(...)
		end

		function remoteEvent:FireClient<T>(player: Player, ...)
			ThrowIfClient()
			validate(...)
			self.LocalEvent:Fire(player, ...)
			self.RedRemoteEvent:FireClient(player, ...)
		end

		function remoteEvent:FireAllClients<T>(...)
			ThrowIfClient()
			validate(...)
			self.LocalEvent:Fire(game:GetService("Players"):GetPlayers(), ...)
			self.RedRemoteEvent:FireAllClients(...)
		end

		function remoteEvent:FireForClients<T>(players: { Player }, ...)
			ThrowIfClient()
			validate(...)
			self.LocalEvent:Fire(players, ...)
			self.RedRemoteEvent:FireClients(players, ...)
		end

		function remoteEvent:WaitRemote<T>()
			local nRet, invoked
			remoteEvent:OnFire(function(...)
				nRet = { ... }
				invoked = true
			end, true, false)

			while not invoked do
				task.wait()
			end

			return table.unpack(nRet)
		end

		function remoteEvent:WaitLocal<T>()
			local nRet, invoked
			remoteEvent:OnFire(function(...)
				nRet = { ... }
				invoked = true
			end, true, true)

			while not invoked do
				task.wait()
			end

			return table.unpack(nRet)
		end

		--- Connects a callback for when the event is invoked. Can be used by both Client and Server, and will connect respectively to the correct signals.
		--- @param callback Will execute when the event is invoked.
		--- @return An abstraction for a connection.
		function remoteEvent:OnFire<T>(
			callback: (Player, ...T) -> () | (...T) -> (),
			once: boolean,
			localEvent: boolean
		): Types.EngineEventConnection? -- Engine "Clone" of RBXScriptConnection.
			if typeof(once) ~= "boolean" or typeof(localEvent) ~= "boolean" then
				error(
					"Cannot set event fire condition: Once and LocalEvent is not set. This is not allowed, and causes issues when handling events."
				)
				return nil -- Should crash.
			end
			--- @class EngineEventConnection
			local connection = {
				Connected = true,
				Disconnect = function(_: Types.EngineEventConnection) end,
			}
			local localDisconnect = function() end
			local remoteDisconnect = function() end
			local disconnectClosure = function()
				localDisconnect()
				remoteDisconnect()
			end
			local oCallback = function(...)
				-- Wrapper.
				if not connection then
					return -- Signal disconnected.
				end
				(callback :: (typeof(...)) -> ())(...)

				if once and connection then
					connection:Disconnect() -- Signal connected and Once is toggled.
				end
			end

			if not localEvent then
				if RunService:IsClient() then
					connection.Disconnect = function(_self)
						if not _self.Connected then
							return
						end
						_self.Connected = false
						disconnectClosure()
					end
					remoteDisconnect = self.RedRemoteEvent:OnClient(oCallback)
				else
					connection.Disconnect = function(_self)
						if not _self.Connected then
							return
						end
						_self.Connected = false
						disconnectClosure()
					end
					remoteDisconnect = self.RedRemoteEvent:OnServer(oCallback)
				end
			end

			if localEvent then
				if once then
					localDisconnect = self.LocalEvent:Once(callback)
				else
					localDisconnect = self.LocalEvent:Connect(oCallback)
				end
			end

			return connection
		end
	end

	if typeof(eventName) == "table" then
		eventName = eventName.Name
	end

	_self.EventMap[eventName :: string] = remoteEvent
	return _self.EventMap[eventName :: string] :: Types.EngineSharedReplicatedEvent
end

function engineEvent:Initialize(envManager: Types.EngineEnvironmentManager)
	engineEvent.EngineEnvironment = envManager.GetEngineGlobals()
	engineEvent.EventMap = {}
end

return engineEvent
