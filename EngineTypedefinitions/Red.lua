-- Types for Red Networking (Mainly for its modules).

export type SignalNode<T...> = {
	Next: SignalNode<T...>?,
	Callback: (T...) -> (),
}

export type Signal<T...> = {
	Root: SignalNode<T...>?,

	Connect: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Wait: (self: Signal<T...>) -> T...,
	Once: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
}

export type SharedEventOptions = {
	Name: string,
	Unreliable: boolean?,
}

export type ValidateFunction<T...> = (...any) -> T...

export type SharedBaseEvent<T...> = {
	Id: string,
	Unreliable: boolean,

	FireClient: (self: SharedBaseEvent<T...>, Player: Player, T...) -> (),
	FireAllClients: (self: SharedBaseEvent<T...>, T...) -> (),
	FireAllClientsExcept: (self: SharedBaseEvent<T...>, Player: Player, T...) -> (),
	FireClients: (self: SharedBaseEvent<T...>, Players: { Player }, T...) -> (),
	FireFilteredClients: (self: SharedBaseEvent<T...>, Filter: (Player) -> boolean, T...) -> (),

	FireServer: (self: SharedBaseEvent<T...>, T...) -> (),
}
export type SharedSignalEvent<T...> = SharedBaseEvent<T...> & {
	CallMode: "Signal",

	Signal: Signal<...any>,

	OnServer: (self: SharedSignalEvent<T...>, Listener: (Player: Player, T...) -> ()) -> () -> (),
	OnClient: (self: SharedSignalEvent<T...>, Listener: (T...) -> ()) -> () -> (),
}

export type SharedCallEvent<T...> = SharedBaseEvent<T...> & {
	CallMode: "Call",

	Listener: ((...any) -> ())?,

	SetServerListener: (self: SharedCallEvent<T...>, Listener: (Player: Player, T...) -> ()) -> (),
	SetClientListener: (self: SharedCallEvent<T...>, Listener: (T...) -> ()) -> (),
}

export type Server<T...> = {
	Id: string,
	Validate: (...any) -> T...,

	Unreliable: boolean,

	Fire: (self: Server<T...>, Player: Player, T...) -> (),
	FireAll: (self: Server<T...>, T...) -> (),
	FireAllExcept: (self: Server<T...>, Except: Player, T...) -> (),
	FireList: (self: Server<T...>, List: { Player }, T...) -> (),
	FireWithFilter: (self: Server<T...>, Filter: (Player) -> boolean, T...) -> (),

	On: (self: Server<T...>, Callback: (Player, T...) -> ()) -> (),
}

export type Client<T...> = {
	Id: string,

	Unreliable: boolean,

	Fire: (self: Client<T...>, T...) -> (),
	On: (self: Client<T...>, Callback: (T...) -> ()) -> (),
}

export type Event<T...> = {
	Id: string,
	Validate: (...any) -> T...,

	Unreliable: boolean,

	ServerEvent: Server<T...>?,
	ClientEvent: Client<T...>?,

	Server: (self: Event<T...>) -> Server<T...>,
	Client: (self: Event<T...>) -> Client<T...>,
}

export type Red = {
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
}

export type EventOptions = {
	Name: string,
	Unreliable: boolean?,
}

export type Function<A..., R...> = {
	Id: string,
	Validate: (...any) -> A...,

	SetCallback: (self: Function<A..., R...>, Callback: (Player, A...) -> R...) -> (),
	Call: (self: Function<A..., R...>, A...) -> any, -- Simplified, I hate generics.
}
