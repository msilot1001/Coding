--Boatbomber

--Services
local RunService		= game:GetService('RunService')
local UserInputService	= game:GetService("UserInputService")

--Localize
local instance,newRay	= Instance.new,Ray.new
local v2,v3,cf,udim2	= Vector2.new,Vector3.new,CFrame.new,UDim2.new
local insert,random,abs	= table.insert,math.random,math.abs


local Player			= game.Players.LocalPlayer
local Character			= Player.Character or Player.CharacterAdded:Wait()


--Bassic setup
local ViewPort			= script.Parent.ViewportFrame
local CameraPart		= workspace.CameraPart
local ScreenPart		= workspace.Screen


--Create the viewport camera
local Camera		= Instance.new("Camera")
	Camera.CFrame			= CameraPart.CFrame
	ViewPort.CurrentCamera	= Camera
	
--Only update camera CFrame when scope CameraPart moves
CameraPart:GetPropertyChangedSignal("CFrame"):Connect(function()
	Camera.CFrame			= CameraPart.CFrame
end)


local d = math.deg
local function inFOV (p0, p1)
    local x1, y1, z1 = p0:ToOrientation()
    local cf = cf(p0.p, p1.p)
    local x2, y2, z2 = cf:ToOrientation()
    return v3(d(x1-x2), d(y1-y2), d(z1-z2))
end

local Humanoids = {}
local Parts		= {}

local function RenderVersion(obj)
	local Descendants = obj:GetDescendants() 
	for i=1, #Descendants do
		local c = Descendants[i]
		if (c:IsA("Script") or c:IsA("Sound") or c:IsA("ManualWeld") or c:IsA("BasePart"))then
			c:Destroy()
		end
	end
	return obj
end
	
local function RenderHumanoid(Model, Parent, MainModel)
	local ModelParts = Model:GetChildren()
	for i=1, #ModelParts do
		local Part		= ModelParts[i]
		if not Part:IsA("Script") then
			local a			= Part.Archivable
				Part.Archivable	= true
			local RenderClone	= Part:Clone()
				Part.Archivable	= a
		
			if Part:IsA("MeshPart") or Part:IsA("Part") then
				PartUpdater = RunService.Heartbeat:Connect(function()
					if Part then
						RenderClone.CFrame = Part.CFrame
					else
						RenderClone:Destroy()
						PartUpdater:Disconnect()
					end
				end)
			elseif Part:IsA("Accoutrement") then
				PartUpdater = RunService.Heartbeat:Connect(function()
					if Part then
						RenderClone.Handle.CFrame = Part.Handle.CFrame
					else
						RenderClone:Destroy()
						PartUpdater:Disconnect()
					end
				end)
			elseif Part:IsA("Script") then
				RenderClone:Destroy()
			end
			RenderClone.Parent = Parent
		end
	end
end

local function RenderObj(Obj,Parent,Map)
	local ObjParts = Obj:GetChildren()
	for i=1, #ObjParts do
		local Part		= ObjParts[i]
		if Map then
			--Handle map objects
			if Part:IsA("BasePart") or Part:IsA("Model") or Part:IsA("Folder") then
				local a			= Part.Archivable
					Part.Archivable	= true
				local RenderClone	= RenderVersion(Part:Clone())
					Part.Archivable	= a
				RenderObj(Part,RenderClone,Map)
				RenderClone.Parent = Parent
			end
		else
			if not Part:IsDescendantOf(workspace.Map) and Part~=workspace.Map then
				if not Parts[Part] and not Humanoids[Part] then
					--handle non-map objects
					if Part:IsA("Model") or Part:IsA("Folder") then
						if Part:FindFirstChildWhichIsA("Humanoid",true) then
							--handle humanoids
--print("Found a Humanoid:",Part)
							Humanoids[Part] = true
								
							local ModelClone = instance("Model")
								ModelClone.Name		= Part.Name
															
							RenderHumanoid(Part, ModelClone,ModelClone)
								ModelClone.Parent	= Parent
						else
							--Handle normal models
--print("Found a model:",Part)
							local ModelClone = instance("Model")
								ModelClone.Name		= Part.Name
							
							Part.ChildAdded:Connect(function(Child)
								wait() --Let it load in
								RenderObj(Part,ModelClone,Map)
							end)
							
							RenderObj(Part, ModelClone, false)
								ModelClone.Parent	= Parent
						end
					elseif Part:IsA("BasePart") then --new part that we don't have yet
						--Handle regular parts
						if Part~=workspace.Terrain then
--print("Found a Part:",Part:GetFullName())
							Parts[Part] = true
							local a			= Part.Archivable
								Part.Archivable	= true
							local RenderClone	= RenderVersion(Part:Clone())
								Part.Archivable	= a

							Part.ChildAdded:Connect(function(Child)
								wait() --Let it load in
								RenderObj(Part,RenderClone,Map)
							end)
							
							local LastCF, LastTP, LastColor, LastSize, LastMat = Part.CFrame,Part.Transparency,Part.Color,Part.Size,Part.Material
		
							spawn(function()	
								while wait() do
									if Part then
										local v = inFOV(Camera.CFrame,Part.CFrame)
										if (abs(v.Y+v.X)*2)<(Camera.FieldOfView+40) then --Only update if the object is in front of the camera
											if LastCF~=Part.CFrame then
												LastCF						= Part.CFrame 
												RenderClone.CFrame			= Part.CFrame
											end
											if LastTP~=Part.Transparency then
												LastTP						= Part.Transparency
												RenderClone.Transparency	= Part.Transparency
											end
											if LastColor~=Part.Color then
												LastColor					= Part.Color
												RenderClone.Color			= Part.Color
											end
											if LastSize~=Part.Size then
												LastSize					= Part.Size
												RenderClone.Size			= Part.Size
											end
											if LastMat~=Part.Material then
												LastMat						= Part.Material
												RenderClone.Material		= Part.Material
											end
										end
									else
										--Part is destroyed, so quit the viewport render
										RenderClone:Destroy()
										Parts[Part] = false
										break
									end
								end
							end)
							RenderObj(Part,RenderClone,Map)
							RenderClone.Parent = Parent
						end
					end
				end
			end
		end
	end
end


--Let the world load before starting
wait(1)

--Create the map (Doesn't update- because we, as the creators of the map, know that it doesn't ever change)
local MapClone = Instance.new("Model")
		MapClone.Name		= 'Map'
	RenderObj(workspace.Map, MapClone,true)
		MapClone.Parent		= ViewPort


--Create the rest of the workspace
RenderObj(workspace,ViewPort)
workspace.ChildAdded:Connect(function(Child)
	wait() --Let it load in
	RenderObj(workspace,ViewPort)
end)


Character.HumanoidRootPart.CFrame = cf(ScreenPart.Position+v3(5,0,0))











