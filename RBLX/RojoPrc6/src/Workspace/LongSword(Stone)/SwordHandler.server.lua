local tool = script.Parent
local UIS = game:GetService("UserInputService")

local function onTouch(partOther)
    local humanOther = partOther.Parent:FindFirstChild("Humanoid")

    if not humanOther then return end

    if humanOther.Parent == tool then return end

    humanOther:TakeDamage(5)
end     

local function Slash()
    local str = Instance.new("StringValue")
    str.Name = "ToolAnim" 
    str.Value = "Slash"
    str.Parent = tool
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        print("Mouse Down")
    end
end)

tool.Activated:Connect(Slash)
tool.Handle.Blade.Touched:Connect(onTouch)