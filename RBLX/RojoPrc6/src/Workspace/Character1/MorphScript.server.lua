local model = script.Parent
local prompt = model.Prompt.ProximityPrompt

prompt.Triggered:Connect(function(player)
    local defaultCharacter = player.Character
    local newCharacter = model.Model:Clone()

    newCharacter.HumanoidRootPart.Anchored = false
    newCharacter:SetPrimaryPartCFrame(defaultCharacter.PrimaryPart.CFrame)

    player.Character = newCharacter
    newCharacter.Parent = game.Workspace
end) 