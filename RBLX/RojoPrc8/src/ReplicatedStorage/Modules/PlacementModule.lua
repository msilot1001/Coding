--[[ Msilot1001     

Current Version - V1.41
Written by zblox164. Initial release (V1.0) on 2020-05-22

As of version 1.40, the changelogs have been removed from the module.	
For API, open the 'API' script. For Changelogs, open 'Changelogs'.
For FAQ and extra info, open the 'Extras' script.

]]--

-- DO NOT EDIT PAST THIS POINT

local placement = {}
placement.__index = placement

-- SETTINGS (DO NOT EDIT SETTINGS IN THE SCRIPT. USE THE ATTRIBUTES INSTEAD)

-- Bools
local interpolation = script:GetAttribute("Interpolation") -- Toggles interpolation (smoothing)
local moveByGrid = script:GetAttribute("MoveByGrid") -- Toggles grid system
local collisions = script:GetAttribute("Collisions") -- Toggles collisions
local buildModePlacement = script:GetAttribute("BuildModePlacement") -- Toggles "build mode" placement
local displayGridTexture = script:GetAttribute("DisplayGridTexture") -- Toggles the grid texture to be shown when placing
local smartDisplay = script:GetAttribute("SmartDisplay") -- Toggles smart display for the grid. If true, it will rescale the grid texture to match your gridsize
local enableFloors = script:GetAttribute("EnableFloors") -- Toggles if the raise and lower keys will be enabled
local transparentModel = script:GetAttribute("TransparentModel") -- Toggles if the model itself will be transparent
local instantActivation = script:GetAttribute("InstantActivation") -- Toggles if the model will appear at the mouse position immediately when activating placement
local includeSelectionBox = script:GetAttribute("IncludeSelectionBox") -- Toggles if a selection box will be shown while placing
local gridFadeIn = script:GetAttribute("GridFadeIn") -- If you want the grid to fade in when activating placement
local gridFadeOut = script:GetAttribute("GridFadeOut") -- If you want the grid to fade out when ending placement
local audibleFeedback = script:GetAttribute("AudibleFeedback") -- Toggles sound feedback on placement

-- Color3
local collisionColor = script:GetAttribute("CollisionColor3") -- Color of the hitbox when colliding
local hitboxColor = script:GetAttribute("HitboxColor3") -- Color of the hitbox while not colliding
local selectionColor = script:GetAttribute("SelectionBoxColor3") -- Color of the selectionBox lines (includeSelectionBox much be set to "true")
local selectionCollisionColor = script:GetAttribute("SelectionBoxCollisionColor3") -- Color of the selectionBox lines when colliding (includeSelectionBox much be set to "true")

-- Integers (Will round to nearest unit if given float)
local maxHeight = script:GetAttribute("MaxHeight") -- Max height you can place objects (in studs)
local floorStep = script:GetAttribute("FloorStep") -- The step (in studs) that the object will be raised or lowered
local rotationStep = script:GetAttribute("RotationStep") -- Rotation step
local gridTextureScale = script:GetAttribute("GridTextureScale") -- How large the StudsPerTileU/V is displayed (smartDisplay must be set to false)
local maxRange = script:GetAttribute("MaxRange") -- Max range for the model (in studs)

-- Numbers/Floats
local hitboxTransparency = script:GetAttribute("HitboxTransparency") -- Hitbox transparency when placing
local transparencyDelta = script:GetAttribute("TransparencyDelta") -- Transparency of the model itself (transparentModel must equal true)
local lerpSpeed = script:GetAttribute("LerpSpeed") -- speed of interpolation. 0 = no interpolation, 0.9 = major interpolation
local placementCooldown = script:GetAttribute("PlacementCooldown") -- How quickly the user can place down objects (in seconds)
local lineThickness = script:GetAttribute("LineThickness") -- How thick the line of the selection box is (includeSelectionBox much be set to "true")
local lineTransparency = script:GetAttribute("LineTransparency") -- How transparent the line of the selection box is (includeSelectionBox must be set to "true")
local volume = script:GetAttribute("AudioVolume") -- Volume of the sound feedback

-- Other
local gridTexture = script:GetAttribute("GridTextureID")
local soundID = script:GetAttribute("SoundID") -- ID of the sound played on Placement (requires audibleFeedback == true)

