local InstanceSandboxService = {
	SandboxTables = {}	
}

local mc = require(script.Parent.Parent.ModuleComponents)

function InstanceSandboxService:Create(instance, tbl, name)
	mc:params({"Instance", "table", "string"}, {instance, tbl, name}, 2)
	
	tbl = setmetatable(tbl, {
		__index = instance;
		__call = instance
	})
	
	name = (name or "SandboxedInstance_") .. mc:tCount(self.SandboxTables)
	
	self.SandboxTables[name] = tbl
	
	return tbl, name
end

function InstanceSandboxService:Get(name)
	mc:params("string", {name}, 1)
	mc:assertf(self.SandboxTables[name], "%s does not exist!", name)
	
	return self.SandboxTables[name]
end

function InstanceSandboxService:Destroy(name)
	mc:params("string", {name}, 1)
	mc:assertf(self.SandboxTables[name], "%s does not exist!", name)
	
	self.SandboxTables[name] = nil
end

function InstanceSandboxService:Swap(instance, name)
	mc:params({"Instance", "string"}, {instance, name}, 2)
	mc:assertf(self.SandboxTables[name], "%s does not exist!", name)
	
	
	local metatable = getmetatable(self.SandboxTables[name])
	metatable.__index = instance
	metatable.__call = instance

	return self.SandboxTables[name]
end

return InstanceSandboxService
