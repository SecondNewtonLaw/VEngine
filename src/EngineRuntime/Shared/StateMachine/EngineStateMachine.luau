--!strict

--[[
	Copyright 2023 Dottik - All Rights Reserved

	This script is a module of the State Machine.

	This module represents the main runtime of the State Machine.
]]

local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LoggerModule = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("Logger"))
local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))
local EngineUtilities = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("EngineUtilities"))

local module = {}

--- Creates a State Machine.
--- @param machineName string
--- @param states table The
--- @param enableDebugPrints boolean Debug prints
--- @return StateMachine createdStateMachine The state machine that was created with the given parameters.
function module.CreateStateMachine(
	machineName: string,
	states: { Types.State },
	enableDebugPrints: boolean
): Types.StateMachine
	--- @class StateMachine
	local __self = {
		--- The valid states of the state machine.
		StateMachineStates = states,
		--- Fired when the state changes.
		--- Invoked with parameter #1 as previous state and parameter #2 as the new state
		OnStateChanged = Instance.new("BindableEvent"),
		--- Fired when the State Machine exits.
		--- Invoked with parameter #1 as the last state before exiting.
		OnExit = Instance.new("BindableEvent"),
		--- Fired when the State Machine has obtained its initial state and is ready.
		Ready = Instance.new("BindableEvent"),
	} :: Types.StateMachine

	local internalState = {
		--- The current State.
		StateMachine_CurrentState = nil,
		--- A shared piece of memory between all states.
		StateMachineMemory = {},
		--- The thread that executs the State Machine.
		MachineThread = nil :: thread?,
		--- Simple getter to the Current State.
		GetCurrentState = function(self): Types.State
			return self.StateMachine_CurrentState
		end,
	} :: any

	--- Starts the machine and returns the Thread that is currently running the state machine.
	--- @return thread machineThread The machine thread
	function __self:StartMachine()
		internalState.MachineThread = task.spawn(function()
			local LoggerInstance = LoggerModule.new(("StateMachine_%s"):format(machineName), true)
			LoggerInstance:PrintInformation("Initialising State Machine.")
			LoggerInstance:PrintInformation("Found States: " .. #states)
			-- For each game tick we will tick the state machine once.
			if internalState.StateMachine_CurrentState == nil then
				for _, value in __self.StateMachineStates do
					if value.Name == "Start" or value.Name == "Idle" then
						-- Found the idle/starting state. Break out.
						LoggerInstance:PrintInformation("Found initial State Machine state!")
						internalState.StateMachine_CurrentState = value
						break
					end
				end
				if internalState.StateMachine_CurrentState == nil then
					LoggerInstance:PrintCritical(
						"[State Machine Step] Failure! Cannot find the initial State Machine state! Please name it something like 'Start' or 'Idle'!"
					)
					return
				end
			end

			__self.Ready:Fire()

			while task.wait() do -- Main Loop.
				local currentState = internalState:GetCurrentState()
				if currentState then
					if not table.find(__self.StateMachineStates, internalState:GetCurrentState()) then
						LoggerInstance:PrintCritical(
							"[State Machine Step] Cowardly refusing to transfer control to a State that has not been registered"
						)
					end

					local nextState = currentState.ExecuteState(LoggerInstance, internalState.StateMachineMemory)
					if not nextState then
						__self.OnExit:Fire(currentState)
						if enableDebugPrints then
							LoggerInstance:PrintWarning(
								("[State Machine Step] State '%s' requested the State machine to stop."):format(
									currentState.Name
								)
							)
						end
						break
					end
					if currentState ~= nextState then
						if enableDebugPrints then
							LoggerInstance:PrintInformation(
								("[State Machine Step] Transferring state control | %s --> %s"):format(
									currentState.Name,
									nextState.Name
								)
							)
						end
						__self.OnStateChanged:Fire(currentState, nextState)
						internalState.StateMachine_CurrentState = nextState
					end
				else
					__self.OnExit:Fire(currentState)
					LoggerInstance:PrintCritical(
						"[State Machine Step] Whoops, this is weird! The current state has not been set, and this has not been accounted for!"
					)
				end
			end
		end)
		return internalState.MachineThread
	end

	---	Stops the State Machine safely.
	--- @return boolean result If true, the State Machine was stopped correctly, else an error occurred
	function __self:StopMachine()
		local success = pcall(task.cancel, internalState.MachineThread)
		__self.OnExit:Fire(internalState.StateMachine_CurrentState)
		internalState.MachineThread = nil
		return success
	end

	--- Returns whether or not the State Machine is running
	--- @return boolean isStateMachineRunning Whether or not the state machine is running.
	function __self:IsStateMachineRunning()
		return not not internalState.MachineThread
	end

	---	Modifies the internal state of the state machine externally.
	--- @param newState table The new state you want to set the state machine to have.
	function __self:ModifyMemory(newState: {})
		local oldState = internalState.StateMachineMemory
		internalState.StateMachineMemory = EngineUtilities.DeepClone(newState)
		return oldState
	end

	--- Returns a deep clone of the State Machine's current memory
	--- @return table stateMachineMemory The memory of the state machine as a table.
	function __self:GetState()
		return EngineUtilities.DeepClone(internalState.StateMachineMemory)
	end

	--- Releases all resources and destroyed any instances attached to this State Machine instance.
	function __self:Dispose()
		__self:StopMachine()
		table.clear(internalState.StateMachineMemory)
		table.clear(internalState)
		table.clear(__self.StateMachineStates)
		__self.OnExit:Destroy()
		__self.OnStateChanged:Destroy()
		__self.Ready:Destroy()
	end

	return __self :: Types.StateMachine
end

return module
