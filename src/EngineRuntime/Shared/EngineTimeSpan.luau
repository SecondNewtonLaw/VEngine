--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--[[
	This code is based off the work done in Microsofts .NET TimeSpan implementation.
	- https://github.com/microsoft/referencesource/blob/master/mscorlib/system/timespan.cs
]]

local engineTimeSpan = {}

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

local TicksPerMillisecond = 10000
local MillisecondsPerTick = 1.0 / TicksPerMillisecond

local TicksPerSecond = TicksPerMillisecond * 1000 -- 10,000,000
local SecondsPerTick = 1.0 / TicksPerSecond -- 0.0001

local TicksPerMinute = TicksPerSecond * 60 -- 600,000,000
local MinutesPerTick = 1.0 / TicksPerMinute -- 1.6666666666667e-9

local TicksPerHour = TicksPerMinute * 60 -- 36,000,000,000
local HoursPerTick = 1.0 / TicksPerHour --2.77777777777777778e-11

local TicksPerDay = TicksPerHour * 24 --864,000,000,000
local DaysPerTick = 1.0 / TicksPerDay -- 1.1574074074074074074e-12

local MillisPerSecond = 1000
local MillisPerMinute = MillisPerSecond * 60 --     60,000
local MillisPerHour = MillisPerMinute * 60 --  3,600,000
local MillisPerDay = MillisPerHour * 24 -- 86,400,000

function engineTimeSpan.new(ticks: number)
	local x: EngineTypes.EngineTimeSpan = {
		CreatedAt = tick(),
		Ticks = ticks,

		ToTicks = function(self): number
			return self.Ticks
		end,

		ToMilliseconds = function(self): number
			return math.round((self.Ticks / TicksPerMillisecond) % 1000)
		end,

		ToSeconds = function(self): number
			return math.round((self.Ticks / TicksPerSecond) % 60)
		end,

		ToMinutes = function(self): number
			return math.round((self.Ticks / TicksPerMinute) % 60)
		end,

		ToHours = function(self): number
			return math.round((self.Ticks / TicksPerHour) % 24)
		end,

		ToDays = function(self): number
			return math.round((self.Ticks / TicksPerDay))
		end,

		ToTotalMilliseconds = function(self): number
			return (self.Ticks * MillisecondsPerTick)
		end,

		ToTotalSeconds = function(self): number
			return (self.Ticks * SecondsPerTick)
		end,

		ToTotalMinutes = function(self): number
			return (self.Ticks * MinutesPerTick)
		end,

		ToTotalHours = function(self): number
			return (self.Ticks * HoursPerTick)
		end,

		ToTotalDays = function(self): number
			return (self.Ticks * DaysPerTick)
		end,
	}

	return table.freeze(x)
end

--- Transforms the scale and uses it to create a new EngineTimeSpan.
--- @param scaledTicks number Scaled time
--- @param scale number The scale used.
--- @return EngineTimeSpan timeSpan an EngineTimeSpan object.
function engineTimeSpan.fromScaled(scaledTicks: number, scale: number): Types.EngineTimeSpan
	return engineTimeSpan.new((scaledTicks * scale + (scaledTicks >= 0 and 0.5 or -0.5)) * TicksPerMillisecond)
end

function engineTimeSpan.fromMilliseconds(milliseconds: number): Types.EngineTimeSpan
	return engineTimeSpan.fromScaled(milliseconds, 1)
end

function engineTimeSpan.fromSeconds(seconds: number): Types.EngineTimeSpan
	return engineTimeSpan.fromScaled(seconds, MillisPerSecond)
end

function engineTimeSpan.fromMinutes(minutes: number): Types.EngineTimeSpan
	return engineTimeSpan.fromScaled(minutes, MillisPerMinute)
end

function engineTimeSpan.fromHours(hours: number): Types.EngineTimeSpan
	return engineTimeSpan.fromScaled(hours, MillisPerHour)
end

function engineTimeSpan.fromDays(days: number): Types.EngineTimeSpan
	return engineTimeSpan.fromScaled(days, MillisPerDay)
end

function engineTimeSpan.fromTime(
	days: number,
	hours: number,
	minutes: number,
	seconds: number,
	milliseconds: number
): Types.EngineTimeSpan
	local totalMs = -- ToMs()!
		(
			(
				(days * 3600 * 24) -- Days->Seconds
				+ (hours * 3600) -- Hours->Seconds
				+ (minutes * 60) -- Minute ->Seconds
				+ seconds
			) * 1000 -- Seconds->Ms
		) + milliseconds -- Ms + Ms
	return engineTimeSpan.fromMilliseconds(totalMs)
end

return engineTimeSpan
