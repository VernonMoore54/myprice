--// UI Loader
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "WaveGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

--// Toggle Button
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 40, 0, 120)
ToggleButton.Position = UDim2.new(0, 0, 0.5, -60)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToggleButton.Text = "⮞"
ToggleButton.TextColor3 = Color3.fromRGB(200, 200, 255)
ToggleButton.Font = Enum.Font.Code
ToggleButton.TextSize = 20
ToggleButton.BorderSizePixel = 0

--// Main Panel
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0, -320, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

--// Header
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.Text = "🌱 Wave Garden Menu"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.Code
Header.TextSize = 18
Header.BorderSizePixel = 0

--// Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

--// Toggle Logic
local IsOpen = false
local OpenTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
	Position = UDim2.new(0, 0, 0.5, -200)
})
local CloseTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
	Position = UDim2.new(0, -320, 0.5, -200)
})

ToggleButton.MouseButton1Click:Connect(function()
	IsOpen = not IsOpen
	ToggleButton.Text = IsOpen and "⮜" or "⮞"
	if IsOpen then
		OpenTween:Play()
	else
		CloseTween:Play()
	end
end)
