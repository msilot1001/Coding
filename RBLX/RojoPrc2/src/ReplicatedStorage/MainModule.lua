local module = {}

local function GetBobbing(addition)
    return math.sin(tick() * 3 * addition * 1.3) * 0.5
end

function module.update(viewmodel, dt, RecoilSpring, BobbleSpring, SwayingSpring, gun)
    viewmodel.HumanoidRootPart.CFrame = game.Workspace.Camera.CFrame

    local Bobble = Vector3.new(GetBobbing(3),GetBobbing(1),GetBobbing(1))
    local MouseDelta = game:GetService("UserInputService"):GetMouseDelta()

    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

    BobbleSpring:shove(Bobble / 10 * (Character:WaitForChild("HumanoidRootPart").Velocity.Magnitude) / 10)
    
    local UpdatedRecoilSpring = RecoilSpring:update(dt)
    local UpdatedBobbleSpring = BobbleSpring:update(dt)
    local UpdatedSwaySpring = SwayingSpring:update(dt)

    gun.GunComponents.Sight.CFrame = gun.GunComponents.Sight.CFrame:Lerp(viewmodel.HumanoidRootPart.CFrame, game.ReplicatedStorage.Values.AimAlpha.Value)
    
    viewmodel.HumanoidRootPart.CFrame = viewmodel.HumanoidRootPart.CFrame:ToWorldSpace(CFrame.new(UpdatedBobbleSpring.Y, UpdatedBobbleSpring.X, 0))
    viewmodel.HumanoidRootPart.CFrame *= CFrame.new(UpdatedSwaySpring.X, UpdatedSwaySpring.Y, 0)

    viewmodel.HumanoidRootPart.CFrame *= CFrame.Angles(math.rad(UpdatedRecoilSpring.X) * 2 ,math.rad(UpdatedRecoilSpring.Y),math.rad(UpdatedRecoilSpring.Z))
    game.Workspace.Camera.CFrame *= CFrame.Angles(math.rad(UpdatedRecoilSpring.X),math.rad(UpdatedRecoilSpring.Y),math.rad(UpdatedRecoilSpring.Z))
end

function module.weldgun(gun)
    local Main = gun.GunComponents.Handle

    for i, v in ipairs(gun:GetDescendants())do
        if v:IsA("BasePart") and v ~= Main then
            local NewMotor = Instance.new("Motor6D")
            NewMotor.Name = v.Name
            NewMotor.Part0 = Main
            NewMotor.Part1 = v
            NewMotor.C0 = NewMotor.Part0.CFrame:inverse() * NewMotor.Part1.CFrame
            NewMotor.Parent = Main
        end
    end
end

function module.equip(viewmodel, gun, hold)
    local GunHandle = gun.GunComponents.Handle
    local HRP_Motor6D = viewmodel:WaitForChild("HumanoidRootPart").Handle

    gun.Parent = viewmodel
    HRP_Motor6D.Part1 = GunHandle

    local Holdanim = viewmodel.AnimationController:LoadAnimation(hold)
    Holdanim:Play()
end

function  module.cast(gun, endpos, velocity, damage)

    local Barrel = gun.GunComponents.Barrel

    local Bullet = Instance.new("Part")
    Bullet.Size = Vector3.new(0.1,0.1,0.5)
    Bullet.Anchored = true;
    Bullet.CanCollide = false;
    Bullet.Color = Color3.new(1, 0.823529, 0.443137)
    Bullet.Material = Enum.Material.Neon
    Bullet.Parent = game.Workspace

    Bullet.CFrame = CFrame.new(Barrel.Position, endpos)

    local Loop

    Loop = game:GetService("RunService").RenderStepped:Connect(function(dt)
        local Hit = workspace:Raycast(Bullet.Position, Bullet.CFrame.LookVector * velocity * 1.5)

        if Hit then
            if Hit.Instance.Parent:FindFirstChild("Humanoid") and damage ~= nil then
                --fire remote event call
                damage:FireServer(Hit.Instance.Parent, 10)

            else
                Loop:Disconnect()
                Bullet:Destroy()
            end
        end

        Bullet.CFrame *= CFrame.new(0,0, -velocity * (dt * 1))
        if(Bullet.Position - Barrel.Position).magnitude > 1000 then
            Loop:Disconnect()
            Bullet:Destroy()    
        end
    end)
end

function module.aim(toaim, viewmodel, gun)
    if toaim then
        game:GetService("TweenService"):Create(game.ReplicatedStorage.Values.AimAlpha, TweenInfo.new(1), {Value = 1}):Play()
    else
        game:GetService("TweenService"):Create(game.ReplicatedStorage.Values.AimAlpha, TweenInfo.new(1), {Value = 0}):Play()
    end
end

function module.GetMouse(Distance, CastParams)
    local MouseLocation = game:GetService("UserInputService"):GetMouseLocation()
    local UnitRay = game:GetService("Workspace").Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

    local origin = UnitRay.Origin
    local endp = UnitRay.Direction * Distance
    local Hit = game:GetService("Workspace"):Raycast(origin, endp, CastParams)

    if Hit then
        return Hit.Position
    else
        return UnitRay.Origin + UnitRay.Direction * Distance    
    end
end

return module