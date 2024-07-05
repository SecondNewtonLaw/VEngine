local module = {}

module.ValidationFailureReason = table.freeze({
	--- The length of the given data is too long.
	TooLong = "TooLong",
	--- The given type is an unexpected type.
	UnexpectedType = "UnexpectedType",
	--- The given type may not be serialised into a Datastore object.
	CannotBeSerialised = "CannotBeSerialised",
	--- Input that is invalid, and unexpected, such as \255 and so.
	InvalidInput = "InvalidInput",
	--- The validation process has failed due to a timeout or an unexpected compliction.
	ValidationTimeout = "ValidationTimeout",
	--- The input is valid, and it may be given into the datastore
	Success = "Success",
})

local Types = require(game:GetService("ReplicatedFirst"):WaitForChild("EngineShared"):WaitForChild("EngineTypes"))

--- Defines whether or not an item is valid for a datastore.
--- @param item The item to evaluate
--- @param expectedType The name of the expected type. The return of typeof(str)
--- @param expectedLength The expected length of the item, defaults to 255 if not set.
function module.IsValidForDatastore(
	item: any,
	expectedType: string,
	expectedLength: number
): Types.ValidationFailureReason
	if not expectedLength then
		expectedLength = 255
	end

	local function StringChecks(str: string, cExpectedLength: number, isKey: boolean)
		-- A string is expected.
		if string.match(str, "[^\0-\127]") then
			-- The string is NOT within the range of 0-127 characters, this item CANNOT be serialised!
			return module.ValidationFailureReason.InvalidInput
		end

		if not utf8.len(str) then
			-- Not valid UTF-8. Meaning trash
			return module.ValidationFailureReason.InvalidInput
		end

		if isKey and #str >= 50 then
			-- Datastores cannot handle strings (as keys) that are more than 50 characters long.
			return module.ValidationFailureReason.TooLong
		end

		if not isKey and #str >= 65536 then
			-- Datastores cannot handle strings longer than 65536 characters long
			return module.ValidationFailureReason.TooLong
		end

		if #str > cExpectedLength then
			-- The string is longer than what is expected
			return module.ValidationFailureReason.TooLong
		end

		return module.ValidationFailureReason.Success
	end

	if typeof(item) == "Instance" then
		return module.ValidationFailureReason.CannotBeSerialised -- Datastores cannot store Instances, they may not be serialised.
	end

	if typeof(item) == "nil" or item == nil then
		return module.ValidationFailureReason.UnexpectedType -- This may cancel UpdateAsync write operations, making them useless, and opening up data rollback exploits
	end

	if typeof(item) ~= expectedType then
		return module.ValidationFailureReason.UnexpectedType -- Not the data type caller expects
	end

	if expectedType == "string" then
		local result = StringChecks(item, expectedLength, true)

		if result ~= module.ValidationFailureReason.Success then
			return result -- Something tripped in the table that made it unable to be "serialisable"
		end
	elseif expectedType == "table" then
		-- Recurse 4 tables before failing.
		local MaxRecursionDepth = 4

		local function assureClean(tab, depth: number?): Types.ValidationFailureReason
			if not depth then
				depth = 1
			end
			if depth > MaxRecursionDepth then
				return module.ValidationFailureReason.ValidationTimeout
			end

			for index: string, value: any in tab do
				if typeof(index) == "string" then
					local result = StringChecks(index, expectedLength, true)

					if result ~= module.ValidationFailureReason.Success then
						return result -- Something tripped in the table that made it unable to be "serialisable"
					end
				end

				if typeof(value) == "string" then
					local result = StringChecks(value, expectedLength, false)

					if result ~= module.ValidationFailureReason.Success then
						return result -- Something tripped in the table that made it unable to be "serialisable"
					end
				end

				if typeof(index) == "Instance" or typeof(value) == "Instance" then
					return module.ValidationFailureReason.CannotBeSerialised -- The table contains a Key or Value that is an Instance, and because of this, it may not be serialised.
				end

				if index ~= index or value ~= value then
					return module.ValidationFailureReason.InvalidInput
				end

				if index == nil or value == nil then
					return module.ValidationFailureReason.UnexpectedType
				end

				if typeof(index) == "table" then
					local result = assureClean(index)
					if result ~= module.ValidationFailureReason.Success then
						return result -- Something tripped in the table that made it unable to be "serialisable"
					end
				end

				if typeof(value) == "table" then
					local result = assureClean(value)
					if result ~= module.ValidationFailureReason.Success then
						return result -- Something tripped in the table that made it unable to be "serialisable"
					end
				end
			end

			return module.ValidationFailureReason.Success
		end

		local result = assureClean(item)

		if result ~= module.ValidationFailureReason.Success then
			return result -- Something tripped in the table that made it unable to be "serialisable"
		end
	end

	if item ~= item then
		return module.ValidationFailureReason.CannotBeSerialised
	end

	return module.ValidationFailureReason.Success
end

return module
