-- modernized 14/09/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- wait for game to load enough
ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage:WaitForChild("weaponRemotes")
ReplicatedStorage.weaponRemotes:WaitForChild("fire")
ReplicatedStorage.modules:WaitForChild("fastCastHandler")

local fastcastHandler = require(ReplicatedStorage.modules.fastCastHandler)

-- standard stuff above. just listen to the weapon fire replication and fire the gun again accordingly.

ReplicatedStorage.weaponRemotes.fire.OnClientEvent:Connect(function(player, origin, direction)
	
	if player ~= Players.LocalPlayer then
	
		-- varibles
		local gun = player.gun.Value
		local properties = gun.settings
		
		-- replicated fire sound
		local sound = gun.receiver.pewpew:Clone()
		sound.Parent = gun.receiver
		sound:Play()
		
		coroutine.wrap(function()		
			
			-- could be optimized a lot
			-- TODO: optimize a lot :)
			-- flash flashes inside the barrel, and smoke smokes for a short time
			
			for _, v in pairs(gun.receiver.barrel:GetChildren()) do
				if v.Name == "flash" then
					v.Transparency = NumberSequence.new(v.transparency.Value)
				elseif v.Name == "smoke" then
					v.Enabled = true
				end
			end	
			
			RunService.RenderStepped:Wait()
			
			for _, v in pairs(gun.receiver.barrel:GetChildren()) do
				if v.Name == "flash" then
					v.Transparency = NumberSequence.new(1)
				elseif v.Name == "smoke" then
					v.Enabled = false
				end
			end		
			
		end)()	
		
		-- re-fire from the client
		fastcastHandler:fire(origin, direction, properties, true)
	end

end)