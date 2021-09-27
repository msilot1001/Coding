local fastcastHandler = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- babababa unknown require
local fastcast = require(ReplicatedStorage.modules.fastCastRedux)
local random = Random.new()

-- create a caster, basically the gun
local mainCaster = fastcast.new()
local bullets = {}

-- standard rayUpdated function; feel free to touch the code, just not the existing 2 lines
function rayUpdated(_, segmentOrigin, segmentDirection, length, bullet)
	
	local BulletLength = bullet.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	bullet.CFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection) * CFrame.new(0, 0, -(length - BulletLength))

end

-- Destroy the bullet, ask server to deal damage etc.
function rayHit(hitPart, hitPoint, normal, material, bullet)
	
	bullet:Destroy()
	if not hitPart then return end
		
	-- algorithm for finding damage parts
	-- still doesn't work for accessories

	local model = hitPart:FindFirstAncestorOfClass("Model")
	
	-- if model exists and has a humanoid inside
	if model and model:FindFirstChildOfClass("Humanoid") then

		-- first child of the model in the hierarchy that has a humanoid class
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		-- headshot = is hitPart a Head or an attachment with a HatAttachment inside?
		local headshot = hitPart.Name == "Head" or hitPart:FindFirstChild("HatAttachment")

		print(headshot)
		-- do NOT do this in a real game; it's awful game security and I will come to your house for tea if you do
		ReplicatedStorage.weaponRemotes.hit:FireServer(humanoid, headshot)
	else

		-- hit effects like sparks
	end
	
end

--- fires a bullet
function fastcastHandler:fire(origin: Vector3, direction: CFrame, properties, isReplicated, repCharacter)
	
	
	local rawOrigin	= origin
	local rawDirection = direction
	
	-- if the propertie aren't already required just require them
	if type(properties) ~= "table" then 
		properties = require(properties)
	end
		
	local directionalCFrame = CFrame.new(Vector3.new(), direction.LookVector)			
	direction = (directionalCFrame * CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector			
	
	local bullet = ReplicatedStorage.bullet:Clone()
	bullet.CFrame = CFrame.new(origin, origin + direction)
	bullet.Parent = workspace.fastCast
	bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
	
	-- useful with the server security i made, almost useless in this fps demo
	local id = math.random(-100000,100000)
	local idValue = Instance.new("NumberValue")
	idValue.Name = "id"
	idValue.Value = id
	idValue.Parent = bullet

	bullets[id] = {
		properties = properties;
		replicated = isReplicated;
	}
	
	-- if not replicated shooting then replicate
	if not isReplicated then 
		ReplicatedStorage.weaponRemotes.fire:FireServer(rawOrigin, rawDirection, id)
	end
	
	-- Custom list; blacklist humanoidrootparts too if your Players can croiuch and prone
	local customList = {}
	customList[#customList+1] = repCharacter
	customList[#customList+1] = workspace.Camera
	customList[#customList+1] = Players.LocalPlayer.Character
	
	-- fire the caster
	mainCaster:FireWithBlacklist(origin, direction * properties.firing.range, properties.firing.velocity, customList, bullet, true, Vector3.new(0, ReplicatedStorage.bulletGravity.Value, 0))					
end 

mainCaster.RayHit:Connect(rayHit)
mainCaster.LengthChanged:Connect(rayUpdated)

return fastcastHandler