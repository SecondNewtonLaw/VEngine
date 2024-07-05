local module = {}

function module.DeepClone(t: { any }): { any }
	if typeof(t) ~= "table" then
		return {}
	end

	local nTable = {}

	for idx, member in t do
		if typeof(member) == "table" then
			nTable[idx] = module.DeepClone(member)
		else
			nTable[idx] = member
		end
	end

	return nTable
end

return module
