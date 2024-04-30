--[[
	Note: None of the Luau written here will run. Roblox LSP will evaluate it for type information, static type notations are not recommended, you should be using
	typeof(require(...)) to avoid having to come here EVERY time to update the types when you write them, unless something makes you make them static, you are advised to avoid doing so.
]]

export type BaseEngineModule = typeof(require(
	game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineModule").new()
))

export type EngineUtilities = typeof(require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("EngineShared")
		:WaitForChild("EngineEnvironment")
		:WaitForChild("EngineUtilities")
))

export type EngineEnvironmentManager = typeof(require(
	game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("EngineEnvironment")
))

export type EngineEnvironment = typeof(require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("EngineShared")
		:WaitForChild("EngineEnvironment")
		.GetEngineGlobals()
))

local loggerModule = require(game:GetService("ReplicatedStorage"):WaitForChild("EngineShared"):WaitForChild("Logger"))

export type LoggerConstructor = typeof(loggerModule)
export type Logger = typeof(loggerModule.new(nil, nil, nil))