-- Cross Platform
local hapticFeedback = script:GetAttribute("HapticFeedback") -- If you want a controller to vibrate when placing objects (only works if the user has a controller with haptic support)
local vibrateAmount = script:GetAttribute("HapticVibrationAmount") -- How large the vibration is when placing objects. Choose a value from 0, 1. hapticFeedback must be set to "true".

-- Essentials
local runService = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local hapticService = game:GetService("HapticService")
local guiService = game:GetService("GuiService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local mouse = player:GetMouse()	

-- math/cframe functions
local clamp = math.clamp
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local min = math.min
local pi = math.pi
local round = math.round

local cframe = CFrame.new
local anglesXYZ = CFrame.fromEulerAnglesXYZ

-- states
local states = {
	"movement",
	"placing",
	"colliding",
	"inactive",
	"out-of-range"
}

local currentState = 4
local lastState = 4

-- Constructor variables
local GRID_UNIT
local itemLocation
local rotateKey
local terminateKey
local raiseKey
local lowerKey
local autoPlace
local xboxRotate
local xboxTerminate
local xboxRaise
local xboxLower

-- Activation variables
local plot
local object

-- bools
local canActivate = true
local currentRot = false
local running = false
local canPlace
local stackable
local smartRot
local range

-- values used for calculations
local speed = 1
local preSpeed = 1

local y
local rot
local x, z
local cx, cz
local pos = cframe(0, 0, 0)
local finalC = cframe(0, 0, 0)

local LOWER_X_BOUND
local UPPER_X_BOUND

local LOWER_Z_BOUND
local UPPER_Z_BOUND

local initialY

-- collision variables
local collisionPoints
local collisionPoint

-- other
local placedObjects
local loc
local primary
local selection
local audio
local lastPlacement = {}
local errorMessage = "You have improperly setup your callback function. Please input a valid callback"
local humanoid = character:WaitForChild("Humanoid")

-- Sets the current state depending on input of function
local function setCurrentState(state)
	currentState = clamp(state, 1, 5)
	lastState = currentState
end

-- Changes the color of the hitbox depending on the current state
local function editHitboxColor()
	if primary then
		if currentState >= 3 then
			primary.Color = collisionColor

			if includeSelectionBox then
				selection.Color3 = selectionCollisionColor
			end
		else
			primary.Color = hitboxColor

			if includeSelectionBox then
				selection.Color3 = selectionColor
			end
		end
	end
end

-- Checks to see if the model is in range of the maxRange
local function getRange()
	character = player.Character
	return (primary.Position - character.PrimaryPart.Position).Magnitude
end

-- Checks for collisions on the hitbox (credit EgoMoose)
local function checkHitbox()
	if object and collisions then
		if range then
			setCurrentState(5)
		else
			setCurrentState(1)
		end

		collisionPoint = object.PrimaryPart.Touched:Connect(function() end)
		collisionPoints = object.PrimaryPart:GetTouchingParts()

		-- Checks if there is collision on any object that is not a child of the object and is not a child of the player
		for i = 1, #collisionPoints do
			if not collisionPoints[i]:IsDescendantOf(object) and not collisionPoints[i]:IsDescendantOf(character) then
				setCurrentState(3)

				break
			end
		end

		collisionPoint:Disconnect()

		return
	end
end

-- (Raise and Lower functions) Edits the floor based on the floor step
local function raiseFloor(actionName, inputState, inputObj)
	if currentState ~= 4 and inputState == Enum.UserInputState.Begin then
		if enableFloors and not stackable then
			y = y + floor(abs(floorStep))
		end
	end
end

local function lowerFloor(actionName, inputState, inputObj)
	if currentState ~= 4 and inputState == Enum.UserInputState.Begin then
		if enableFloors and not stackable then
			y = y - floor(abs(floorStep))
		end
	end
end

-- Handles scaling of the grid texture on placement activation
local function displayGrid()
	local gridTex = Instance.new("Texture")

	gridTex.Name = "GridTexture"
	gridTex.Texture = gridTexture
	gridTex.Face = Enum.NormalId.Top
	gridTex.Transparency = 1

	if smartDisplay then
		if GRID_UNIT%2 == 0 then
			gridTex.StudsPerTileU = 2
			gridTex.StudsPerTileV = 2
		elseif GRID_UNIT == 1 then
			gridTex.StudsPerTileU = GRID_UNIT
			gridTex.StudsPerTileV = GRID_UNIT
		else
			gridTex.StudsPerTileU = 3
			gridTex.StudsPerTileV = 3
		end
	else
		gridTex.StudsPerTileU = gridTextureScale
		gridTex.StudsPerTileV = gridTextureScale
	end

	if gridFadeIn then
		spawn(function()
			for i = 1, 0, -0.1 do
				if currentState ~= 4 then
					gridTex.Transparency = i

					wait()
				end
			end
		end)
	else
		gridTex.Transparency = 0
	end
	gridTex.Parent = plot
end

local function displaySelectionBox()
	selection = Instance.new("SelectionBox")
	selection.Name = "outline"
	selection.LineThickness = lineThickness
	selection.Color3 = selectionColor
	selection.Transparency = lineTransparency
	selection.Parent = player.PlayerGui
	selection.Adornee = object.PrimaryPart
end

local function createAudioFeedback()
	audio = Instance.new("Sound")
	audio.Name = "placementFeedback"
	audio.Volume = volume
	audio.SoundId = soundID
	audio.Parent = player.PlayerGui
end

local function playAudio()
	if audibleFeedback and audio then
		audio:Play()
	end
end

-- Handles rotation of the model
local function rotate(actionName, inputState, inputObj)
	if currentState ~= 4 and currentState ~= 2 and inputState == Enum.UserInputState.Begin then
		if smartRot then
			-- Rotates the model depending on if currentRot is true/false
			if currentRot then
				rot = rot + rotationStep
			else 
				rot = rot - rotationStep
			end
		else
			rot = rot + rotationStep
		end

		-- Toggles currentRot
		currentRot = not currentRot
	end
end

-- Calculates the Y position to be ontop of the plot (all objects) and any object (when stacking)
local function calculateYPos(tp, ts, o)
	return (tp + ts*0.5) + o*0.5
end

-- Clamps the x and z positions so they cannot leave the plot
local function bounds(c)
	-- currentRot is here because if we rotate the model the offset is changed
	if currentRot then
		LOWER_X_BOUND = plot.Position.X - (plot.Size.X*0.5) + cx
		UPPER_X_BOUND = plot.Position.X + (plot.Size.X*0.5) - cx

		LOWER_Z_BOUND = plot.Position.Z - (plot.Size.Z*0.5)	+ cz
		UPPER_Z_BOUND = plot.Position.Z + (plot.Size.Z*0.5) - cz
	else
		LOWER_X_BOUND = plot.Position.X - (plot.Size.X*0.5) + cx
		UPPER_X_BOUND = plot.Position.X + (plot.Size.X*0.5) - cx

		LOWER_Z_BOUND = plot.Position.Z - (plot.Size.Z*0.5)	+ cz
		UPPER_Z_BOUND = plot.Position.Z + (plot.Size.Z*0.5) - cz
	end

	local newX = clamp(c.X, LOWER_X_BOUND, UPPER_X_BOUND)
	local newZ = clamp(c.Z, LOWER_Z_BOUND, UPPER_Z_BOUND)
	local newCFrame = cframe(newX, y, newZ)

	return newCFrame*anglesXYZ(0, rot*pi/180, 0)
end

-- Returns a rounded cframe to the nearest grid unit
local function snapCFrame(c)
	local newX = round(c.X/GRID_UNIT)*GRID_UNIT
	local newZ = round(c.Z/GRID_UNIT)*GRID_UNIT
	local newCFrame = cframe(newX, 0, newZ)

	return newCFrame
end

-- Calculates the position of the object
local function calculateItemLocation()
	if currentRot then
		cx = primary.Size.X*0.5
		cz = primary.Size.Z*0.5

		x, z = mouse.Hit.X - cx, mouse.Hit.Z - cz
	else
		cx = primary.Size.Z*0.5
		cz = primary.Size.X*0.5

		x, z = mouse.Hit.X - cx, mouse.Hit.Z - cz
	end

	-- Clamps y to a max height above the plot position
	y = clamp(y, initialY, maxHeight + initialY)

	-- Changes y depending on mouse target
	if stackable and mouse.Target and mouse.Target:IsDescendantOf(placedObjects) or mouse.Target == plot then
		y = calculateYPos(mouse.Target.Position.Y, mouse.Target.Size.Y, primary.Size.Y)
	end

	if moveByGrid then
		-- Calculates the correct position
		local pltCFrame = cframe(plot.CFrame.X, plot.CFrame.Y, plot.CFrame.Z)
		pos = cframe(x, 0, z)
		pos = snapCFrame(pltCFrame:Inverse()*pos)
		finalC = pos*pltCFrame*cframe(cx, 0, cz)
	else
		finalC = cframe(x, y, z)*cframe(cx, 0, cz)
	end

	finalC = bounds(finalC)

	return finalC	
end

--[[
	Used for sending a final CFrame to the server when using interpolation.
	When interpolating the position is changing. This is the position the object will
	end up after the lerp is finished.
]]
local function getFinalCFrame()
	return calculateItemLocation()
end

-- Sets the position of the object
local function translateObj()
	if currentState ~= 2 and currentState ~= 4 then
		if getRange() > maxRange then
			setCurrentState(5)

			range = true
		else
			range = false
		end

		checkHitbox()
		editHitboxColor()

		object:PivotTo(primary.CFrame:Lerp(calculateItemLocation(), speed))
	end
end

-- Unbinds all inputs
local function unbindInputs()
	contextActionService:UnbindAction("Rotate")
	contextActionService:UnbindAction("Terminate")
	contextActionService:UnbindAction("Pause")

	if enableFloors then
		contextActionService:UnbindAction("Raise")
		contextActionService:UnbindAction("Lower")
	end
end

-- Terminates the current placement
local function TERMINATE_PLACEMENT()
	if object then
		setCurrentState(4)

		if selection then
			selection:Destroy()
			selection = nil
		end

		stackable = nil
		canPlace = nil
		smartRot = nil

		object:Destroy()
		object = nil

		-- removes grid texture from plot
		if displayGridTexture then
			for i, v in next, plot:GetChildren() do
				if v then
					if v.Name == "GridTexture" and v:IsA("Texture") then
						if gridFadeOut then
							for i = v.Transparency, 1, 0.1 do
								v.Transparency = i

								wait()
							end

							v:Destroy()
						else
							v:Destroy()
						end	
					end
				end
			end
		end

		if audibleFeedback and audio then
			audio:Destroy()
		end

		canActivate = true

		unbindInputs()

		mouse.TargetFilter = nil

		return
	end
end

-- Binds all inputs for PC and Xbox
local function bindInputs()
	contextActionService:BindAction("Rotate", rotate, false, rotateKey, xboxRotate)
	contextActionService:BindAction("Terminate", TERMINATE_PLACEMENT, false, terminateKey, xboxTerminate)

	if enableFloors and not stackable then
		contextActionService:BindAction("Raise", raiseFloor, false, raiseKey, xboxRaise)
		contextActionService:BindAction("Lower", lowerFloor, false, lowerKey, xboxLower)
	end
end

-- Makes sure that you cannot place objects too fast.
local function coolDown(plr, cd)
	if lastPlacement[plr.UserId] == nil then
		lastPlacement[plr.UserId] = tick()

		return true
	else
		if tick() - lastPlacement[plr.UserId] >= cd then
			lastPlacement[plr.UserId] = tick()

			return true
		else
			return false
		end
	end
end

-- Generates vibrations on placement if the player is using a controller
local function createHapticFeedback()
	local isVibrationSupported = hapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1)
	local largeSupported

	if isVibrationSupported then
		largeSupported = hapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)

		if largeSupported then
			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, vibrateAmount)

			wait(0.2)	

			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large, 0)
		else
			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, vibrateAmount)

			wait(0.2)

			hapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end	
	end
