--[[
	Type definitions for VEngine.

	Load Using:
		local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

]]

export type BaseEngineModule = {
	--- Runs the initialization routine for an EngineModule.
	--- @param envManager The environment manager for VEngine.
	Initialize: (self: BaseEngineModule, envManager: EngineEnvironmentManager) -> (),
	--- The load order of the module.
	--- The higher, the earlier it will load.
	LoadOrder: number,
	--- The name of the engine module.
	ModuleName: string,
}

export type EngineUtilities = {
	DeepClone: (t: { any }) -> { any },
}

export type EngineEnvironmentManager = {
	GetRealDataModel: () -> DataModel,
	GetEngineGlobals: () -> VEngineEnv,
	GetEngineModule: (self: EngineEnvironmentManager, moduleName: string) -> BaseEngineModule?,
	GetLoadedModules: (self: EngineEnvironmentManager) -> { [string]: BaseEngineModule },
	GetStandardEnvironment: (self: EngineEnvironmentManager, runningOn: LuaSourceContainer) -> RBXEnvBase,
	PushEngineModule: (self: EngineEnvironmentManager, module: BaseEngineModule) -> (),
	ModifyEnvironment: (f: () -> () | number) -> (),
}

export type LoggerConstructor = {
	new: (loggerName: string, studioOnly: boolean, stackTraceDepth: number?) -> Logger,
}

export type Logger = {
	PrintInformation: (self: Logger, message: string, ...any) -> (),
	PrintWarning: (self: Logger, message: string, ...any) -> (),
	PrintError: (self: Logger, message: string, ...any) -> (),
	PrintCritical: (self: Logger, message: string) -> (),
	RestoreEnvironment: (self: Logger, f: () -> () | number) -> (),
	PolluteEnvironment: (self: Logger, f: () -> () | number) -> (),
}

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
	ExecuteState: (LoggerInstance: Logger, stateMachineMemory: { any }) -> State?,
}

export type StateMachine = {
	Dispose: (self: StateMachine) -> (),
	GetState: (self: StateMachine) -> any,
	IsStateMachineRunning: (self: StateMachine) -> boolean,
	ModifyMemory: (self: StateMachine, newState: { any }) -> { any },
	OnExit: BindableEvent,
	OnStateChanged: BindableEvent,
	Ready: BindableEvent,
	StartMachine: (self: StateMachine) -> nil,
	StateMachineStates: { State },
	StopMachine: (self: StateMachine) -> boolean,
}

export type EngineTimeSpan = {
	Ticks: number,

	ToTicks: (self: EngineTimeSpan) -> number,
	ToMilliseconds: (self: EngineTimeSpan) -> number,
	ToSeconds: (self: EngineTimeSpan) -> number,
	ToMinutes: (self: EngineTimeSpan) -> number,
	ToHours: (self: EngineTimeSpan) -> number,
	ToDays: (self: EngineTimeSpan) -> number,

	ToTotalMilliseconds: (self: EngineTimeSpan) -> number,
	ToTotalSeconds: (self: EngineTimeSpan) -> number,
	ToTotalMinutes: (self: EngineTimeSpan) -> number,
	ToTotalHours: (self: EngineTimeSpan) -> number,
	ToTotalDays: (self: EngineTimeSpan) -> number,
}

export type EngineRemoteEventFactory = {
	EventMap: { [string]: EngineSharedReplicatedEvent },
	EngineEnvironment: VEngineEnv,
}

export type EngineSharedReplicatedEvent = {
	FireAllClients: <T>(self: EngineSharedReplicatedEvent, ...T) -> (),
	FireClient: <T>(self: EngineSharedReplicatedEvent, fireForPlayer: Player, ...T) -> (),
	FireForClients: <T>(self: EngineSharedReplicatedEvent, players: { Player }, ...T) -> (),
	FireServer: <T>(self: EngineSharedReplicatedEvent, ...T) -> (),
	OnFire: <T>(
		self: EngineSharedReplicatedEvent,
		callback: (Player, ...T) -> () | (...T) -> (),
		once: boolean,
		localEvent: boolean
	) -> EngineEventConnection?,
	WaitRemote: <T>(self: EngineSharedReplicatedEvent) -> ...T,
	WaitLocal: <T>(self: EngineSharedReplicatedEvent) -> ...T,
}

export type EngineEventConnection = {
	Connected: boolean,
	Disconnect: (self: EngineEventConnection) -> (),
}

export type SharedEventOptions = {
	Name: string,
	Unreliable: boolean?,
}

export type EventOptions = {
	Name: string,
	Unreliable: boolean?,
}

