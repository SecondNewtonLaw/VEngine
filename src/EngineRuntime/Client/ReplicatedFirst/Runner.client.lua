local oPrint = print
local function print(str, ...)
	oPrint("[VEngine::ReplicatedFirst] " .. (#{ ... } == 0 and str or string.format(str, ...)))
end

print("Waiting for scripts...")
local scripts = game:GetService("ReplicatedFirst"):WaitForChild("Preinit")
print("Executing pre-initialization scripts:")

for _, moduleScript in pairs(scripts:GetDescendants()) do
	if moduleScript:IsA("ModuleScript") then
		oPrint(`- ReplicatedFirst/Game/{moduleScript.Name}`)
	end
end
