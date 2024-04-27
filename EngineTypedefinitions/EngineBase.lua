export type BaseEngineModule = {
	ModuleName: string,

	Initialize: (self: BaseEngineModule) -> (),
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
