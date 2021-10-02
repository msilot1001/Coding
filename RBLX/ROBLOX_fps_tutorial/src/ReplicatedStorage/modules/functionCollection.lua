-- free stuff

---@class functionCollection
local collection = {}

function collection.isNotANumber(num: number): boolean
	return num ~= num
end

function collection.pickRandomInList(list: Dictionary): any
	return list[math.random(1, #list)]
end

-- stolen from arduino api, map(0.9, 0.8, 1, 0, 1) ==> 0.5
function collection.map(value, in_min, in_max, out_min, out_max): number
	return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
end

-- from elle
function collection.lerpNumber(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- from elle
function collection.isPointInsidePart(point, part, additionalPartSize): boolean
	additionalPartSize = additionalPartSize or 0
	local offset = part.CFrame:pointToObjectSpace(point)
	return math.abs(offset.X) <= (part.Size.X + additionalPartSize) / 2
	  and math.abs(offset.Y) <= (part.Size.Y + additionalPartSize) / 2
	  and math.abs(offset.Z) <= (part.Size.Z + additionalPartSize) / 2
end

--- # shitty
function collection.rayShow(ray, hitPos, killTimeout, altColorScheme)

	coroutine.wrap(function()

		local origin = ray.Origin
		local pos = hitPos

		local originPart = Instance.new("Part")
		originPart.Size = Vector3.new(0.1,0.1,0.1)
		originPart.Color = Color3.new(0,1,0)
		originPart.CFrame = CFrame.new(origin)
		originPart.Anchored = true
		originPart.CanCollide = false
		originPart.Parent = workspace.fastCast

		local hitPosPart = Instance.new("Part")
		hitPosPart.Size = Vector3.new(0.1,0.1,0.1)
		hitPosPart.Color = Color3.new(0,0,1)
		hitPosPart.CFrame = CFrame.new(pos)
		hitPosPart.Anchored = true
		hitPosPart.CanCollide = false
		hitPosPart.Parent = workspace.fastCast

		local part = Instance.new("Part")
		part.Size = Vector3.new(0.05,0.05,(origin - pos).Magnitude)
		part.Color = Color3.new(1,0,0)
		part.CFrame = CFrame.new(origin,pos) * CFrame.new(0, 0, -((origin - pos).Magnitude / 2))
		part.Anchored = true
		part.CanCollide = false
		part.Parent = workspace.fastCast

		if altColorScheme then
			part.Color = Color3.new(1,1,1)
		end

		wait(killTimeout)
		part:Destroy()
		hitPosPart:Destroy()
		originPart:Destroy()

	end)()

end

--- Wait through a descendant tree starting at the instance with timeout given as WaitForChild timeout
--- callback is called if the descendant tree's end is reached
function collection:WaitForDescendant(instance: Instance, descendant: string, callback: Function, timeout: number): Instance

	local currentDescendant = instance
	for _, name in pairs(string.split(descendant, ".")) do
		local nextDescendant = currentDescendant:WaitForChild(name, timeout)
		if not nextDescendant then return end
		currentDescendant = nextDescendant
	end

	if callback then
		callback(currentDescendant)
	end

	return currentDescendant
end

return collection