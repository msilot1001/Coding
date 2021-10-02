local velocity = {
	Settings = {}	
}
for _, setting in ipairs(script.Settings.VelocitySettings:GetChildren()) do
	velocity.Settings[setting.Name] = setting.Value
end

local mainVelocity = {}

local SERVICES = script.Services
local mc = require(script.ModuleComponents)

function mainVelocity:GetService(str)
	mc:params({"string"}, {str}, 1)
	
	local service = script.Services:FindFirstChild(str)
	if service then
		return require(service)
	else
		mc:errorf("%s is not a valid service!", str)
	end
end

function mainVelocity:AddService(module)
	mc:params({"Instance"}, {module}, 1)
	mc:assertf(module:IsA("ModuleScript"), "%s is not a module!", module.Name)
	
	local clone = module:Clone()
	clone.Parent = script.Services
end


function mainVelocity:GetModule(id)
	mc:assertf(typeof(id) == "string" or typeof(id) == "number", "%s is not valid, either give the string name or the id!", id)
	
	if typeof(id) == "string" then
		local container = script.ExtraModules:FindFirstChild(id)
		
		if container then
			if container:IsA("NumberValue") or container:IsA("IntValue") then
				return require(container.Value)
			elseif container:IsA("ModuleScript") then
				return require(container)
			else
				mc:errorf("%s is not a StringValue/NumberValue/IntValue or ModuleScript!", id)
			end
		else
			mc:errorf("%s module doesn't exist!", id)
		end
	else
		return require(id)
	end
end

function mainVelocity:AddModule(module)
	mc:params({"Instance"}, {module}, 1)
	
	if module:IsA("NumberValue") or module:IsA("IntValue") or module:IsA("ModuleScript") then
		module.Parent = script.ExtraModules
	else
		mc:errorf("%s is not a valid Instance class", tostring(module))
	end
end

function velocity:GetVersion()
	return "Velocity - The Framework speeding up development!\nVersion: " .. script.Misc.Version.Value
end

function velocity:SetSetting(str, val)
	mc:params({"string"}, {str}, 1)

	local Setting = script.Settings:FindFirstChild(str, true)
	mc:assertf(Setting and Setting:IsA("ValueBase"), "%s is not a valid setting!", str)
	
	Setting.Value = val
end

function velocity:GetSetting(str)
	mc:params({"string"}, {str}, 1)
	
	local Setting = script.Settings:FindFirstChild(str, true)
	mc:assertf(Setting and Setting:IsA("ValueBase"), "%s is not a valid setting!", str)
	
	return Setting.Value
end

function Handle()
	local Players = game:GetService("Players")
	local inbuilt = game:GetService("ReplicatedStorage").InbuiltEvents
	
	local playerAdded = Instance.new("BindableEvent")
	playerAdded.Name = "playerAdded"
	playerAdded.Parent = inbuilt
	
	local characterAdded = Instance.new("BindableEvent")
	characterAdded.Name = "characterAdded"
	characterAdded.Parent = inbuilt
	
	Players.CharacterAutoLoads = false
	
	Players.PlayerAdded:Connect(function(player)
		playerAdded:Fire(player)
		
		wait(velocity.Settings.RespawnTime)
		
		player.CharacterAdded:Connect(function(character)
			characterAdded:Fire(player, character)
			
			character:WaitForChild("Humanoid").Died:Connect(function()
				wait(velocity.Settings.RespawnTime)
				player:LoadCharacter()
			end)
		end)
		
		player:LoadCharacter()
	end)
	
end

function velocity:Init(handle)
	if not script.Misc.AlreadyInited.Value then
		
		local rs = game:GetService("ReplicatedStorage")
	
		local RemoteEvents = Instance.new("Folder")
		RemoteEvents.Name = "RemoteEvents"
		RemoteEvents.Parent = rs	
	
		local RemoteFunctions = Instance.new("Folder")
		RemoteFunctions.Name = "RemoteFunctions"
		RemoteFunctions.Parent = rs
		
		local BindableEvents = Instance.new("Folder")
		BindableEvents.Name = "BindableEvents"
		BindableEvents.Parent = rs
	
		local BindableFunctions = Instance.new("Folder")
		BindableFunctions.Name = "BindableFunctions"
		BindableFunctions.Parent = rs
	
		local InbuiltEvents = Instance.new("Folder")
		InbuiltEvents.Name = "InbuiltEvents"
		InbuiltEvents.Parent = rs
	
		local isHandling = Instance.new("BoolValue")
		isHandling.Name = "isHandling"
		isHandling.Parent = rs
	
		script.Misc.AlreadyInited.Value = true
		
		if velocity.Settings.PrintOnInit then
			print(velocity:GetVersion())
		end
	
		if handle then
			Handle()
			isHandling.Value = true
		end
	
		return mainVelocity
	else
		return mainVelocity
	end
end


return velocity
