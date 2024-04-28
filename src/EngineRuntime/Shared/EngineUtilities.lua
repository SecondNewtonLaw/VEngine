local m = {}

function m.DeepClone(t: table)
	if typeof(t) ~= "table" then
		return { [1] = t }
	end

	local c = {}

	for i, v in t do
		if typeof(v) == "table" then
			c[i] = m.DeepClone(v)
		else
			c[i] = v
		end
	end

	return c
end

return m
