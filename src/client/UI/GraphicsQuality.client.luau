local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local player = Players.LocalPlayer

local QUALITY_LEVELS = {
	{
		key = "Low",
		label = "LOW",
		desc = "Best Performance",
		icon = "🔋",
		qualityEnum = Enum.QualityLevel.Level01,
	},
	{
		key = "Medium",
		label = "MEDIUM",
		desc = "Balanced",
		icon = "⚡",
		qualityEnum = Enum.QualityLevel.Level05,
	},
	{
		key = "High",
		label = "HIGH",
		desc = "Best Quality",
		icon = "✨",
		qualityEnum = Enum.QualityLevel.Level10,
	},
}

local function applyGraphicsQuality(qualityEnum)
	if qualityEnum == Enum.QualityLevel.Level01 then
		Lighting.GlobalShadows = false
		if Terrain then
			Terrain.Decoration = false
			Terrain.WaterWaveSize = 0
			Terrain.WaterReflectance = 0
		end
	elseif qualityEnum == Enum.QualityLevel.Level05 then
		Lighting.GlobalShadows = true
		if Terrain then
			Terrain.Decoration = false
			Terrain.WaterWaveSize = 0.5
			Terrain.WaterReflectance = 0.5
		end
	elseif qualityEnum == Enum.QualityLevel.Level10 then
		Lighting.GlobalShadows = true
		if Terrain then
			Terrain.Decoration = true
			Terrain.WaterWaveSize = 1
			Terrain.WaterReflectance = 1
		end
	end
end

local function createPopup()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GraphicsQualityUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Parent = screenGui

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.6, 0)
	card.Size = UDim2.new(0, 420, 0, 0)
	card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	card.BackgroundTransparency = 0.75
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = overlay

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 28)

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = Color3.fromRGB(255, 255, 255)
	cardStroke.Transparency = 0.5
	cardStroke.Thickness = 1.5
	cardStroke.Parent = card

	local cardGradient = Instance.new("UIGradient")
	cardGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 255)),
	})
	cardGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0.85),
	})
	cardGradient.Rotation = 135
	cardGradient.Parent = card

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 38)
	title.Position = UDim2.new(0, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.Text = "Graphics Quality"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.Parent = card

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0, 20)
	subtitle.Position = UDim2.new(0, 0, 0, 62)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Choose your preferred quality level"
	subtitle.TextColor3 = Color3.fromRGB(220, 220, 255)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 13
	subtitle.Parent = card

	local buttonContainer = Instance.new("Frame")
	buttonContainer.AnchorPoint = Vector2.new(0.5, 0)
	buttonContainer.Position = UDim2.new(0.5, 0, 0, 104)
	buttonContainer.Size = UDim2.new(1, -48, 0, 110)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = card

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 12)
	listLayout.Parent = buttonContainer

	local selectedButton = nil
	local allButtons = {}

	local function deselectAll()
		for _, btn in ipairs(allButtons) do
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.75,
			}):Play()
			local s = btn:FindFirstChildOfClass("UIStroke")
			if s then
				TweenService:Create(s, TweenInfo.new(0.2), {
					Color = Color3.fromRGB(255, 255, 255),
					Transparency = 0.6,
				}):Play()
			end
		end
	end

	local function createQualityButton(data)
		local btn = Instance.new("TextButton")
		btn.Name = data.key
		btn.Size = UDim2.new(0, 100, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btn.BackgroundTransparency = 0.75
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = buttonContainer

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(255, 255, 255)
		btnStroke.Transparency = 0.6
		btnStroke.Thickness = 1.2
		btnStroke.Parent = btn

		local btnGradient = Instance.new("UIGradient")
		btnGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 210, 255)),
		})
		btnGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.65),
			NumberSequenceKeypoint.new(1, 0.8),
		})
		btnGradient.Rotation = 135
		btnGradient.Parent = btn

		local innerLayout = Instance.new("UIListLayout")
		innerLayout.FillDirection = Enum.FillDirection.Vertical
		innerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		innerLayout.Padding = UDim.new(0, 4)
		innerLayout.Parent = btn

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(1, 0, 0, 28)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Text = data.icon
		iconLabel.TextSize = 22
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		iconLabel.Parent = btn

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 18)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = data.label
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 12
		nameLabel.Parent = btn

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -8, 0, 14)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = data.desc
		descLabel.TextColor3 = Color3.fromRGB(200, 210, 255)
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 9
		descLabel.TextWrapped = true
		descLabel.Parent = btn

		table.insert(allButtons, btn)

		btn.MouseEnter:Connect(function()
			if selectedButton ~= btn then
				TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.6 }):Play()
			end
		end)

		btn.MouseLeave:Connect(function()
			if selectedButton ~= btn then
				TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.75 }):Play()
			end
		end)

		btn.MouseButton1Click:Connect(function()
			selectedButton = btn
			deselectAll()

			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(140, 160, 255),
				BackgroundTransparency = 0.35,
			}):Play()
			TweenService:Create(btnStroke, TweenInfo.new(0.2), {
				Color = Color3.fromRGB(180, 200, 255),
				Transparency = 0.1,
			}):Play()

			applyGraphicsQuality(data.qualityEnum)
		end)
	end

	for _, data in ipairs(QUALITY_LEVELS) do
		createQualityButton(data)
	end

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.AnchorPoint = Vector2.new(0.5, 0)
	confirmBtn.Position = UDim2.new(0.5, 0, 0, 234)
	confirmBtn.Size = UDim2.new(1, -48, 0, 46)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(120, 150, 255)
	confirmBtn.BackgroundTransparency = 0.3
	confirmBtn.Text = "Continue"
	confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.TextSize = 15
	confirmBtn.AutoButtonColor = false
	confirmBtn.Parent = card

	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 14)

	local confirmStroke = Instance.new("UIStroke")
	confirmStroke.Color = Color3.fromRGB(180, 200, 255)
	confirmStroke.Transparency = 0.4
	confirmStroke.Thickness = 1.2
	confirmStroke.Parent = confirmBtn

	local confirmGradient = Instance.new("UIGradient")
	confirmGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 130, 255)),
	})
	confirmGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.4),
	})
	confirmGradient.Rotation = 135
	confirmGradient.Parent = confirmBtn

	confirmBtn.MouseEnter:Connect(function()
		TweenService:Create(confirmBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
	end)
	confirmBtn.MouseLeave:Connect(function()
		TweenService:Create(confirmBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.3 }):Play()
	end)

	local function closePopup()
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 420, 0, 0),
			Position = UDim2.new(0.5, 0, 0.6, 0),
		}):Play()
		TweenService:Create(overlay, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
		task.delay(0.4, function()
			screenGui:Destroy()
		end)
	end

	confirmBtn.MouseButton1Click:Connect(closePopup)

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = card

	local function updateResponsive()
		local vp = workspace.CurrentCamera.ViewportSize
		local scale = math.clamp(vp.X / 1280, 0.55, 1)
		uiScale.Scale = scale
	end

	updateResponsive()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()
	TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 420, 0, 320),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}):Play()
end

createPopup()
