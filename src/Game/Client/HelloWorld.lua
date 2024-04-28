local m = {}

function m:Initialize(engineEnv: EngineEnvironment)
	engineEnv.RedNetworking.Event(engineEnv.EventOptions.new("Hello", false), function() end)
end

return m
