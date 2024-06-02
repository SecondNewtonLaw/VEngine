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

local DatastoreService = game:GetService("DataStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LoggerModule = require(ReplicatedFirst:WaitForChild("EngineShared"):WaitForChild("Logger"))
local AnticheatModuleLogger = LoggerModule.new("DataStore Utilities Module", false)

function module.BanPlayer(player: Player)
	local bansDatastore = DatastoreService:GetDataStore("Bans")

	local status, result = pcall(function(cPlayer: Player)
		return bansDatastore:GetAsync(cPlayer.UserId)
	end, player)

	if status then
		if not result then
			local success = false
			while not success and task.wait() do
				local i_success, err = pcall(function(cPlayer: Player)
					bansDatastore:SetAsync(cPlayer.UserId, true, { cPlayer.UserId })
				end, player)

				success = i_success

				if not success then
					AnticheatModuleLogger:PrintError("The datastore 'SetAsync' operation has errored! --> " .. err)
					AnticheatModuleLogger:PrintError("The operation will be retried in a second...")
					task.wait(1)
				else
					AnticheatModuleLogger:PrintInformation(
						"A player has been banned from the game --> " .. player.UserId
					)
				end
			end
		end
	else
		AnticheatModuleLogger:PrintError("The datastore 'GetAsync' operation has errored! --> " .. result)
	end
	task.wait(0.5)
	player:Kick("You have been banned from this game.")
end

function module.IsBanned(player: Player)
	-- TODO: Replace with new Roblox Banning API.

	local bansDatastore = DatastoreService:GetDataStore("Bans")

	local success, itemOrError = pcall(function(plr)
		return bansDatastore:GetAsync(plr.UserId)
	end, player)

	if success and typeof(itemOrError) == "boolean" and itemOrError then
		return true
	elseif success and not itemOrError then
		return false
	elseif not success then
		AnticheatModuleLogger:PrintError(
			("The datastore operation 'GetAsync' has failed for user %s (%d), the user has been kicked and told to Re-Join for validating them."):format(
				player.Name,
				player.UserId
			)
		)
		pcall(function(player_)
			bansDatastore:SetAsync(player_.UserId, false, { player_.UserId })
		end, player)
		player:Kick("Internal Server Error. Please Re-Join")
		return false
	end
end

--- Defines whether or not an item is valid for a datastore.
--- @param item any The item to evaluate
--- @param expectedType string The name of the expected type. The return of typeof(str)
--- @param expectedLength number? The expected length of the item, defaults to 255 if not set.
function module.IsValidForDatastore(item: any, expectedType: string, expectedLength: number?): ValidationFailureReason
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

		local function assureClean(tab, depth: number?): ValidationFailureReason
			if not depth then
				depth = 1
			end
			if depth > MaxRecursionDepth then
				return module.ValidationFailureReason.ValidationTimeout
			end

			for index, value in tab do
				if typeof(index) == "string" then
					local result = StringChecks(index, expectedLength)

					if result ~= module.ValidationFailureReason.Success then
						return result -- Something tripped in the table that made it unable to be "serialisable"
					end
				end

				if typeof(value) == "string" then
					local result = StringChecks(value, expectedLength)

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
