export type BaseEngineModule = {
	ModuleName: string,

	Initialize: (self: BaseEngineModule) -> (),
}

export type EngineUtilities = {
	---	Deep clones a table and returns it.
	DeepClone: (t: table) -> table,
}

export type EngineEnvironmentManager = {
	--- Manipulate the environment of the given closure to get all V8Engine globals.
	ModifyEnvironment: (f: () -> ()) -> (),
}

export type EngineEnvironment = {
	--[[
		Red Networking related goodies.
	]]
	RedNetworking: { -- Note: Why? If we add : Red into this, we will not get any type completion, as Roblox LSP will choke.
		Event: (Config: string | EventOptions, Validate: (...any) -> T...) -> Event<T...>,
		Function: (
			Name: string,
			ValidateArg: (...any) -> A...,
			ValidateRet: (...any) -> R...
		) -> Function<A..., R...>,
		SharedEvent: (
			Options: string | SharedEventOptions,
			Validate: ValidateFunction<T...>
		) -> SharedCallEvent<T...>,
		SharedSignalEvent: (
			Options: string | SharedEventOptions,
			Validate: ValidateFunction<T...>
		) -> SharedSignalEvent<T...>,
	},
	EventOptions: { -- Red networking extension.
		new: (eventName: string, unreliable: boolean?) -> EventOptions,
	},
	SharedEventOptions: {
		new: (eventName: string, unreliable: boolean?) -> SharedEventOptions,
	},
}

export type Logger = {
	LoggerName: string,
	StudioOnly: boolean,
	StackTraceDepth: number,

	PrintInformation: (self: Logger, message: string) -> (),
	PrintWarning: (self: Logger, message: string) -> (),
	PrintError: (self: Logger, message: string) -> (),
	PrintCritical: (self: Logger, message: string) -> (),
	PolluteEnvironment: (self: Logger) -> (),
	RestoreEnvironment: (self: Logger) -> (),
}
