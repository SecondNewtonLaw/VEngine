--!strict

local t = {}

local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

--- Require engine modules in a protected fashion. This is assumed to ONLY be used on Engine modules.
--- @param module ModuleScript The module script that will be required
--- @return BaseEngineModule BaseEngineModule the required module.
function t.protected(module: ModuleScript): Types.BaseEngineModule?
	if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
		error(string.format("Cannot require %s as it is not a ModuleScript.", tostring(module)))
	end

	local success: boolean, ret: string | Types.BaseEngineModule = pcall(function(): Types.BaseEngineModule
		return require(module) :: Types.BaseEngineModule
	end)

	if not success or typeof(ret) == "string" then
		warn(string.format("Failed to require module %s! Error received: '%s'", module:GetFullName(), tostring(ret)))
		return nil
	end

	return ret
end

return t
