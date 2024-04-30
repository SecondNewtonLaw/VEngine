local moduleConstructor = {}

function moduleConstructor.new()
	--- The base of a module in VEngine, containing the minimum required methods and properties to initialize one.
	--- @class BaseEngineModule
	local module: BaseEngineModule = {}

	--- The name of the engine module.
	--- @type string
	module.ModuleName = "EngineModule"

	--- Runs the initialization routine for an EngineModule.
	--- @param _ EngineEnvironmentManager The environment manager for VEngine.
	function module:Initialize(_: EngineEnvironmentManager)
		print(
			"This has not been overriden by you, the developer. You should override it to give your module functionality!"
		)
	end

	return module
end

return moduleConstructor
