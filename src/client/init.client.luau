local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local function requireModule(path)
	return require(Shared:WaitForChild(path))
end

requireModule("Hello")()

-- UI Components
task.spawn(function()
	require(script.Parent.UI.SprintButton)
end)
