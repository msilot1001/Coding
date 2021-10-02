-- modernized 14/09/2020

-- Coolio module stuff
local handler = {}
local fpsMT = {__index = handler}	

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage.modules:WaitForChild("fastCastHandler")
ReplicatedStorage.modules:WaitForChild("spring")

local fastcastHandler = require(ReplicatedStorage.modules.fastCastHandler)
local spring = require(ReplicatedStorage.modules.spring)

-- Functions i like using and you will probably too.
-- Bobbing!

local function getBobbing(addition, speed, modifier)
	return math.sin(tick()*addition*speed)*modifier
end

function handler.new(weapons)
	local self = {}
	
	self.loadedAnimations = {}
	self.springs = {}
	self.lerpValues = {}
	self.ammo = {} -- per weapon
	
	self.lerpValues.aim = Instance.new("NumberValue")
	self.lerpValues.equip = Instance.new("NumberValue") self.lerpValues.equip.Value = 1
	
	self.springs.walkCycle = spring.create();
	self.springs.sway = spring.create()
	self.springs.fire = spring.create()
	
	self.canFire = true
	
	return setmetatable(self,fpsMT)
end

function handler:equip(wepName)
	
	-- Explained how this works earlier. we can store variables too!
       -- if the weapon is disabled, or equipped, remove it instead
	if self.disabled then return end
	if self.equipped then self:remove() end
	if self.reloading then return end
	-- get weapon from storage
	local weapon = ReplicatedStorage.weapons:FindFirstChild(wepName) -- do not cloen 
	if not weapon then return end -- if the weapon exists, clone it, else, stop
	weapon = weapon:Clone()

       --[[
	
	 	Make a viewmodel (easily accessible with weapon.viewmodel too!) 
		and throw everything in the weapon straight inside of it. This makes animation hierarchy work.
		
	--]]

	self.viewmodel = ReplicatedStorage.viewmodel:Clone()
	for _, v in pairs(weapon:GetChildren()) do
		v.Parent = self.viewmodel
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CastShadow = false
		end
	end		
	
	-- Time for automatic rigging and some basic properties
	self.camera = workspace.CurrentCamera
	self.character = Players.LocalPlayer.Character
	
	-- Throw the viewmodel under the map. It will go back to the camera the next render frame once we get to moving it.
	self.viewmodel.rootPart.CFrame = CFrame.new(0, -100, 0)
	-- We're making the gun bound to the viewmodel's rootpart, and making the arms move along with the viewmodel using hierarchy.
	self.viewmodel.rootPart.weapon.Part1 = self.viewmodel.weaponRootPart
	self.viewmodel.left.leftHand.Part0 = self.viewmodel.weaponRootPart
	self.viewmodel.right.rightHand.Part0 = self.viewmodel.weaponRootPart
	-- I legit forgot to do this in the first code revision.
	self.viewmodel.Parent = workspace.Camera
	
	self.settings = require(self.viewmodel.settings)
	self.loadedAnimations.idle = self.viewmodel.AnimationController:LoadAnimation(self.settings.animations.viewmodel.idle)
	self.loadedAnimations.reload = self.viewmodel.AnimationController:LoadAnimation(self.settings.animations.viewmodel.reload)
	self.loadedAnimations.fire = self.viewmodel.AnimationController:LoadAnimation(self.settings.animations.viewmodel.fire)
	self.loadedAnimations.idle:Play()	
	
	-- set ammo, either current or default filled
	self.wepName = wepName
	self.ammo[wepName] = self.ammo[wepName] or (self.settings.firing.magCapacity + 1)
	
	local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 0 }):Play()		
	
	--[[
		Real life example:
			
		self.loadedAnimations.idle = self.viewmodel.AnimationController:LoadAnimation(self.settings.anims.viewmodel.idle)
		self.loadedAnimations.idle:Play()
	
		self.tweenLerp("equip","In")
		self.playSound("draw")
		
	--]]
	
	-- coroutine'd because server requests are far from instant
	coroutine.wrap(function()

		-- if server say no, then so does the client
		local pass = ReplicatedStorage.weaponRemotes.equip:InvokeServer(wepName)
		if not pass then self:remove() end		
	end)()
	
	self.curWeapon = wepName
	self.equipped = true -- Yay! our gun is ready.