end

local function updateAttributes()
	interpolation = script:GetAttribute("Interpolation")
	moveByGrid = script:GetAttribute("MoveByGrid")
	collisions = script:GetAttribute("Collisions")
	buildModePlacement = script:GetAttribute("BuildModePlacement")
	displayGridTexture = script:GetAttribute("DisplayGridTexture")
	smartDisplay = script:GetAttribute("SmartDisplay")
	enableFloors = script:GetAttribute("EnableFloors")
	transparentModel = script:GetAttribute("TransparentModel")
	instantActivation = script:GetAttribute("InstantActivation")
	includeSelectionBox = script:GetAttribute("IncludeSelectionBox")
	gridFadeIn = script:GetAttribute("GridFadeIn")
	gridFadeOut = script:GetAttribute("GridFadeOut")
	audibleFeedback = script:GetAttribute("AudibleFeedback")
	collisionColor = script:GetAttribute("CollisionColor3")
	hitboxColor = script:GetAttribute("HitboxColor3")
	selectionColor = script:GetAttribute("SelectionBoxColor3")
	selectionCollisionColor = script:GetAttribute("SelectionBoxCollisionColor3")
	maxHeight = script:GetAttribute("MaxHeight")
	floorStep = script:GetAttribute("FloorStep")
	rotationStep = script:GetAttribute("RotationStep")
	gridTextureScale = script:GetAttribute("GridTextureScale")
	maxRange = script:GetAttribute("MaxRange")
	hitboxTransparency = script:GetAttribute("HitboxTransparency")
	transparencyDelta = script:GetAttribute("TransparencyDelta")
	lerpSpeed = script:GetAttribute("LerpSpeed")
	placementCooldown = script:GetAttribute("PlacementCooldown")
	lineThickness = script:GetAttribute("LineThickness")
	lineTransparency = script:GetAttribute("LineTransparency")
	volume = script:GetAttribute("AudioVolume")
	gridTexture = script:GetAttribute("GridTextureID")
	soundID = script:GetAttribute("SoundID")
	hapticFeedback = script:GetAttribute("HapticFeedback")
	vibrateAmount = script:GetAttribute("HapticVibrationAmount")

	if not interpolation then
		speed = 1
	else
		speed = clamp(abs(tonumber(1 - lerpSpeed)), 0, 0.9)
	end