export type RBXEnvBase = {
	-- Roblox Globals -> https://create.roblox.com/docs/reference/engine/globals/RobloxGlobals
	Enum: Enum,
	game: DataModel,
	workspace: Workspace,
	script: LuaSourceContainer,

	require: typeof(require),
	tick: typeof(tick),
	time: typeof(time),
	typeof: typeof(typeof),
	warn: typeof(warn),
	UserSettings: typeof(UserSettings),
	elapsedTime: typeof(elapsedTime),
	gcinfo: typeof(gcinfo),
	OverlapParams: typeof(OverlapParams),

	bit32: typeof(bit32),
	debug: typeof(debug),
	math: typeof(math),
	SharedTable: typeof(SharedTable),
	task: {
		cancel: typeof(task.cancel),
		spawn: typeof(task.spawn),
		defer: typeof(task.defer),
		wait: typeof(task.wait),
		delay: typeof(task.delay),
		desynchronize: typeof(task.desynchronize),
		synchronize: typeof(task.synchronize),
	},
	table: typeof(table),
	os: typeof(os),
	string: typeof(string),
	utf8: typeof(utf8),
	coroutine: typeof(coroutine),
	Instance: typeof(Instance),

	-- Lua 5.1.4 Globals -> https://create.roblox.com/docs/reference/engine/globals/LuaGlobals

	getfenv: typeof(getfenv),
	setfenv: typeof(setfenv),

	xpcall: typeof(xpcall),
	pcall: typeof(pcall),

	ipairs: typeof(ipairs),
	pairs: typeof(pairs),
	next: typeof(next),

	newproxy: typeof(newproxy),
	loadstring: typeof(loadstring), -- This shouldn't really work. But its a roblox global.

	print: typeof(print),
	error: typeof(error),

	collectgarbage: typeof(collectgarbage), -- This is not really going to invoke the GC.
	select: typeof(select),

	getmetatable: typeof(getmetatable),
	setmetatable: typeof(setmetatable),
	rawget: typeof(rawget),
	rawset: typeof(rawset),
	rawlen: typeof(rawlen),

	tonumber: typeof(tonumber),
	tostring: typeof(tostring),

	type: typeof(type),

	assert: typeof(assert),

	unpack: typeof(unpack),
	_G: typeof(_G),
	_VERSION: typeof(_VERSION),

	-- Additional API tables.
	TweenInfo: typeof(TweenInfo),

	Ray: typeof(Ray),
	RaycastParams: typeof(RaycastParams),

	RotationCurveKey: typeof(RotationCurveKey),

	CFrame: typeof(CFrame),

	Vector3: typeof(Vector3),
	Vector3int16: typeof(Vector3int16),

	Vector2: typeof(Vector2),
	Vector2int16: typeof(Vector2int16),

	UDim: typeof(UDim),
	UDim2: typeof(UDim2),

	Color3: typeof(Color3),
	ColorSequence: typeof(ColorSequence),
	ColorSequenceKeypoint: typeof(ColorSequenceKeypoint),
	BrickColor: typeof(BrickColor),

	Font: typeof(Font),
	Random: typeof(Random),
}

export type VEngineEnv = {
	-- TODO: Complete
	RedSignal: () -> (),
} & RBXEnvBase

export type EngineKeybinds = {
	Initialize: () -> (),
	SetKeybind: (self: EngineKeybinds, keybindEnum: EngineEnumItem, keycode: Enum.KeyCode) -> (),
	GetKeybind: (self: EngineKeybinds, keybindEnum: EngineEnumItem) -> Enum.KeyCode?,
}

export type EngineAudioManager = {
	SoundCache: { [string]: Sound },

	--- Creates a sound in the EngineAudioManager. Synchronizes thread.
	--- @param soundName The name of the sound.
	--- @param soundId The ID of the sound.
	--- @return The now loaded sound.
	CreateSound: (self: EngineAudioManager, soundName: string, soundId: string) -> Sound,

	--- Obtain a sound from the EngineAudioManager cache.
	--- @param soundName The name of the sound.
	--- @return The sound that was cached. May be nil if it is not loaded.
	GetSound: (self: EngineAudioManager, soundName: string) -> Sound?,

	--- Obtains the container used in the game to Parent the sounds to. Synchronizes thread.
	GetSoundContainer: () -> Folder,

	StopAllSounds: (self: EngineAudioManager, exclusionList: { string }) -> (),
	FadeOutAllSounds: (self: EngineAudioManager, exclusionList: { string }) -> (),

	--- Fades in a sound loaded by the EngineAudioManager.
	--- @param soundName The name of the sound
	--- @param targetVolume The target volume, between 0 and 1.
	--- @param fadeInTime The time that the fade will take to complete
	--- @param fadeEasing The easing style for the fade.
	--- @return The signal that will be fired when the Fade ends.
	FadeIn: (
		self: EngineAudioManager,
		soundName: string,
		targetVolume: number,
		fadeInTime: number,
		fadeEasing: Enum.EasingStyle
	) -> RBXScriptSignal?,
	--- Fades out a sound loaded by the EngineAudioManager.
	--- @param soundName The name of the sound
	--- @param fadeOutTime The time that the fade will take to complete
	--- @param fadeEasing The easing style for the fade.
	--- @return The signal that will be fired when the Fade ends.
	FadeOut: (
		self: EngineAudioManager,
		soundName: string,
		fadeOutTime: number,
		fadeEasing: Enum.EasingStyle
	) -> RBXScriptSignal?,
} & BaseEngineModule

return {}
