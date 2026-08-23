local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 15
local CARRY_DISTANCE = 5.5
local CARRY_HEIGHT_OFFSET = -0.3 -- Posisi lebih rendah di depan badan (terasa berat)

local CARRY_WALK_SPEED_MULTIPLIER = 0.7 -- Gerakan lebih lambat saat membawa

local heldPart = nil
local alignPosition = nil
local alignOrientation = nil
local attachment0 = nil
local noCollisionConstraints = {}
local isHovering = false
local originalWalkSpeed = 16

local HEAVY_PHYSICAL_PROPERTIES = PhysicalProperties.new(
	3.5, -- Density tinggi (berat)
	0.9, -- Friction tinggi
	0.0, -- Elasticity 0 (tidak memantul)
	1.0,
	1.0
)

local function isPickupable(part)
	return part and part.Name == "box" and part:IsA("BasePart")
end

local function applyHeavyPhysics(part)
	part.CustomPhysicalProperties = HEAVY_PHYSICAL_PROPERTIES
end

local function createPromptUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PickupPromptUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Name = "PromptFrame"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.65, 0)
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BackgroundTransparency = 0.7
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Visible = false
	frame.Parent = screenGui

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.4
	stroke.Thickness = 1.2
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 255)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	gradient.Rotation = 135
	gradient.Parent = frame

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "KeyLabel"
	keyLabel.Size = UDim2.new(0, 36, 0, 36)
	keyLabel.Position = UDim2.new(0, 12, 0.5, -18)
	keyLabel.BackgroundColor3 = Color3.fromRGB(140, 160, 255)
	keyLabel.BackgroundTransparency = 0.3
	keyLabel.Text = "E"
	keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = 18
	keyLabel.Parent = frame

	Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 10)

	local keyStroke = Instance.new("UIStroke")
	keyStroke.Color = Color3.fromRGB(180, 200, 255)
	keyStroke.Transparency = 0.3
	keyStroke.Thickness = 1
	keyStroke.Parent = keyLabel

	local actionLabel = Instance.new("TextLabel")
	actionLabel.Name = "ActionLabel"
	actionLabel.Size = UDim2.new(1, -60, 1, 0)
	actionLabel.Position = UDim2.new(0, 54, 0, 0)
	actionLabel.BackgroundTransparency = 1
	actionLabel.Text = "Pick Up"
	actionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionLabel.Font = Enum.Font.GothamBold
	actionLabel.TextSize = 14
	actionLabel.TextXAlignment = Enum.TextXAlignment.Left
	actionLabel.Parent = frame

	return screenGui, frame, actionLabel
end

local screenGui, promptFrame, actionLabel = createPromptUI()

local function showPrompt(text)
	actionLabel.Text = text
	promptFrame.Visible = true
	TweenService:Create(promptFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 160, 0, 50),
	}):Play()
end

local function hidePrompt()
	local tween = TweenService:Create(promptFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
	})
	tween:Play()
	tween.Completed:Connect(function()
		if not isHovering then
			promptFrame.Visible = false
		end
	end)
end

local function getTargetFromCrosshair()
	local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local ray = camera:ViewportPointToRay(screenCenter.X, screenCenter.Y)

	local character = player.Character
	if not character then return nil end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * MAX_DISTANCE, params)
	if result and isPickupable(result.Instance) then
		return result.Instance
	end
	return nil
end

local function disableCharacterCollision(part, character)
	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BasePart") then
			local ncc = Instance.new("NoCollisionConstraint")
			ncc.Part0 = part
			ncc.Part1 = desc
			ncc.Parent = part
			table.insert(noCollisionConstraints, ncc)
		end
	end
end

local function clearNoCollisionConstraints()
	for _, ncc in ipairs(noCollisionConstraints) do
		if ncc then
			ncc:Destroy()
		end
	end
	table.clear(noCollisionConstraints)
end

local function pickUp(part)
	heldPart = part
	applyHeavyPhysics(heldPart)

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		originalWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = originalWalkSpeed * CARRY_WALK_SPEED_MULTIPLIER
	end

	disableCharacterCollision(heldPart, character)

	attachment0 = Instance.new("Attachment")
	attachment0.Name = "CarryAttachment0"
	attachment0.Parent = heldPart

	-- Responsiveness rendah (12) + MaxVelocity terkontrol = ada delay / inersia berat
	alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment0
	alignPosition.MaxForce = 35000
	alignPosition.Responsiveness = 12
	alignPosition.MaxVelocity = 22
	alignPosition.Parent = heldPart

	-- Responsiveness rotasi lebih lambat (8) = rotasi tertinggal perlahan
	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment0
	alignOrientation.MaxTorque = 35000
	alignOrientation.Responsiveness = 8
	alignOrientation.MaxAngularVelocity = 15
	alignOrientation.Parent = heldPart
end

local function drop()
	clearNoCollisionConstraints()

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = originalWalkSpeed
		end
	end

	if alignPosition then
		alignPosition:Destroy()
		alignPosition = nil
	end
	if alignOrientation then
		alignOrientation:Destroy()
		alignOrientation = nil
	end
	if attachment0 then
		attachment0:Destroy()
		attachment0 = nil
	end
	if heldPart then
		applyHeavyPhysics(heldPart)
		heldPart = nil
	end
	isHovering = false
	hidePrompt()
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode ~= Enum.KeyCode.E then return end

	if heldPart then
		drop()
		return
	end

	local target = getTargetFromCrosshair()
	if target then
		pickUp(target)
	end
end)

local currentSag = 0

RunService.RenderStepped:Connect(function(dt)
	if heldPart and alignPosition and alignOrientation then
		local character = player.Character
		if not character then
			drop()
			return
		end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			drop()
			return
		end

		-- Hitung kecepatan gerak untuk menambah efek berat kebawah saat jalan/lari
		local moveVelocity = rootPart.AssemblyLinearVelocity
		local speed = Vector3.new(moveVelocity.X, 0, moveVelocity.Z).Magnitude
		local targetSag = math.clamp(speed / 16 * 0.4, 0, 0.6)
		currentSag = currentSag + (targetSag - currentSag) * math.clamp(dt * 8, 0, 1)

		local lookDir = camera.CFrame.LookVector
		local targetPos = rootPart.Position 
			+ lookDir * CARRY_DISTANCE 
			+ Vector3.new(0, CARRY_HEIGHT_OFFSET - currentSag, 0)

		alignPosition.Position = targetPos
		alignOrientation.CFrame = camera.CFrame
	end

	local target = getTargetFromCrosshair()

	if target then
		if not isHovering then
			isHovering = true
			if heldPart and target == heldPart then
				showPrompt("Drop")
			elseif not heldPart then
				showPrompt("Pick Up")
			end
		end
	else
		if isHovering then
			isHovering = false
			hidePrompt()
		end
	end
end)
