--[[
	Type definitions for VEngine.
	
	Load Using:
	local EngineTypes = require(game:GetService("ReplicatedFirst").EngineShared.EngineTypes)
	
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type BaseEngineModule = {
	--- Runs before Initialize. This is where you should create instances, and initialize your Manager.
	--- @param envManager The environment manager for VEngine.
	PreInitialize: (self: BaseEngineModule, envManager: EngineEnvironmentManager) -> (),
	--- Runs the initialization routine for an EngineModule.
	--- Runs after all the Pre-Initialization is completed. This should connect game events and can require other modules
	--- @param envManager The environment manager for VEngine.
	Initialize: (self: BaseEngineModule, envManager: EngineEnvironmentManager) -> (),
	--- The load order of the module.
	--- The higher, the earlier it will load.
	LoadOrder: number,
	--- The name of the engine module.
	ModuleName: string,
}

export type EngineDatastoreValidation = {
	--- Validate if an item is valid for saving inside a DataStore.
	--- @param item The item to validate
	--- @param expectedType The type the item should be.
	--- @param expectedLength Optional. The expected length of the value, only applies of item and expectedType are of type string. Defaults to 255.
	--- @return An enum that represents the reason the validation failed.
	IsValidForDatastore: <T>(item: T, expectedType: string, expectedLength: number?) -> ValidationFailureReason,

	ValidationFailureReason: {
		--- The length of the given data is too long.
		TooLong: "TooLong",
		--- The given type is an unexpected type.
		UnexpectedType: "UnexpectedType",
		--- The given type may not be serialised into a Datastore object.
		CannotBeSerialised: "CannotBeSerialised",
		--- Input that is invalid, and unexpected, such as \255 and so.
		InvalidInput: "InvalidInput",
		--- The validation process has failed due to a timeout or an unexpected compliction.
		ValidationTimeout: "ValidationTimeout",
		--- The input is valid, and it may be given into the datastore
		Success: "Success",
	},
}

export type EngineSharedReplicatedEventFactory = {
	--- A map of the events already created
	EventMap: { [string]: EngineSharedReplicatedEvent },

	--- Creates an event using Red networking internally.
	--- @param eventName The name of the event, optionally, you can use a SharedEventOptions structure.
	--- @param validate A validation callback that is run before all events are fired
	--- @return An EngineSharedReplicatedEvent representing the event.
	CreateEvent: <T...>(
		self: EngineSharedReplicatedEventFactory,
		eventName: string | SharedEventOptions,
		validate: (T...) -> T...
	) -> EngineSharedReplicatedEvent,

	--- A list of pre-made validators
	Validators: {
		NoArgumentsValidator: <T>(...T) -> ...T,
	},
	--- A copy of the VEngine environment.
	EngineEnvironment: VEngineEnv,
} & BaseEngineModule

export type EngineUtilities = {
	--- Clones a given table, including nested tables.
	--- @param t The table to copy
	--- @return The deeply-copied table.
	DeepClone: (t: { any }) -> { any },
}

export type EngineEnvironmentManager = {
	---	Obtain the VEngine exclusive globals, such as "RedNetworking"
	--- This environment is extended from what GetStandardEnvironment gives.
	--- @return The VEngine environment
	GetEngineGlobals: () -> VEngineEnv,
	--- Gets a loaded engine module on demand
	--- Will error if there is no module with the given name.
	--- @paran moduleName The name of the module to look for
	--- @return The loaded base engine module with the given name
	GetEngineModule: (self: EngineEnvironmentManager, moduleName: string) -> BaseEngineModule,
	--- Gets all loaded engine module.
	--- @return All loaded BaseEngineModule s mapped by their name.
	GetLoadedModules: (self: EngineEnvironmentManager) -> { [string]: BaseEngineModule },
	--- Obtain the RBXBaseEnv.
	--- @param runningOn The script that the environment is running on.
	--- @return A copy of the standard roblox environment. Contains hooks.
	GetStandardEnvironment: (self: EngineEnvironmentManager, runningOn: LuaSourceContainer) -> RBXEnvBase,
	--- Pushes an engine module into the list of loaded modules
	--- @param module The module to push into the loaded modules.
	PushEngineModule: (self: EngineEnvironmentManager, module: BaseEngineModule) -> (),
	--- Modify the environment of a given closure with the VEngineEnv.
	--- @param f The closure (or index) to modify.
	ModifyEnvironment: (f: () -> () | number) -> (),
}

export type LoggerConstructor = {
	--- Construct a Logger
	--- @param loggerName The name of the logger. Used when printing to trace logs.
	--- @param studioOnly If true, the logs will only show up on Roblox Studio.
	--- @param stackTraceDepth When printing a critical error, this will be the amount of stack trace printed. Optional, if nil, the entire stack trace will be emitted.
	--- @return An instance of af a logger, ready to be used.
	new: (loggerName: string, studioOnly: boolean, stackTraceDepth: number?) -> Logger,
}

export type Logger = {
	--- Prints to the development console.
	--- @param message The message to print.
	PrintInformation: (self: Logger, message: string, ...any) -> (),
	--- Prints a warning.
	--- @param message The message to print.
	PrintWarning: (self: Logger, message: string, ...any) -> (),
	--- Prints a light error, will not error the thread.
	--- @param message The message to print.
	PrintError: (self: Logger, message: string, ...any) -> (),
	--- Prints an error. Will error the thread
	--- @param message The message to print.
	PrintCritical: (self: Logger, message: string) -> (),
	--- Restores a polluted environment back to the VEngine default one.
	--- @param f The function that whose environment will be restored
	RestoreEnvironment: (self: Logger, f: () -> () | number) -> (),
	--- Pollutes an environment, replacing the print, warn and error functions with custom implementations.
	--- @param f The function that whose environment will be restored
	PolluteEnvironment: (self: Logger, f: () -> () | number) -> (),

	--- The name of the logger, used when building it.
	LoggerName: string,
	--- Whether or not the logger should only print when it is on studio
	StudioOnly: boolean,
	--- The depth of the stack trace on errors when printing Critical error messages.
	StackTraceDepth: number,
}

export type EngineEnum = { [string]: EngineEnumItem }

export type EngineEnumItem = {
	Value: number,
	Name: string,
	EnumType: EngineEnum,
}

export type ValidationFailureReason = "TooLong" | "UnexpectedType" | "CannotBeSerialised" | "InvalidInput" | "Success"

export type State = {
	--- The name of the state.
	Name: string,
	--- Executes a step in this state.
	--- @param LoggerInstance The logger instance associated with this State's currently executing state machine.
	--- @param stateMachineMemory A snapshot of the memory of the State Machine executing this state.
	--- @return The next state; If nil the state machine should stop.
	ExecuteState: (LoggerInstance: Logger, stateMachineMemory: { any }) -> State?,
}

export type StateMachineFactory = {
	--- Creates a Finite State Machine.
	--- @param machineName The name of the state machine.
	--- @param states The table of valid states for the machine to be on. There must be a default state embedded into it called either "Start" or "Idle". Else the State Machine will not be created.
	--- @param enableDebugPrints Weather or not the machine should print out its state in a verbose, debuggable manner.
	--- @return The state machine that was created with the given parameters.
	CreateStateMachine: (machineName: string, states: { State }, enableDebugPrints: boolean) -> StateMachine,
}

export type StateMachine = {
	--- Fired when the State Machine exits.
	--- Invoked with parameter #1 as the last state before exiting.
	OnExit: BindableEvent,

	--- Fired when the state changes.
	--- Invoked with parameter #1 as previous state and parameter #2 as the new state
	OnStateChanged: BindableEvent,

	--- Fired when the State Machine has obtained its initial state and is ready.
	Ready: BindableEvent,

	--- The valid states of the state machine.
	StateMachineStates: { State },

	--- Starts the machine and returns the Thread that is currently running the state machine.
	--- @return machineThread The machine thread
	StartMachine: (self: StateMachine) -> thread?,

	---	Stops the State Machine safely.
	--- @return If true, the State Machine was stopped correctly, else an error occurred
	StopMachine: (self: StateMachine) -> boolean,

	--- Returns whether or not the State Machine is running
	--- @return Whether or not the state machine is running.
	IsStateMachineRunning: (self: StateMachine) -> boolean,

	---	Modifies the internal state of the state machine externally.
	--- @param newState The new state you want to set the state machine to have.
	--- @return The old state that the machine had before it was modified
	ModifyMemory: (self: StateMachine, newState: { any }) -> { any },

	--- Releases all resources and destroyed any instances attached to this State Machine instance
	--- After using this function, the State Machine will not be able to run again.
	Dispose: (self: StateMachine) -> (),

	--- Returns a deep clone of the State Machine's current memory
	--- @return A copy of the memory of the state machine as a table.
	GetState: (self: StateMachine) -> any,
}

export type EngineTimeSpan = {
	--- Internal varirable. Do not use.
	Ticks: number,

	--- Gets the number of ticks representing this EngineTimeSpan instance.
	--- @return Ticks
	ToTicks: (self: EngineTimeSpan) -> number,
	--- Gets the number of milliseconds (For the current second).
	--- @return Milliseconds
	ToMilliseconds: (self: EngineTimeSpan) -> number,
	--- Gets the number of seconds (For the current minute).
	--- @return Seconds
	ToSeconds: (self: EngineTimeSpan) -> number,
	--- Gets the number of minutes (For the current hour).
	--- @return Minutes
	ToMinutes: (self: EngineTimeSpan) -> number,
	--- Gets the number of hours (For the current day).
	--- @return Hours
	ToHours: (self: EngineTimeSpan) -> number,
	--- Gets the number of days (For the current month).
	--- @return Days
	ToDays: (self: EngineTimeSpan) -> number,

	--- Gets the total number of milliseconds represented in this EngineTimeSpan Instance.
	--- @return Total milliseconds
	ToTotalMilliseconds: (self: EngineTimeSpan) -> number,
	--- Gets the total number of seconds represented in this EngineTimeSpan Instance.
	--- @return Total seconds
	ToTotalSeconds: (self: EngineTimeSpan) -> number,
	--- Gets the total number of minutes represented in this EngineTimeSpan Instance.
	--- @return Total minutes
	ToTotalMinutes: (self: EngineTimeSpan) -> number,
	--- Gets the total number of hours represented in this EngineTimeSpan Instance.
	--- @return Total hours
	ToTotalHours: (self: EngineTimeSpan) -> number,
	--- Gets the total number of days represented in this EngineTimeSpan Instance.
	--- @return Total days
	ToTotalDays: (self: EngineTimeSpan) -> number,
}

export type EngineSharedReplicatedEvent = {
	--- Fire the ReplicatedEvent for all clients. Two events will be fired, the Local and the Remote one.
	--- @param ... The arguments to send to the remote and local event
	FireAllClients: <T>(self: EngineSharedReplicatedEvent, ...T) -> (),

	--- Fire the ReplicatedEvent for a specific client. Two events will be fired, the Local and the Remote one.
	--- @param ... The arguments to send to the remote and local event
	FireClient: <T>(self: EngineSharedReplicatedEvent, fireForPlayer: Player, ...T) -> (),

	--- Fire the ReplicatedEvent for a specific group of clients. Two events will be fired, the Local and the Remote one.
	--- @param ... The arguments to send to the remote and local event
	FireForClients: <T>(self: EngineSharedReplicatedEvent, players: { Player }, ...T) -> (),

	--- Fire the ReplicatedEvent to the server. Two events will be fired, the Local and the Remote one.
	--- @param ... The arguments to send to the remote and local event
	FireServer: <T>(self: EngineSharedReplicatedEvent, ...T) -> (),

	--- Set up the connection the event, there are two types of events available to connect to.
	--- @param callback The callback that will be connected to the event on fire
	--- @param once Weather or not the callback should fire only once, and then disconnect.
	--- @param localEvent Weather this event should be connected to the Local signal or the Remote signal. If true, the event will be connected to the Local signal.
	--- @return A representation of the connection made to the event.
	OnFire: <T>(
		self: EngineSharedReplicatedEvent,
		callback: (...T) -> () | (Player | { Player }, ...T) -> () ,
		once: boolean,
		localEvent: boolean
	) -> EngineEventConnection?,

	--- Wait for the Remote event to be called. Waits on the appropiate remote for each context (Client or Server)
	--- @return The arguments that the remote was called with
	WaitRemote: <T>(self: EngineSharedReplicatedEvent) -> ...T,

	--- Wait for the Local event to be called.
	--- @return The arguments that the local signal was called with
	WaitLocal: <T>(self: EngineSharedReplicatedEvent) -> ...T,

	--- The local event which will fire. Represented by a Red signal.
	LocalEvent: typeof(require(ReplicatedStorage.ThirdPartyShared.signal)()),

	--- The remote event which will fire. Represented by a Red SharedSignalEvent.
	RedRemoteEvent: typeof(require(ReplicatedStorage.ThirdPartyShared.Red).SharedSignalEvent(nil :: any, nil :: any)),
}

export type EngineEventConnection = {
	--- Weather or not the connection is connected.
	Connected: boolean,
	--- Disconnect the function from the signal, cleaning up resources
	Disconnect: (self: EngineEventConnection) -> (),
}

export type SharedEventOptions = {
	--- The name of the event
	Name: string,
	--- Weather or not the event is channeled through an UnreliableRemoteEvent.
	Unreliable: boolean?,
}

export type EventOptions = {
	--- The name of the event
	Name: string,
	--- Weather or not the event is channeled through an UnreliableRemoteEvent.
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
	---	Construct a Red Signal
	RedSignal: typeof(require(ReplicatedStorage.ThirdPartyShared.signal)),
	--- Red Networking.
	RedNetworking: typeof(require(ReplicatedStorage.ThirdPartyShared.Red)),
	EventOptions: {
		---	Construct a EventOptions structure.
		--- @param eventName The name of the event.
		--- @param unreliable Whether or not its mode is set to unreliable.
		--- @return An Instance of EventOptions
		new: (eventName: string, unreliable: boolean?) -> EventOptions,
	},
	SharedEventOptions: {
		---	Construct a SharedEventOptions structure.
		--- @param eventName The name of the event.
		--- @param unreliable Whether or not its mode is set to unreliable.
		--- @return Instance of SharedEventOptions
		new: (eventName: string, unreliable: boolean?) -> EventOptions,
	},

	EngineSharedReplicatedEvent: EngineSharedReplicatedEventFactory,
} & RBXEnvBase

export type EngineKeybinds = {
	--- Initializes the EngineKeybinds. Only available on the server side.
	Initialize: () -> (),

	--- Set a key bind to the specified KeyCode
	--- @param keybindEnum An engine enum that exists within the Shared/Enums/GameKeybinds.luau file
	--- @param keycode The keycode to save the keybind as
	SetKeybind: (self: EngineKeybinds, keybindEnum: EngineEnumItem, keycode: Enum.KeyCode) -> (),

	--- Get the keycode for a specific key bind
	--- @param keybindEnum An engine enum that exists within the Shared/Enums/GameKeybinds.luau file
	--- @return The KeyCode for that Keybind
	GetKeybind: (self: EngineKeybinds, keybindEnum: EngineEnumItem) -> Enum.KeyCode?,
}

export type EngineAudioManager = {
	--- The folder used to store the sounds loaded via the EngineAudioManager
	SfxFolder: Folder,

	--- The cache of sounds, mapping Sound names to Sound instances.
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

	--- Obtains the container used in the game to Parent the sounds to.
	--- @return The folder containing all engine loaded audio located on the game's workspace.
	GetSoundContainer: (self: EngineAudioManager) -> Folder,

	--- Abruptly stop all sounds loaded via the EngineAudioManager which are not included on the exclusionList
	--- Synchronizes the thread.
	--- @param exclusionList A list of sound names which will not be stopped
	StopAllSounds: (self: EngineAudioManager, exclusionList: { string }) -> (),

	--- Fades out all sounds loaded via the EngineAudioManager which are not included on the exclusionList
	--- Synchronizes the thread.
	--- @param exclusionList A list of sound names which will not be faded out
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
