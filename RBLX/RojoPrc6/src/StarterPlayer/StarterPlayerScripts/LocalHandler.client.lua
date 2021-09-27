local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local AssetFolder = ReplicatedStorage.Assets
local localplayer = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

--RunorWalk Func
local runspeed = 50
local normalspd = 16
local key = Enum.KeyCode.LeftShift
local fov = 60
local fovMin = { FieldOfView = fov }
local fovMax = { FieldOfView = fov + runspeed }
local Camera = game.Workspace.CurrentCamera
local TweenSev1 = game.TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine), fovMax)
local TweenSev2 = game.TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine), fovMin)

game:GetService("UserInputService").InputBegan:Connect(function(input, prc)
	if prc then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == key then
            if localplayer.Character:FindFirstChild("Humanoid") then
                localplayer.Character:FindFirstChild("Humanoid").WalkSpeed = runspeed
			TweenSev1:Play()
			-- tween starts 1 and stops 2
            end
        end
	end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input, prc)
	if prc then return end
	if input.KeyCode == key then
        if localplayer.Character:FindFirstChild("Humanoid") then
            localplayer.Character:FindFirstChild("Humanoid").WalkSpeed = normalspd
		TweenSev2:Play()
        end
    end
end) 

--Player Mouse Action Detection
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
	end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
	end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
	end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
	end
end)

