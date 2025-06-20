--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Удаление предыдущего GUI
local Old = LocalPlayer.PlayerGui:FindFirstChild("WaveGui")
if Old then Old:Destroy() end

--// Новый GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "WaveGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

--// Окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0, -320, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

--// Хедер
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.Text = "🌱 Wave Garden Menu"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.Code
Header.TextSize = 18
Header.BorderSizePixel = 0

--// Контент
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -40)
Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

--// Левая кнопка (открыть)
local LeftArrow = Instance.new("TextButton", ScreenGui)
LeftArrow.Size = UDim2.new(0, 24, 0, 50)
LeftArrow.Position = UDim2.new(0, 0, 0.5, -25)
LeftArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LeftArrow.Text = "▶"
LeftArrow.TextColor3 = Color3.fromRGB(200, 200, 255)
LeftArrow.Font = Enum.Font.Code
LeftArrow.TextSize = 20
LeftArrow.BorderSizePixel = 0
LeftArrow.Visible = true

--// Правая кнопка (закрыть)
local RightArrow = Instance.new("TextButton", MainFrame)
RightArrow.Size = UDim2.new(0, 24, 0, 50)
RightArrow.Position = UDim2.new(1, -24, 0.5, -25)
RightArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
RightArrow.Text = "◀"
RightArrow.TextColor3 = Color3.fromRGB(200, 200, 255)
RightArrow.Font = Enum.Font.Code
RightArrow.TextSize = 20
RightArrow.BorderSizePixel = 0
RightArrow.Visible = false

--// Анимация
local IsOpen = false
local OpenTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
	Position = UDim2.new(0, 0, 0.5, -200)
})
local CloseTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
	Position = UDim2.new(0, -320, 0.5, -200)
})

LeftArrow.MouseButton1Click:Connect(function()
	IsOpen = true
	OpenTween:Play()
	LeftArrow.Visible = false
	RightArrow.Visible = true
end)

RightArrow.MouseButton1Click:Connect(function()
	IsOpen = false
	CloseTween:Play()
	LeftArrow.Visible = true
	RightArrow.Visible = false
end)
