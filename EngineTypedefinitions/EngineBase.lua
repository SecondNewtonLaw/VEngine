--[[
	Note: None of the Luau written here will run. Roblox LSP will evaluate it for type information, static type notations are not recommended, you should be using
	typeof(require(...)) to avoid having to come here EVERY time to update the types when you write them, unless something makes you make them static, you are advised to avoid doing so.
]]

export type BaseEngineModule = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineModule")
).new())

export type EngineUtilities = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineUtilities")
))

export type EngineEnvironmentManager = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineEnvironment")
))

export type EngineEnvironment = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineEnvironment")
).GetEngineGlobals())

local loggerModule = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("Logger"))

export type LoggerConstructor = typeof(loggerModule)
export type Logger = typeof(loggerModule.new(nil, nil, nil))

export type EngineEnum = { [string]: EngineEnumItem }

export type EngineEnumItem = {
	Value: number,
	Name: string,
	EnumType: EngineEnum,
}

export type ValidationFailureReason = {
	--- The length of the given data is too long.
	TooLong: string,
	--- The given type is an unexpected type.
	UnexpectedType: string,
	--- The given type may not be serialised into a Datastore object.
	CannotBeSerialised: string,
	--- Input that is invalid, and unexpected, such as \255 and so.
	InvalidInput: string,
}

export type State = {
	--- The name of the state.
	Name: string,
	--- Executes a step in this state.
	--- @param LoggerInstance Logger The logger instance associated with this State's currently executing state machine.
	--- @param stateMachineMemory table A snapshot of the memory of the State Machine executing this state.
	--- @return State nextState The next state; If nil the state machine should stop.
	ExecuteState: (LoggerInstance: Logger, stateMachineMemory: table) -> State?,
}

export type StateMachine = typeof(require(
	game:GetService("ReplicatedFirst")
		:WaitForChild("EngineShared")
		:WaitForChild("StateMachine")
		:WaitForChild("EngineStateMachine")
).CreateStateMachine("", {}))

export type EngineTimeSpan = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTimeSpan")
).new(0))

export type EngineRemoteEventFactory = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineRemoteEvent")
))

export type EngineRemoteEvent = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineRemoteEvent")
).CreateEvent("Hello, World!"))

export type EngineEventConnection = typeof(require(
	game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineRemoteEvent")
).CreateEvent("Hello, World!"):OnFire())
