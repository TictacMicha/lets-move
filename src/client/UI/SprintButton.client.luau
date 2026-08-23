local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local sprintSpeed = 32
local isSprinting = false
local originalWalkSpeed = 16

local function waitForPlayer()
	local player = Players.LocalPlayer
	if player then return player end
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	return Players.LocalPlayer
end

local function createLiquidGlassButton(screenGui)
	local button = Instance.new("TextButton")
	button.Name = "SprintButton"
	button.Text = "SPRINT"
	button.Size = UDim2.new(0, 100, 0, 100)
	button.Position = UDim2.new(0.8, 0, 0.7, 0)
	button.BackgroundTransparency = 0.7
	button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Active = true
	button.Parent = screenGui
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.3
	stroke.Parent = button
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button
	
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 0.8)
	})
	gradient.Rotation = 45
	gradient.Parent = button
	
	return button, stroke, gradient
end

local function createSprintScreenGui(player)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SprintUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	return screenGui
end

local function createPulseAnimation(button)
	local tweenInfo = TweenInfo.new(
		0.8,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut,
		-1,
		true
	)
	
	local tween = TweenService:Create(button, tweenInfo, {
		BackgroundTransparency = 0.6
	})
	
	tween:Play()
	return tween
end

local function handleDrag(button)
	local dragging = false
	local dragStart = nil
	local buttonStart = nil
	
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			buttonStart = button.Position
			
			local tween = TweenService:Create(button, TweenInfo.new(0.1), {
				BackgroundTransparency = 0.5,
				Size = UDim2.new(0, 95, 0, 95)
			})
			tween:Play()
		end
	end)
	
	local dragConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			button.Position = UDim2.new(
				buttonStart.X.Scale,
				buttonStart.X.Offset + delta.X,
				buttonStart.Y.Scale,
				buttonStart.Y.Offset + delta.Y
			)
		end
	end)
	
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			dragConnection:Disconnect()
			
			local tween = TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.7,
				Size = UDim2.new(0, 100, 0, 100)
			})
			tween:Play()
		end
	end)
	
	button.AncestryChanged:Connect(function()
		if not button:IsDescendantOf(game) then
			dragConnection:Disconnect()
		end
	end)
end

local function setupSprintButton()
	local player = waitForPlayer()
	local screenGui = createSprintScreenGui(player)
	local button, stroke, gradient = createLiquidGlassButton(screenGui)
	
	createPulseAnimation(button)
	handleDrag(button)
	
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	originalWalkSpeed = humanoid.WalkSpeed
	
	button.MouseButton1Click:Connect(function()
		isSprinting = not isSprinting
		
		if isSprinting then
			humanoid.WalkSpeed = sprintSpeed
			
			local colorTween = TweenService:Create(button, TweenInfo.new(0.3), {
				BackgroundColor3 = Color3.fromRGB(255, 100, 100),
				BackgroundTransparency = 0.4
			})
			colorTween:Play()
			
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 150)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))
			})
			
			stroke.Color = Color3.fromRGB(255, 150, 150)
			button.Text = "STOP"
		else
			humanoid.WalkSpeed = originalWalkSpeed
			
			local colorTween = TweenService:Create(button, TweenInfo.new(0.3), {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.7
			})
			colorTween:Play()
			
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
			})
			
			stroke.Color = Color3.fromRGB(255, 255, 255)
			button.Text = "SPRINT"
		end
	end)
	
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if not isSprinting then
			originalWalkSpeed = humanoid.WalkSpeed
		end
	end)
	
	player.CharacterAdded:Connect(function(newChar)
		character = newChar
		humanoid = character:WaitForChild("Humanoid")
		originalWalkSpeed = humanoid.WalkSpeed
		
		if isSprinting then
			humanoid.WalkSpeed = sprintSpeed
		end
	end)
end

setupSprintButton()