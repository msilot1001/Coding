local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local AssetFolder = ReplicatedStorage.Assets
local StrucFolder = AssetFolder.Structure
local localplayer = game.Players.LocalPlayer
local RemoteEventFolder = game.ReplicatedStorage.RemoteEvents
local StructureFrame = script.Parent.StructureFrame
local Character = localplayer.Character or localplayer.Character:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local mouse = localplayer:GetMouse()

local YBuildingOffset = 5
local maxPlacingDis = 50
local rKeyIsPressed