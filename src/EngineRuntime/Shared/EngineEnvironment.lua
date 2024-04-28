local ReplicatedStorage = game:GetService("ReplicatedStorage")
local envManager = {}

print("[VEngine::EngineEnvironmentManager] Initializing Environment Manager...")

local EngineUtilities = require(ReplicatedStorage:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

local function ConstructEngineEnvironment(baseEnvironment: table)
	--- Table containing all the environment of VEngine.
	local nEnv = EngineUtilities.DeepClone(baseEnvironment)

	--- The Red networking library.
	nEnv["RedNetworking"] = require(ReplicatedStorage:WaitForChild("ThirdPartyShared"):WaitForChild("Red"))

	--- Factory for EventOptions (Part of Red Networking)
	nEnv["EventOptions"] = {
		---	Construct a EventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table eventOptions Instance of EventOptions
		new = function(eventName: string, unreliable: boolean?): EventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	--- Factory for SharedEventOptions (Part of Red Networking)
	nEnv["SharedEventOptions"] = {
		---	Construct a SharedEventOptions structure.
		--- @param eventName string The name of the event.
		--- @param unreliable boolean Whether or not its mode is set to unreliable.
		--- @return table sharedEventOptions Instance of SharedEventOptions
		new = function(eventName: string, unreliable: boolean?): SharedEventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}

	return nEnv
end

function envManager.GetEngineGlobals()
	return table.freeze(ConstructEngineEnvironment({}))
end

function envManager.ModifyEnvironment(func: () -> ())
	if typeof(func) == "number" then
		func += 1 -- Assume the given number was the level of the caller. Increase by one to access the callers' instead of ours.
	end
	setfenv(func, ConstructEngineEnvironment(getfenv(func)))
end

return table.freeze(envManager)
