local EnhancedFunctionService = {
	Funcs = {};
}
local mc = require(script.Parent.Parent.ModuleComponents)

local EnhancedFunction = {
	Function = nil,
	Code = "",
	Returned = {},
	DidSucceed = false,
	ErrorMessage = "",
	RetryCount = 0
}
EnhancedFunction.__index = EnhancedFunction

function EnhancedFunction:run(...)
	self.Returned = table.pack(self.Function(...))
	return self
end

function EnhancedFunction:prun(...)
	local vals = table.pack(pcall(self.Function, ...))
	self.DidSucceed = vals[1]
	table.remove(vals, 1)
	
	if not self.DidSucceed then
		self.ErrorMessage = vals[1]
		self.RetryCount = self.RetryCount + 1
	else
		self.Returned = vals
		self.RetryCount = 0
	end
	
	return self
end

function EnhancedFunction:get()
	return unpack(self.Returned)
end

function EnhancedFunctionService:new(func, code)
	mc:params({"function", "string"}, {func, code}, 1)
		
	local newFunc = setmetatable({}, EnhancedFunction)
	newFunc.Function = func
	newFunc.Code = (code or "Function_") .. mc:tCount(self.Funcs)
	self.Funcs[newFunc.Code] = newFunc
	return newFunc
end

function EnhancedFunctionService:get(code)
	return self.Funcs[code] or mc:errorf("The function, with the code %s, does not exist!")
end
	
function EnhancedFunctionService:destroy(code)
	if self.Funcs[code] then
		self.Funcs[code] = nil
	else
		mc:errorf("The function, with the code %s, does not exist!")
	end
end

function EnhancedFunctionService:destroyAll()
	for funcCode, func in pairs(self.Funcs) do
		self.Funcs[funcCode] = nil
	end
end

return EnhancedFunctionService