end

function handler:remove()
	
	if self.reloading then return end
	if self.firing then self:fire(false) end
	if self.aiming then self:aim(false) end 
	
	local tweeningInformation = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 1 }):Play()	
		
	self.equipped = false -- Nay! We can't do anything with the gun now.
	self.disabled = true
	self.curWeapon = nil
	
	coroutine.wrap(function()
		-- cough
		ReplicatedStorage.weaponRemotes.unequip:InvokeServer()
	end)()
	
	
	wait(0.6) --wait until the tween finished so the gun lowers itself smoothly
	if self.viewmodel then
		self.viewmodel:Destroy()
		self.viewmodel = nil
	end
	self.disabled = false
	
end

function handler:reload()
	
	if self.firing then self:fire(false) end
	if self.aiming then self:aim(false) end
	if self.reloading then return end
	
	self.reloading = true
	self.ammo[self.wepName] = 0
	self.loadedAnimations.reload:Play()
	
	-- we can use keyframe reached here, i will use length instead. waiting for the animation to finish will yield infinitely
	if not self.equipped then return end
	wait(self.loadedAnimations.reload.Length)
	
	self.ammo[self.wepName] = self.settings.firing.magCapacity
	self.reloading = false
end

function handler:fire(tofire)
	
	if self.reloading then return end
	if self.disabled then return end
	if not self.equipped then return end
	if tofire and self.ammo[self.wepName] <= 0 then self:reload() return end
	if self.firing and  tofire then return end 
	if not self.canFire and tofire then return end
	
	-- this makes the loop stop running when set to false
	self.firing = tofire
	if not tofire then return end
	
	-- while lmb held down do
	local function fire()
		if self.ammo[self.wepName] <= 0 then return end
		
		-- It's better to replicate the change to other clients and play it there with the same code as here instead of using SoundService.RespectFilteringEnabled = false
		local sound = self.viewmodel.receiver.pewpew:Clone()
		sound.Parent = self.viewmodel.receiver
		sound:Play()
		
		-- replace? i've heard bad things about debris service
		game:GetService("Debris"):AddItem(sound, 5)
		self.loadedAnimations.fire:Play()
		self.ammo[self.wepName] = self.ammo[self.wepName] - 1
		
		-- addition of deltatime here is a poor attempt at fixing the recoil being framerate based
		-- this doesn't happen in my own game, dunno why
		self.springs.fire:shove(Vector3.new(0.03, 0, 0) * self.deltaTime * 60)
		spawn(function()
			wait(.15)
			self.springs.fire:shove(Vector3.new(-0.03, 0, 0) * self.deltaTime * 60)
		end)
		
		-- Muzzle flash. This is why we left it invisible and enabled.
		coroutine.wrap(function()		
			
			-- could be optimized a lot
			-- flash flashes inside the barrel, and smoke smokes for a short time
			
			for _, v in pairs(self.viewmodel.receiver.barrel:GetChildren()) do
				if v.Name == "flash" then
					v.Transparency = NumberSequence.new(v.transparency.Value)
				elseif v.Name == "smoke" then
					v.Enabled = true
				end
			end	
			
			RunService.RenderStepped:Wait()
			
			for _, v in pairs(self.viewmodel.receiver.barrel:GetChildren()) do
				if v.Name == "flash" then
					v.Transparency = NumberSequence.new(1)
				elseif v.Name == "smoke" then
					v.Enabled = false
				end
			end		
			
		end)()		
		
		-- origin, direction
		-- barrel because realism, camera.CFrame because uh accuracy and arcadeying 
		-- make sure the barrel is facing where the gun fires
		-- aaand make sure the gun is actually facing towards the cursor properly, players don't like offsets
		
		local origin = self.viewmodel.receiver.barrel.WorldPosition
		local direction = self.viewmodel.receiver.barrel.WorldCFrame
		
		-- inconsistent :(
		fastcastHandler:fire(origin, direction, self.settings)
		
		wait(60/self.settings.firing.rpm)
	end
	
	repeat
		self.canFire = false
		fire()
		self.canFire = true
	until self.ammo[self.wepName] <= 0 or not self.firing
	
	if self.ammo[self.wepName] <= 0 then
		self.firing = false
	end
	
	
end

function handler:aim(toaim)
	
	-- we'll be using this soon
	-- We used it! ha!
	
	-- add a TweenService variable at the top that references TweenService yourself, thanks
	
	if self.disabled then return end
	if not self.equipped then return end
	
	self.aiming = toaim
	game:GetService("UserInputService").MouseIconEnabled = not toaim --do this wherever you want
	ReplicatedStorage.weaponRemotes.aim:FireServer(toaim)
	
	-- This is an easy to make approach
	
	if toaim then
		-- customize speed at will. 

		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 1 }):Play()			
	else

		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 0 }):Play()			
	end
	
