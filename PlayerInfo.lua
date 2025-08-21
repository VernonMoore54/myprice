local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Настройки
local verticalOffset = -100
local textSize = 35

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerStatsGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Name = "StatsContainer"
container.BackgroundTransparency = 1
container.Size = UDim2.new(0, 0, 0, 0)
container.Position = UDim2.new(0.5, 0, 0.5, verticalOffset)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.AutomaticSize = Enum.AutomaticSize.XY
container.Parent = screenGui

-- Никнейм
local nicknameLabel = Instance.new("TextLabel")
nicknameLabel.Text = LocalPlayer.Name
nicknameLabel.TextColor3 = Color3.new(1, 1, 1)
nicknameLabel.TextSize = textSize
nicknameLabel.Font = Enum.Font.SourceSansBold
nicknameLabel.BackgroundTransparency = 1
nicknameLabel.TextStrokeTransparency = 0.5
nicknameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
nicknameLabel.Size = UDim2.new(0, 0, 0, 0)
nicknameLabel.AutomaticSize = Enum.AutomaticSize.XY
nicknameLabel.TextXAlignment = Enum.TextXAlignment.Center
nicknameLabel.Parent = container

-- Уровень
local levelLabel = Instance.new("TextLabel")
levelLabel.Text = "Lvl: 0"
levelLabel.TextColor3 = Color3.new(1, 1, 1)
levelLabel.TextSize = textSize * 0.8
levelLabel.Font = Enum.Font.SourceSans
levelLabel.BackgroundTransparency = 1
levelLabel.TextStrokeTransparency = 0.5
levelLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
levelLabel.Position = UDim2.new(0, 0, 0, nicknameLabel.AbsoluteSize.Y)
levelLabel.AutomaticSize = Enum.AutomaticSize.XY
levelLabel.TextXAlignment = Enum.TextXAlignment.Center
levelLabel.Parent = container

-- Опыт
local expLabel = Instance.new("TextLabel")
expLabel.Text = "Exp (must be loaded): 0/0"
expLabel.TextColor3 = Color3.new(1, 1, 1)
expLabel.TextSize = textSize * 0.8
expLabel.Font = Enum.Font.SourceSans
expLabel.BackgroundTransparency = 1
expLabel.TextStrokeTransparency = 0.5
expLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
expLabel.Position = UDim2.new(0, 0, 0, nicknameLabel.AbsoluteSize.Y + levelLabel.AbsoluteSize.Y)
expLabel.AutomaticSize = Enum.AutomaticSize.XY
expLabel.TextXAlignment = Enum.TextXAlignment.Center
expLabel.Parent = container

-- Прямое получение данных
local function getLevel()
    return LocalPlayer.PlayerStats.Level.Value
end

local function getExperience()
    return LocalPlayer.PlayerGui.HUD.Main.Frames.Character.ScrollingFrame.Experience.Frame.TextLabel.Text
end

-- Обновление данных
local function updateStats()
    pcall(function()
        levelLabel.Text = "Lvl: "..tostring(getLevel())
        expLabel.Text = "Exp (must be loaded): "..getExperience()
    end)
end

-- Автоматическое обновление
RunService.Heartbeat:Connect(updateStats)
updateStats()
