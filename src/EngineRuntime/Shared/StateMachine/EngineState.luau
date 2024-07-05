--[[
	Copyright 2023 Dottik - All Rights Reserved

	This script is a module of the State Machine.
	This module aims to represent a possible state on a state machine.
]]

local State = {}

local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

function State.new(stateName: string): Types.State
	--- @class State
	local self = {
		--- The name of the state.
		Name = stateName,
		--- Executes a step in this state.
		--- @param LoggerInstance Logger The logger instance associated with this State's currently executing state machine.
		--- @param stateMachineMemory table A snapshot of the memory of the State Machine executing this state.
		--- @return State nextState The next state; If nil the state machine should stop.
		ExecuteState = function(LoggerInstance: Types.Logger, stateMachineMemory: {}): Types.State?
			local _ = LoggerInstance
			local _ = stateMachineMemory
			return nil
		end,
	}

	return self :: Types.State
end


return State
