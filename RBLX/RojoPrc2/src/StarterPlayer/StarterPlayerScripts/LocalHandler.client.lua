local Selectedgun = "Groza"

local GunModel = game.ReplicatedStorage:WaitForChild("Groza")
local ViewModel = game.ReplicatedStorage:WaitForChild("Viewmodel")
local AnimFolder = game.ReplicatedStorage:WaitForChild("Groza_Animations")

local MainModule = require(game.ReplicatedStorage.MainModule)
local SpringModule = require(game.ReplicatedStorage.SpringModule)

ViewModel.Parent = game.Workspace.Camera

MainModule.weldgun(GunModel)

local RecoilSpring = SpringModule.new()
local BobbleSpring = SpringModule.new()
local SwayingSpring = SpringModule.new()
	
game:GetService("RunService").RenderStepped:Connect(function(dt)
	MainModule.update(ViewModel, dt, RecoilSpring, BobbleSpring, SwayingSpring, GunModel)
end)

MainModule.equip(ViewModel, GunModel, AnimFolder.Hold)

--RunorWalk

local runspeed = 25 -- how fast you want the player to sprint?
local normalspd = 16 -- what do you want the normal speed to be?
local key = Enum.KeyCode.LeftShift -- what key do you want it to work with?
local fov = 60
local fovMin = { FieldOfView = fov }
local fovMax = { FieldOfView = fov + runspeed }
local Camera = game.Workspace.CurrentCamera
local TweenSev1 = game.TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine), fovMax)
local TweenSev2 = game.TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine), fovMin)
local function RunorWalk(isRunning)
    local player = game.Players.LocalPlayer
    
    if isRunning then
        if player.Character:FindFirstChild("Humanoid") then
            player.Character:FindFirstChild("Humanoid").WalkSpeed = runspeed
        end
    else
        if player.Character:FindFirstChild("Humanoid") then
            player.Character:FindFirstChild("Humanoid").WalkSpeed = normalspd
        end
    end
end
game:GetService("UserInputService").InputBegan:Connect(function(input, prc)
	if prc then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == key then
			RunorWalk(true)
			TweenSev1:Play()
			-- tween starts 1 and stops 2
		end
	end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input, prc)
	if prc then return end
	if input.KeyCode == key then
		RunorWalk(false)
		TweenSev2:Play()
	end
end)

--Shoot

local IsPlayerHoldingMouse
local CanFire = true
local RPM = 750

local Damage = game.ReplicatedStorage.Damage
local Fire = game.ReplicatedStorage.Fire

Fire.OnClientEvent:Connect(function(client, origin, endposition)
    if client ~= game.Players.LocalPlayer then
        MainModule.cast(GunModel , endposition, 5, nil)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function(dt)
	if IsPlayerHoldingMouse then
		if CanFire then
			local FireDelay = 60/RPM
			CanFire = false
			
			RecoilSpring:shove(Vector3.new(2, math.random(-1.0,1.0),10))

			coroutine.wrap(function()
				for i, v in ipairs(GunModel.GunComponents:GetChildren())do
					if v:IsA("ParticleEmitter") then
						v:Emit()
					end
				end

				local Firesound = GunModel.GunComponents.Sounds.Fire:Clone()

				Firesound.Parent = game.Workspace
				Firesound.Parent = nil
				Firesound:Destroy()
			end)()

			coroutine.wrap(function()
				wait(0.2)
				RecoilSpring:shove(Vector3.new(-1.9, math.random(-1.0,1.0),-10))
			end)()
			
			local CastParams = RaycastParams.new()
			CastParams.IgnoreWater = true
			CastParams.FilterType = Enum.RaycastFilterType.Blacklist
			CastParams.FilterDescendantsInstances = {ViewModel, game.Players.LocalPlayer.Character}

			local Mouse = MainModule.GetMouse(1000, CastParams)

			MainModule.cast(GunModel , Mouse , 300, Damage)
            Fire:FireServer(GunModel.GunComponents.Barrel.Position, Mouse)

			wait(FireDelay)
			CanFire =true
		end
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsPlayerHoldingMouse = true
		print("LMouseBegan")
	end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
		MainModule.aim(true, ViewModel, GunModel)
		print("RMouseBegan")
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		IsPlayerHoldingMouse = false
		print("LMouseEnded")
	end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
		MainModule.aim(false, ViewModel, GunModel)
		print("RMouseEnded")
	end
end)