end

-- Rounds all integer attributes to the nearest whole number (int)
local function roundInts()
	script:SetAttribute("MaxHeight", round(script:GetAttribute("MaxHeight")))
	script:SetAttribute("FloorStep", round(script:GetAttribute("FloorStep")))
	script:SetAttribute("RotationStep", round(script:GetAttribute("RotationStep")))
	script:SetAttribute("GridTextureScale", round(script:GetAttribute("GridTextureScale")))
	script:SetAttribute("MaxRange", round(script:GetAttribute("MaxRange")))

	updateAttributes()
end

local function PLACEMENT(func, callback)
	if currentState ~= 3 and currentState ~= 4 and currentState ~= 5 and object then
		local cf

		-- Makes sure you have waited the cooldown period before placing
		if coolDown(player, placementCooldown) then
			-- Buildmode placement is when you can place multiple objects in one session
			if buildModePlacement then
				cf = getFinalCFrame()

				checkHitbox()
				-- Sends information to the server, so the object can be placed
				if currentState == 2 or currentState == 1 then
					setCurrentState(2)

					func:InvokeServer(object.Name, placedObjects, loc, cf, collisions, plot)

					if callback then
						xpcall(function()
							callback()
						end, function(err)
							warn(errorMessage .. "\n\n" .. err)
						end)
					end

					setCurrentState(1)
					playAudio()

					if hapticFeedback and guiService:IsTenFootInterface() then
						createHapticFeedback()
					end
				end
			else
				cf = getFinalCFrame()

				checkHitbox()

				if currentState == 2 or currentState == 1 then
					-- Same as above (line 540)
					if func:InvokeServer(object.Name, placedObjects, loc, cf, collisions, plot) then
						TERMINATE_PLACEMENT()
						playAudio()

						if callback then
							xpcall(function()
								callback()
							end, function(err)
								warn(errorMessage .. "\n\n" .. err)
							end)
						end

						if hapticFeedback and guiService:IsTenFootInterface() then
							createHapticFeedback()
						end
					end
				end
			end
		end
	end
