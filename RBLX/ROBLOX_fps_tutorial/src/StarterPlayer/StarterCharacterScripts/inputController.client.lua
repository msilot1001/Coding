-- input controller
-- modernized 14/09/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character -- 100% defined since localscript is a startercharacterscript

-- translating binds from integer to enum. You don't need to understand that.
local enumBinds = {
	[1] = "One";
	[2] = "Two";
	[3] = "Three";
}

-- wait for game to load enough
ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage:WaitForChild("weaponRemotes")
ReplicatedStorage.modules:WaitForChild("Velocity")
ReplicatedStorage.weaponRemotes:WaitForChild("fire")

-- The fps module we're about to add
local weaponHandler = require(ReplicatedStorage.modules.fps)

--Custom input service. Do this how you want, i just couldn't ever remember how to use other services consistently.
local velocity = require(ReplicatedStorage.modules.Velocity):Init(true)
local inputs = velocity:GetService("InputService")

-- Server security. We need it this time around.
local weps, ammoData = ReplicatedStorage.weaponRemotes.new:InvokeServer()
local weapon = weaponHandler.new(weps)

-- let's just make it easier on me to not mention another edit
weapon.ammoData = ammoData

-- clearing viewmodels we could have kept in the camera because of script errors and stuff
local viewmodels = workspace.Camera:GetChildren()
for _, v in pairs(viewmodels) do
	
	-- "v" only when v.Name == "viewmodel"
	-- equivalent to if v.Name == "viewmodel" then v:Destroy()
	local viewmodel = v and v.Name == "viewmodel"
	if viewmodel then
		viewmodel:Destroy()
	end
end

-- equip code
for i, v in pairs(weps) do
	
	-- cooldown for spammy bois
	local working
	
	-- we will bind this per-weapon
	local function equip()
		
		
		-- if cooldown active, then don't execute the function. for less experienced scripters, this is just the equivalent of:
		 --[[
			
			local function brug()
				
				if working == false then
					
					-- do stuff
					
				end
				
			end
		
		 --]]
		
		if working then return end 
		
		working = true
			
		-- if the current equipped weapon is different from the one we want right now (also applies to the weapon being nil)
		if weapon.curWeapon ~= v then
					
			if weapon.equipped then
				weapon:remove()
			end
			weapon:equip(v)
			
		else
		-- if it's the same, just remove it
		
			spawn(function()
				weapon:remove()
			end)
			weapon.curWeapon = nil
			
		end
		
		working = false
	end
	
	-- This means you can have 3 different weapons at once.
	inputs.BindOnBegan(nil, enumBinds[i], equip, "Equip : "..i)
end

local function update(dt)
	weapon:update(dt)
end

-- PLEASE don't do it like this.
inputs.BindOnBegan("MouseButton1", nil, function() weapon:fire(true) end, "PewPew")
inputs.BindOnEnded("MouseButton1", nil, function() weapon:fire(false) end, "PewPewEnd")

inputs.BindOnBegan("MouseButton2", nil, function() weapon:aim(true) end, "AimPewPew")
inputs.BindOnEnded("MouseButton2", nil, function() weapon:aim(false) end, "AimPewPewEnd")

inputs.BindOnBegan(nil, "R", function() weapon:reload() end, "ReloadPewPew")

-- marking the gun as unequippable
Character:WaitForChild("Humanoid").Died:Connect(function() weapon:remove() weapon.disabled = true end)
RunService.RenderStepped:Connect(update)