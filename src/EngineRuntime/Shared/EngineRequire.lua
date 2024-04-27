local t = {}

--- Require engine modules in a protected fashion. This is assumed to ONLY be used on Engine modules.
--- @param module ModuleScript The module script that will be required
--- @return BaseEngineModule BaseEngineModule the required module.
function t.protected(module: ModuleScript): BaseEngineModule
	if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
		(critical or error)(string.format("Cannot require %s as it is not a ModuleScript.", tostring(module)))
	end

	local success, ret: string | BaseEngineModule = pcall(function()
		return require(module)
	end)

	if not success then
		(critical and error or warn)(
			string.format("Failed to require module %s! Error received: '%s'", module:GetFullName(), tostring(ret))
		)
		return nil
	end

	return ret
end

return t