end

-- Verifys that the plane which the object is going to be placed upon is the correct size
local function verifyPlane()	
	if plot.Size.X%GRID_UNIT == 0 and plot.Size.Z%GRID_UNIT == 0 then
		return true
	else
		return false
	end
end

-- Checks if there are any problems with the users setup
local function approveActivation()
	if not verifyPlane() then
		warn("The object that the model is moving on is not scaled correctly. Consider changing it.")
	end

	if GRID_UNIT > min(plot.Size.X, plot.Size.Z) then 
		error("Grid size is larger than the plot size. To fix this, try lowering the grid size.")
	end
end

-- Constructor function
function placement.new(g, objs, r, t, u, l, xbr, xbt, xbu, xbl)
	local data = {}
	local metaData = setmetatable(data, placement)

	-- Sets variables needed
	GRID_UNIT = abs(round(tonumber(g)))
	itemLocation = objs
	rotateKey = r
	terminateKey = t
	raiseKey = u
	lowerKey = l
	xboxRotate = xbr
	xboxTerminate = xbt
	xboxRaise = xbu
	xboxLower = xbl

	data.gridsize = GRID_UNIT
	data.items = objs
	data.rotate = rotateKey
	data.cancel = terminateKey
	data.raise = raiseKey
	data.lower = lowerKey
	data.XBOX_ROTATE = xboxRotate
	data.XBOX_TERMINATE = xboxTerminate
	data.XBOX_RAISE = xboxRaise
	data.XBOX_LOWER = xboxLower

	return data
