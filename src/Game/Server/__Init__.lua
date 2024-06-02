-- Run to initialize some engine modules
local PlayerService = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local engineKeybinds

local moduleBaseConstructor = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineModule"))

local module = moduleBaseConstructor.new()

module.ModuleName = "ServerInitialization"

function module.Initialize(self: BaseEngineModule, envManager: EngineEnvironmentManager)
	print("Resolving requires...")

	engineKeybinds = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineKeybinds"))

	print("Requires resolved!")

	print("Engine Keybinds: Initializing...")
	engineKeybinds:Initialize()
end

return module
