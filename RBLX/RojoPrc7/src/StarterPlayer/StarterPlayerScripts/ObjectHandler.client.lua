local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local AssetFolder = ReplicatedStorage.Assets
local StrucFolder = AssetFolder.Structure

--Building Variable
local currentMode = nil
local currentObject = nil

--Object Action
local RemoteEventFolder = game.ReplicatedStorage.RemoteEvents

local EntityPlace = RemoteEventFolder.EntityPlace
local EntityDestroy = RemoteEventFolder.EntityDestroy

local orientation = CFrame.new()

local mouseHitPart = nil
local mouseHitPos = nil
local mouseHitNormal = nil

local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera

UIS.InputBegan:Connect(function(input, inGui)
	if inGui then
		return
	end

	local key = input.KeyCode

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if currentMode == "Build" then
			EntityPlace:FireServer(currentObject.Position.x,currentObject.Position.y,currentObject.Position.z,1)
		end
    end

	if key == Enum.KeyCode.E then
		if currentObject then
			currentObject:Destroy()
			currentObject = nil
		end

		if currentMode ~= "Build" then
			currentMode = "Build"

			currentObject = StrucFolder.Building1:Clone()
			currentObject.Parent = workspace

			CollectionService:AddTag(currentObject,"IgnoreCamera")
		else
			currentMode = nil
		end
	elseif key == Enum.KeyCode.R then
		orientation = CFrame.Angles(0, math.rad(90), 0) * orientation
	end
end)

--RayCast
local function raycast()
	local mousePos = UIS:GetMouseLocation()	

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {player.Character, currentObject}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)

	return workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, params)
end

local function getRotatedSize(size)
	local newModelSize = orientation * CFrame.new(size)
	newModelSize = Vector3.new(
		math.abs(newModelSize.X),
		math.abs(newModelSize.Y),
		math.abs(newModelSize.Z)
	)

	return newModelSize
end

local function getPlacementPos(size)
	local newModelSize = getRotatedSize(size)

	return Vector3.new(
		math.floor(mouseHitPos.X / 2 - 0.5) * 4 + mouseHitNormal.X * (newModelSize.X / 2) - 2,
		math.floor(mouseHitPos.Y / 0.5 + 0.5) * 0.5 + mouseHitNormal.Y * (newModelSize.Y / 2),
		math.floor(mouseHitPos.Z / 2 - 0.5) * 4 + mouseHitNormal.Z * (newModelSize.Z / 2) - 2
	)
end

game:GetService("RunService").Heartbeat:Connect(function()
	local raycastResult = raycast() or {}

	mouseHitPart = raycastResult.Instance
	mouseHitPos = raycastResult.Position
	mouseHitNormal = raycastResult.Normal

	if currentMode == "Build" then
		if mouseHitNormal and mouseHitPos and currentObject then
			currentObject:SetPrimaryPartCFrame(CFrame.new(getPlacementPos(currentObject.PrimaryPart.Size)) * orientation)
			game:GetService("CollectionService"):AddTag(currentObject,"IgnoreCamera")
		end
	end
end)