end

-- returns the current state when called
function placement:getCurrentState()
	return states[currentState]
end

-- Pauses the current state
function placement:pauseCurrentState()
	lastState = currentState

	if object then
		currentState = 4

		print("Set state to: " .. states[currentState])
	end
end

-- Resumes the current state if paused
function placement:resume()
	if object then
		setCurrentState(lastState)
	end
end

-- Terminates placement
function placement:terminate()
	TERMINATE_PLACEMENT()
end

function placement:haltPlacement()
	if autoPlace then
		if running then
			running = false
		end
	end
end

function placement:editAttribute(attribute, input)
	if script:GetAttribute(attribute) ~= nil then
		script:SetAttribute(attribute, input)
		roundInts()
		updateAttributes()
	else
		warn("Attribute " .. attribute .. "does not exist.")
	end
end

-- Requests to place down the object
function placement:requestPlacement(func, cb) 
	if autoPlace then
		running = true

		repeat
			PLACEMENT(func, cb)

			wait(placementCooldown)
		until not running
	else
		PLACEMENT(func, cb)
	end
end

-- Activates placement
function placement:activate(id, pobj, plt, stk, r, a)
	TERMINATE_PLACEMENT()
	character = player.Character or player.CharacterAdded:Wait()

	-- Sets necessary variables for placement 
	plot = plt
	object = itemLocation:FindFirstChild(tostring(id)):Clone()
	placedObjects = pobj
	loc = itemLocation

	approveActivation()

	-- Sets properties of the model (CanCollide, Transparency)
	for i, o in pairs(object:GetDescendants()) do
		if o then
			if o:IsA("Part") or o:IsA("UnionOperation") or o:IsA("MeshPart") then
				o.CanCollide = false
				o.Anchored = true

				if transparentModel then
					o.Transparency = o.Transparency + transparencyDelta
				end
			end
		end
	end

	if includeSelectionBox then	
		displaySelectionBox()
	end

	if audibleFeedback then
		createAudioFeedback()
	end

	if displayGridTexture then
		displayGrid()
	end

	object.PrimaryPart.Transparency = hitboxTransparency

	stackable = stk
	smartRot = r

	-- Allows stackable objects depending on stk variable given by the user
	if not stk then
		mouse.TargetFilter = placedObjects
	else
		mouse.TargetFilter = object
	end

	-- Toggles buildmode placement (infinite placement) depending on if set true by the user
	if buildModePlacement then
		canActivate = true
	else
		canActivate = false
	end

	-- Gets the initial y pos and gives it to y
	initialY = calculateYPos(plt.Position.Y, plt.Size.Y, object.PrimaryPart.Size.Y)
	y = initialY

	speed = 0
	rot = 0
	currentRot = true
	autoPlace = a

	translateObj()
	editHitboxColor()
	bindInputs()
	roundInts()

	-- Sets up interpolation speed
	speed = 1

	if interpolation then
		preSpeed = clamp(abs(tonumber(1 - lerpSpeed)), 0, 0.9)

		if instantActivation then
			speed = 1
		else
			speed = preSpeed
		end
	end

	-- Parents the object to the location given
	if object then
		primary = object.PrimaryPart
		setCurrentState(1)
		object.Parent = pobj

		wait()

		speed = preSpeed
	else
		TERMINATE_PLACEMENT()

		warn("Your trying to activate placement too fast! Please slow down")
	end
end

runService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, translateObj)

return placement

-- Created and written by zblox164