--[[
	Copyright 2023 Dottik - All Rights Reserved

	This script is a module of the State Machine.
	This module aims to represent a possible state on a state machine.
]]

local module = {}

function module.new(stateName: string)
	--- @class State
	local self = {
		--- The name of the state.
		Name = stateName,
		--- Executes a step in this state.
		--- @param LoggerInstance Logger The logger instance associated with this State's currently executing state machine.
		--- @param stateMachineMemory table A snapshot of the memory of the State Machine executing this state.
		--- @return State nextState The next state; If nil the state machine should stop.
		ExecuteState = function(LoggerInstance: Logger, stateMachineMemory: table): State?
			local _ = LoggerInstance
			local _ = stateMachineMemory
			return nil
		end,
	}

	return self
end
return module
