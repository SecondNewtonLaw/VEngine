local ReplicatedStorage = game:GetService("ReplicatedStorage")
local envManager = {}

print("[VEngine::EngineEnvironmentManager] Initializing Environment Manager...")

local EngineUtilities = require(ReplicatedStorage:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

local function ConstructEngineEnvironment(baseEnvironment: table)
	--- @class EngineEnvironment
	local nEnv = EngineUtilities.DeepClone(baseEnvironment)

	--- Red Networking library
	nEnv["RedNetworking"] = require(ReplicatedStorage:WaitForChild("ThirdPartyShared"):WaitForChild("Red"))
	nEnv["EventOptions"] = {
		new = function(eventName: string, unreliable: boolean?): EventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}
	nEnv["SharedEventOptions"] = {
		new = function(eventName: string, unreliable: boolean?): SharedEventOptions
			return { Name = eventName, Unreliable = unreliable }
		end,
	}
	return nEnv
end

function envManager.GetEngineGlobals()
	return ConstructEngineEnvironment({})
end

function envManager.ModifyEnvironment(func: () -> ())
	if typeof(func) == "number" then
		func += 1 -- Assume the given number was the level of the caller. Increase by one to access the callers' instead of ours.
	end
	setfenv(func, ConstructEngineEnvironment(getfenv(func)))
end

return envManager
