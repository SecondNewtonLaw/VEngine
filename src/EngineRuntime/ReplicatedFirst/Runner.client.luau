-- No check required due to require(module_)
--!native
--!nocheck

--[[
	ReplicatedFirst modules are not meant to have dependencies, and therefore we won't push the modules we load into the environment,
	nor will we use the EngineEnvironmentManager at all on this section.
]]

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

local initializedModules = 0
local moduleCount = 0

for _, moduleScript in pairs(scripts:GetDescendants()) do
	if moduleScript:IsA("ModuleScript") then
		oPrint(`- ReplicatedFirst/Game/{moduleScript.Name}`)
		moduleCount += 1
	end
end

for _, moduleScript in scripts:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		local function __run_protected_require(module: ModuleScript)
			if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then
				error(string.format("Cannot require %s as it is not a ModuleScript.", tostring(module)))
			end

			local success, ret: any = pcall(function(module_: ModuleScript)
				return require(module_)
			end, module)

			if not success then
				error(
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

		task.spawn(function()
			local _, msg = pcall(function()
				debug.setmemorycategory("ReplicatedFirst/" .. m.ModuleName)
				task.synchronize()
				m:Initialize(nil)
				task.synchronize()
				debug.resetmemorycategory()
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
		end)
	end
end

while moduleCount ~= initializedModules do
	task.wait()
end

game:GetService("ReplicatedFirst"):SetAttribute("Loaded__Preload", true)
