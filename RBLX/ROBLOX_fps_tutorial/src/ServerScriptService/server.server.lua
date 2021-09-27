local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("weaponRemotes")
local weapons = ReplicatedStorage:WaitForChild("weapons")


-- ayyYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY[...]
local players = {} -- table for keeping track of weapons
local defaultWeapons = {
	[1] = "m4a4"
}
-- feel free to separate this
-- this is the amount of ammo each gun gets spare
local magazineCount = 5

-- each time the player spawns, they get a new weapon slot:
remotes:WaitForChild("new").OnServerInvoke = function(player)
	
	if not player.Character then return end
	
	-- we create a new table for the player
	players[player.UserId] = {}
	local weaponTable = players[player.UserId]
	
	-- some stuff for later
	weaponTable.magData = {}
	weaponTable.weapons = {}
	weaponTable.loadedAnimations = {}
	
	-- add each available weapon
	for index, weaponName in pairs(defaultWeapons) do 
		
		-- clone gun
		local weapon = weapons[weaponName]:Clone()
		local weaponSettings = require(weapon.settings)
		
		-- index gun
		weaponTable.weapons[weaponName] = { weapon = weapon; settings = weaponSettings }
		
		-- not used in the tutorial
		-- save gun magazines
		weaponTable.magData[index] = { current = weaponSettings.firing.magCapacity; spare = weaponSettings.firing.magCapacity * magazineCount  }
		
		--  holster goon
		weapon.Parent = player.Character
		weapon.receiver.backweld.Part0 = player.Character.Torso
		
		
	end
	
	-- we give the client the gun list
	return defaultWeapons, weaponTable.magData
end

remotes:WaitForChild("equip").OnServerInvoke = function(player, wepName)
	
	if players[player.UserId].currentWeapon then return end
	if not players[player.UserId].weapons then return end
	if not players[player.UserId].weapons[wepName] then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId]
	
	-- we mark the current gun
	weaponTable.currentWeapon = weaponTable.weapons[wepName] 
	player.gun.Value = weaponTable.currentWeapon.weapon
	
	--  unholster goon
	weaponTable.currentWeapon.Parent = player.Character
	weaponTable.currentWeapon.weapon.receiver.backweld.Part0 = nil
	
	-- equip gun
	weaponTable.currentWeapon.weapon.receiver.weaponHold.Part0 = player.Character["Right Arm"]
	weaponTable.loadedAnimations.idle = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.idle)
	weaponTable.loadedAnimations.idle:Play()

	-- yes client u can equip gun
	return true 
end

-- aiiiiimingggggggggggggg
remotes:WaitForChild("aim").OnServerEvent:Connect(function(player, toaim)
	
	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId]
	
	-- we mark this for firing animations
	weaponTable.aiming = toaim
	
	-- load the aim animation
	if not weaponTable.loadedAnimations.aim then 
		
		weaponTable.loadedAnimations.aim = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.aim)
		
	end
	
	-- play or stop it
	if toaim then 
		
		weaponTable.loadedAnimations.aim:Play()
		
	else
		
		weaponTable.loadedAnimations.aim:Stop()
		
	end 
	
end)

-- reverse of equipping lol
remotes:WaitForChild("unequip").OnServerInvoke = function(player)
	
	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId]
	
	weaponTable.loadedAnimations.idle:Stop()
	weaponTable.loadedAnimations = {}
	
	-- holster gun and unequip gun
	-- if joint is alive, might need more protection if player falls off the baseplate
	
	if weaponTable.currentWeapon.weapon.receiver:FindFirstChild("weaponHold") then
		
		weaponTable.currentWeapon.Parent = player.Character
		weaponTable.currentWeapon.weapon.receiver.backweld.Part0 = player.Character.Torso
	
		weaponTable.currentWeapon.weapon.receiver.weaponHold.Part0 = nil
	end
	-- we mark the inexistence of the current gun
	weaponTable.currentWeapon = nil
	player.gun.Value = nil
	
	-- 
	return true 
end

-- pew
remotes:WaitForChild("fire").OnServerEvent:Connect(function(player, origin, direction)
	
	local weaponTable = players[player.UserId]
	if not weaponTable.currentWeapon then return end
	if not player.Character then return end 
	
	-- DO NOT do this without verification
	-- we replicate the changes to other clients
	remotes.fire:FireAllClients(player, origin, direction)
	
	if weaponTable.aiming then 

		if not weaponTable.loadedAnimations.aimFire then 
			
			weaponTable.loadedAnimations.aimFire = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.aimFire)
		end	
		
		weaponTable.loadedAnimations.aimFire:Play()	
		
	else

		if not weaponTable.loadedAnimations.idleFire then 
			
			weaponTable.loadedAnimations.idleFire = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.idleFire)
		end	
		
		weaponTable.loadedAnimations.idleFire:Play()			
		
	end
	
end)


-- player hit event
-- i will also point out here as well that this is a bad method since a *certain* human being decided to not read the client side of this
-- arsenal had a literal cheater takeover this summer because they didn't verify hit security, don't be like them 
-- https://pastebin.com/zLHzyzHq
remotes:WaitForChild("hit").OnServerEvent:Connect(function(player, humanoid, headshot)

	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	
	if headshot then 
		
		humanoid:TakeDamage(players[player.UserId].currentWeapon.settings.firing.headshot)
	else
		
		humanoid:TakeDamage(players[player.UserId].currentWeapon.settings.firing.damage)
	end 
end)


-- for making a gun variable
Players.PlayerAdded:Connect(function(player)
	
	-- this method of adding values to the player on-added is much better than pasting the same code all over again.
	-- the gun variable is incredibly useful for keeping track of the gun inside other scripts, such as procedural animations w/ foot planting
	-- why did i mention that earlier? because I used to copy paste variables over and over in older games.
	local values = {
		{ name = "gun"; value = nil; type = "ObjectValue" };
	}
	
	-- table good c+p bad
	for _, v in pairs(values) do
		local value = Instance.new(v.type)
		value.Name = v.name
		value.Value = v.value
		value.Parent = player
	end
	
end)