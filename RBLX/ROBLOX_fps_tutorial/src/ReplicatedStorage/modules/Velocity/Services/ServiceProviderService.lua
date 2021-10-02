local RobloxServiceProvider = {}
local mc = require(script.Parent.Parent.ModuleComponents)

setmetatable(RobloxServiceProvider, {
	__index = function(self, key)	
		local success, service = pcall(game.GetService, game, key)
		if success then 
			return service
		else
			return mc:errorf("The given key %s is not a valid roblox service!", key)
		end
	end;
	
	__call = function(self, param)
		mc:params({"string"}, param, 1)
		local success, service = pcall(game.GetService, game, param)
		if success then 
			return service
		else
			return mc:errorf("The given key %s is not a valid roblox service!", param)
		end
	end;
})


return RobloxServiceProvider
