local UtilityService = {}
local mc = require(script.Parent.Parent.ModuleComponents)

function UtilityService:GetChildrenOfA(class, instance)
	mc:params({"skip", "table"}, {class,instance}, 2)
	local children = {}
	local func
	
	if typeof(class) == "table" then
		func = function(child)
			for _, className in pairs(class) do
				mc:assertf(typeof(className) == "string", "%s is not a string in the class table!", tostring(className))
				
				if child:IsA(className) then
					return true
				end
			end
			return false
		end
	elseif typeof(class) == "string" then
		func = false
	else
		mc:errorf("The class parameter provided, %s, needs to be a number/array", tostring(class))
	end
	
	for _, child in pairs(instance:GetChildren()) do
		if func and func(child) or child:IsA(class) then
			table.insert(children, child)
		end
	end
	
	return children
end

function UtilityService:GetDescendantsOfA(class: table, instance)
	mc:params({"skip", "table"}, {class, instance}, 2)
	
	local descendants = {}
	local func
	
	if typeof(class) == "table" then
		func = function(descendant)
			for _, className in pairs(class) do
				mc:assertf(typeof(className) == "string", "%s is not a string in the class table!", tostring(className))
				
				if descendant:IsA(className) then
					return true
				end
			end
			return false
		end
	elseif typeof(class) == "string" then
		func = false
	else
		mc:errorf("The class parameter provided, %s, needs to be a number/array", tostring(class))
	end
	
	for _, descendant in pairs(instance:GetDescendants()) do
		if func and func(descendant) or descendant:IsA(class) then
			table.insert(descendants, descendant)
		end
	end
	
	return descendants
end

function UtilityService:CreateWeld(instance1, instance2)
	mc:params({"skip", "Instance"}, {instance1, instance2}, 2)
	
	if typeof(instance1) == "Instance" and instance1:IsA("BasePart") then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = instance1
		weld.Part1 = instance2
		weld.Parent = instance1
		return weld	
	elseif typeof(instance1) == "table" then
		local welds = {}
		for _, object in pairs(instance1) do
			local success, weld = pcall(self.CreateWeld, self, object, instance2)
			mc:assertf(success, "%s in the given array needs to be a BasePart Instance!", tostring(object))
			return weld
		end
	else
		return mc:errorf("%s needs to be a BasePart Instance!", tostring(instance1))
	end
end

function UtilityService:GetPartsWeldedWith(instance)
	mc:params({"Instance"}, {instance}, 1)
	
	local welds = self:GetDescendantsOfA({"Weld", "WeldConstraint"}, workspace)
	local weldedWith = {}
	
	for _, loopWeld in pairs(welds) do
		if loopWeld.Part0 == instance then
			table.insert(weldedWith, loopWeld.Part1)
		elseif loopWeld.Part1 == instance then
			table.insert(weldedWith, loopWeld.Part0)
		end
	end
	
	return weldedWith
end

function UtilityService:GetFullObjectMass(object)
	mc:params({"Instance"}, {object}, 1)
	mc:assertf(object:IsA("BasePart"), "%s needs to be a BasePart!", object)
	
	local mass = object:GetMass()
	local descendants = self:GetDescendantsOfA("BasePart", object)
	if #descendants >= 1 then
		for _, part in pairs(descendants) do
			mass = mass + part:GetMass()
		end
	end
	
	return mass
end

function UtilityService:VectorClamp(vector, min, max)
	mc:params({"Vector3", "number", "number"}, {vector, min, max}, 3)
	
	local x, y, z = math.clamp(vector.X, min, max), math.clamp(vector.Y, min, max), math.clamp(vector.Z, min, max)
	
	return Vector3.new(x, y, z)
end

function UtilityService:RandomVector(min, max, seed)
	mc:params({"number", "number", "number"}, {min, max, seed}, 0)
	local rand = Random.new(seed or tick())
	local x, y, z = rand:NextNumber(min or 0, max or 1000), rand:NextNumber(min or 0, max or 1000), rand:NextNumber(min or 0, max or 1000)
	
	return Vector3.new(x, y, z)
end

function UtilityService:ColorClamp(color, min, max)
	mc:params({"Color3", "number", "number"}, {color, min, max}, 3)
	
	local r, g, b = math.clamp(color.R, min, max), math.clamp(color.G, min, max), math.clamp(color.B, min, max)
	
	return Color3.new(r, g, b)
end

function UtilityService:RandomColor(min, max, seed)
	mc:params({"number", "number", "number"}, {min, max, seed}, 0)
	local rand = Random.new(seed or tick())
	local r, g, b = rand:NextNumber(min or 0, max or 255), rand:NextNumber(min or 0, max or 255), rand:NextNumber(min or 0, max or 255)
	
	return Color3.fromRGB(r, g, b)
end

function UtilityService:GetServerType()
	local serverType, serverOwner
	
	if not game.PrivateServerOwnerId == 0 then
		serverType = "VIP"
		serverOwner = game.PrivateServerOwnerId
	elseif not game.PrivateServerId == "" then
		serverType = "Reserved"
	else
		serverType = "Public"
	end
	
	return serverType, serverOwner
end

return UtilityService
