local InbuiltEventsService = {}
local rs = game:GetService("ReplicatedStorage")
local mc = require(script.Parent.Parent.ModuleComponents)

setmetatable(InbuiltEventsService, {
	__index = function(self, key)
		local event = rs.InbuiltEvents:FindFirstChild(key)
			
		if event then
			return event.Event
		else
			return mc:errorf("The event %s does not exist!", key)
		end
	end;
	
	__call = function(self, param)
		mc:params({"string"}, {param}, 1)
		
		local event = rs.InbuiltEvents:FindFirstChild(param)
		
		if event then
			return event.Event
		else
			return mc:errorf("The event %s does not exist!", param)
		end
	end;
})

return InbuiltEventsService
