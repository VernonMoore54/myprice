--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SeedDataModule = ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData")

-- Получение данных семян
local SeedData = require(SeedDataModule)
local SeedStock = {} -- Названия семян, DisplayInShop = true
for key, data in pairs(SeedData) do
	if data.DisplayInShop then
		SeedStock[key] = true
	end
end

-- Удаление старого GUI
local old = PlayerGui:FindFirstChild("WaveGui")
if old then old:Destroy() end

-- Поиск фермы игрока
local MyFarm = (function()
	local Farms = workspace:WaitForChild("Farm")
	for _, farm in ipairs(Farms:GetChildren()) do
		local owner = farm:FindFirstChild("Important") and farm.Important.Data.Owner
		if owner and owner.Value == LocalPlayer.Name then
			return farm
		end
	end
end)()
assert(MyFarm, "Ферма не найдена")

-- Конфигурация семян для автопосадки
local AutoPlantSeeds = {
	"Coconut",
	"Bamboo"
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "WaveGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0, -320, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local bg = Instance.new("ImageLabel", MainFrame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Image = "rbxassetid://70998571392678"
bg.BackgroundTransparency = 1
bg.ImageTransparency = 0.2
bg.ScaleType = Enum.ScaleType.Crop
bg.ZIndex = 0

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.Text = "🌱 Wave Garden"
Header.TextColor3 = Color3.new(1,1,1)
Header.Font = Enum.Font.Code
Header.TextSize = 18
Header.ZIndex = 1

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1,0,1,-40)
Content.Position = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1
Content.ZIndex = 1

local LeftArrow = Instance.new("TextButton", ScreenGui)
LeftArrow.Size = UDim2.new(0, 24, 0, 50)
LeftArrow.Position = UDim2.new(0, 0, 0.5, -25)
LeftArrow.Text = "▶"
LeftArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LeftArrow.TextColor3 = Color3.new(0.8, 0.8, 1)
LeftArrow.Font = Enum.Font.Code
LeftArrow.TextSize = 20

local RightArrow = Instance.new("TextButton", MainFrame)
RightArrow.Size = UDim2.new(0, 24, 0, 50)
RightArrow.Position = UDim2.new(1, -24, 0.5, -25)
RightArrow.Text = "◀"
RightArrow.Visible = false
RightArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
RightArrow.TextColor3 = Color3.new(0.8, 0.8, 1)
RightArrow.Font = Enum.Font.Code
RightArrow.TextSize = 20

local isOpen = false
local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.35), {Position = UDim2.new(0, 0, 0.5, -200)})
local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.35), {Position = UDim2.new(0, -320, 0.5, -200)})

LeftArrow.MouseButton1Click:Connect(function()
	openTween:Play()
	LeftArrow.Visible = false
	RightArrow.Visible = true
end)
RightArrow.MouseButton1Click:Connect(function()
	closeTween:Play()
	LeftArrow.Visible = true
	RightArrow.Visible = false
end)

local pages = {}
local current = nil
local function switchPage(name)
	if current then pages[current].Visible = false end
	pages[name].Visible = true
	current = name
end

-- Home page
local home = Instance.new("Frame", Content)
home.Size = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pages["home"] = home

local autoBuyBtn = Instance.new("TextButton", home)
autoBuyBtn.Size = UDim2.new(0,280,0,50)
autoBuyBtn.Position = UDim2.new(0,20,0,20)
autoBuyBtn.Text = "AutoBuySeeds 🌱"
autoBuyBtn.Font = Enum.Font.Code
autoBuyBtn.TextColor3 = Color3.new(1,1,1)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)

local autoPlantBtn = Instance.new("TextButton", home)
autoPlantBtn.Size = UDim2.new(0,280,0,50)
autoPlantBtn.Position = UDim2.new(0,20,0,90)
autoPlantBtn.Text = "AutoPlantSeeds 🌾"
autoPlantBtn.Font = Enum.Font.Code
autoPlantBtn.TextColor3 = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)

-- AutoPlant page
local autoPlantPage = Instance.new("Frame", Content)
autoPlantPage.Size = UDim2.new(1,0,1,0)
autoPlantPage.BackgroundTransparency = 1
autoPlantPage.Visible = false
pages["autoplant"] = autoPlantPage

local backBtn = Instance.new("ImageButton", autoPlantPage)
backBtn.Size = UDim2.new(0,28,0,28)
backBtn.Position = UDim2.new(0,10,0,10)
backBtn.Image = "rbxassetid://4952231049"
backBtn.BackgroundTransparency = 1
backBtn.MouseButton1Click:Connect(function()
	switchPage("home")
end)

local autoPlantToggle = Instance.new("TextButton", autoPlantPage)
autoPlantToggle.Size = UDim2.new(0, 280, 0, 50)
autoPlantToggle.Position = UDim2.new(0, 20, 0, 60)
autoPlantToggle.Font = Enum.Font.Code
autoPlantToggle.TextSize = 22
autoPlantToggle.Text = "Enable AutoPlant?"
autoPlantToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
autoPlantToggle.TextColor3 = Color3.new(1, 1, 1)

local plantEnabled = false
autoPlantToggle.MouseButton1Click:Connect(function()
	plantEnabled = not plantEnabled
	autoPlantToggle.Text = plantEnabled and "AutoPlant: ON 🌿" or "AutoPlant: OFF"
end)

autoPlantBtn.MouseButton1Click:Connect(function()
	switchPage("autoplant")
end)

-- Поиск позиций для посадки
local function getRightPlantLocations()
	local locations = {}
	local nodes = MyFarm:WaitForChild("Important"):WaitForChild("Plant_Locations"):WaitForChild("Can_Plant")
	for _, loc in ipairs(nodes:GetChildren()) do
		if loc:GetAttribute("Side") == "Right" then
			table.insert(locations, loc.Position)
		end
	end
	return locations
end

-- Автоматическая посадка семян
spawn(function()
	while true do
		task.wait(0.5)
		if not plantEnabled then continue end
		for _, seedName in ipairs(AutoPlantSeeds) do
			local toolName = seedName .. " Seed"
			local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
			if tool then
				tool.Parent = LocalPlayer.Character
			end
			for _, pos in ipairs(getRightPlantLocations()) do
				local args = {
					Vector3.new(pos.X, pos.Y, pos.Z),
					seedName
				}
				GameEvents:WaitForChild("Plant_RE"):FireServer(unpack(args))
			end
		end
	end
end)

-- Запуск начальной страницы
switchPage("home")