end

function handler:update(deltaTime)
	
	self.deltaTime = deltaTime

	-- IF we have a gun right now. We're checking the viewmodel instead for "reasons".
	if self.viewmodel then
		
		-- for animations
		-- breaks for some people? idk
		local animatorCFrameDifference = self.lastReceiverRelativity or CFrame.new() * self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.rootPart.CFrame):Inverse()
		local x,y,z = animatorCFrameDifference:ToOrientation()
		workspace.Camera.CFrame = workspace.Camera.CFrame * CFrame.Angles(x, y, z)
		self.lastReceiverRelativity = self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.rootPart.CFrame)

		-- get velocity for walkCycle
		local velocity = self.character.HumanoidRootPart.Velocity
		
		-- you can add priorities here! for example, equip offset for procedural equipping would be below aimOffset to overwrite it when removing the gun.
		-- here, aim overwrites idle.
		local idleOffset = self.viewmodel.offsets.idle.Value
		local aimOffset = idleOffset:lerp(self.viewmodel.offsets.aim.Value, self.lerpValues.aim.Value)
		local equipOffset = aimOffset:lerp(self.viewmodel.offsets.equip.Value, self.lerpValues.equip.Value)
		
		-- it'll be final for a reason. You saw!
		local finalOffset = equipOffset
		
		-- Let's get some mouse movement!
		local mouseDelta = game:GetService("UserInputService"):GetMouseDelta()
		if self.aiming then mouseDelta *= 0.1 end
		self.springs.sway:shove(Vector3.new(mouseDelta.X / 200, mouseDelta.Y / 200)) --not sure if this needs deltaTime filtering
		
		-- speed can be dependent on a value changed when you're running, or standing still, or aiming, etc.
		-- this makes the bobble faster.
		local speed = 1
		-- modifier can be dependent on a value changed when you're aiming, or standing still, etc.
		-- this makes the bobble do more. or something.
		local modifier = 0.1

		if self.aiming then modifier = 0.01 end
		
		-- See? Bobbing! contruct a vector3 with getBobbing.
		local movementSway = Vector3.new(getBobbing(10, speed, modifier), getBobbing(5, speed, modifier),getBobbing(5, speed, modifier))
	
		-- if velocity is 0, then so will the walk cycle
		self.springs.walkCycle:shove((movementSway / 25) * deltaTime * 60 * velocity.Magnitude)
		
		-- Sway! Yay!
		local sway = self.springs.sway:update(deltaTime)
		local walkCycle = self.springs.walkCycle:update(deltaTime)
		local recoil = self.springs.fire:update(deltaTime)
		
		-- RecoillllL!!!!!
		self.camera.CFrame = self.camera.CFrame * CFrame.Angles(recoil.x,recoil.y,recoil.z)
		
		--ToWorldSpace basically means rootpart.CFrame = camera CFrame but offset by xxx while taking rotation into account. I don't know. You'll see how it works soon enough.
		self.viewmodel.rootPart.CFrame = self.camera.CFrame:ToWorldSpace(finalOffset)
		self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame:ToWorldSpace(CFrame.new(walkCycle.x / 4, walkCycle.y / 2, 0))
		
		-- Rotate our rootpart based on sway
		self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame * CFrame.Angles(0, -sway.x, sway.y)
		self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame * CFrame.Angles(0, walkCycle.y / 2, walkCycle.x / 5)
	end
end

return handler