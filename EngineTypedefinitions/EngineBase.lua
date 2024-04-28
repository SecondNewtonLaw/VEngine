--[[
	Note: None of the Luau written here will run. Roblox LSP will evaluate it for type information, static type notations are not recommended, you should be using
	typeof(require(...)) to avoid having to come here EVERY time to update the types when you write them, unless something makes you make them static, you are advised to avoid doing so.
]]

export type BaseEngineModule = {
	ModuleName: string,

	Initialize: (self: BaseEngineModule) -> (),
}

export type EngineUtilities = {
	---	Deep clones a table and returns it.
	DeepClone: (t: table) -> table,
}

export type EngineEnvironmentManager = typeof(require(
	game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineEnvironment")
))
export type EngineEnvironment = typeof(require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("EngineShared")
		:WaitForChild("EngineEnvironment")
		.GetEngineGlobals()
))

export type Logger = typeof(require(
	game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("Logger")
))
