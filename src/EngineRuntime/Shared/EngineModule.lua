local moduleConstructor = {}

function moduleConstructor.new()
	--- The base of a module in VEngine, containing the minimum required methods and properties to initialize one.
	--- @class BaseEngineModule
	local module: BaseEngineModule = {}

	--- The name of the engine module.
	--- @type string
	module.ModuleName = "EngineModule"

	--- The load order of the module.
	--- The higher, the earlier it will load.
	--- @type number
	module.LoadOrder = 0

	--- Runs the initialization routine for an EngineModule.
	--- @param envManager EngineEnvironmentManager The environment manager for VEngine.
	function module:Initialize(envManager: EngineEnvironmentManager)
		local _ = envManager
		print(
			"This has not been overriden by you, the developer. You should override it to give your module functionality!"
		)
	end

	return module
end

return moduleConstructor
