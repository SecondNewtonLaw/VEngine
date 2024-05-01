local oPrint = print
local oWarn = warn
local function print(str, ...)
	oPrint("[VEngine::ReplicatedFirst] " .. (#{ ... } == 0 and str or string.format(str, ...)))
end

local function warn(str, ...)
	oWarn("[VEngine::ReplicatedFirst] " .. (#{ ... } == 0 and str or string.format(str, ...)))
end

print("Waiting for scripts...")
local scripts = game:GetService("ReplicatedFirst"):WaitForChild("Preinit")
print("Executing pre-initialization scripts:")

for _, moduleScript in pairs(scripts:GetDescendants()) do
	if moduleScript:IsA("ModuleScript") then
		oPrint(`- ReplicatedFirst/Game/{moduleScript.Name}`)
	end
end

local initializedModules = 0
local moduleCount = #scripts:GetChildren()
for _, moduleScript in scripts:GetChildren() do
	if moduleScript:IsA("ModuleScript") then
		local function __run_protected_require(module: ModuleScript): BaseEngineModule
			if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
				(critical or error)(string.format("Cannot require %s as it is not a ModuleScript.", tostring(module)))
			end

			local success, ret: string | BaseEngineModule = pcall(function()
				return require(module)
			end)

			if not success then
				(critical and error or warn)(
					string.format(
						"Failed to require module %s! Error received: '%s'",
						module:GetFullName(),
						tostring(ret)
					)
				)
				return nil
			end

			return ret
		end

		local m = __run_protected_require(moduleScript)

		if typeof(m) ~= "table" or typeof(m.ModuleName) ~= "string" or typeof(m.Initialize) ~= "function" then
			warn("Cowardly refusing to initialize a module that does not comply with the BaseEngineModule definition!")
			continue
		end

		print(
			string.format(
				"Running initialization routine for %s (Module: ReplicatedFirst/Game/%s)...",
				m.ModuleName,
				moduleScript.Name
			)
		)

		local _, msg = pcall(function()
			m:Initialize(nil)
		end)

		if msg then
			warn(
				string.format(
					"Failed to initialize VEngine module '%s' (Module: ReplicatedFirst/Game/%s);\nError: %s",
					m.ModuleName,
					moduleScript.Name,
					msg
				)
			)
		else
			initializedModules += 1
		end
	end
end

if moduleCount ~= initializedModules then
	warn("Some engine modules failed to initialize correctly...")
end
