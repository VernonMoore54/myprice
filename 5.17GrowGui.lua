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
local seedsToPlant = {"Coconut", "Bamboo"}

-- Поиск места для посадки с атрибутом Side == "Right"
local plantLocations = MyFarm.Important.Plant_Locations
local canPlantRight
for _, obj in ipairs(plantLocations:GetChildren()) do
	if obj.Name == "Can_Plant" and obj:GetAttribute("Side") == "Right" then
		canPlantRight = obj
		break
	end
end
assert(canPlantRight, "Can_Plant с Side == 'Right' не найден")
local plantPosition = canPlantRight.Position

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
autoPlantBtn.Position = UDim2.new(0,20,0,80)
autoPlantBtn.Text = "AutoPlant 🌿"
autoPlantBtn.Font = Enum.Font.Code
autoPlantBtn.TextColor3 = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)

-- Buy page
local buy = Instance.new("Frame", Content)
buy.Size = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible = false
pages["buy"] = buy

local back = Instance.new("ImageButton", buy)
back.Size = UDim2.new(0,28,0,28)
back.Position = UDim2.new(0,10,0,10)
back.Image = "rbxassetid://4952231049"
back.BackgroundTransparency = 1
back.MouseButton1Click:Connect(function()
	switchPage("home")
end)

-- Drop list
local selected = {}
local drop = Instance.new("Frame", buy)
drop.Size = UDim2.new(0,280,0,100)
drop.Position = UDim2.new(0,20,0,60)
drop.BackgroundColor3 = Color3.fromRGB(25,25,45)

local scroll = Instance.new("ScrollingFrame", drop)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageTransparency = 0.4
scroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,150)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ClipsDescendants = true

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local sorted = {}
for name in pairs(SeedStock) do
	table.insert(sorted, name)
end
table.sort(sorted)

local label = Instance.new("TextLabel", buy)
label.Size = UDim2.new(0, 280, 0, 40)
label.Position = UDim2.new(0, 20, 0, 165)
label.Text = "Выбрано: "
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Left
label.BackgroundTransparency = 1

for _, name in ipairs(sorted) do
	local b = Instance.new("TextButton", scroll)
	b.Size = UDim2.new(1,0,0,30)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Code
	b.TextSize = 16
	b.MouseButton1Click:Connect(function()
		selected[name] = not selected[name]
		b.BackgroundColor3 = selected[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
		local s = {}; for k,v in pairs(selected) do if v then table.insert(s, k) end end
		label.Text = "Выбрано: " .. table.concat(s, ", ")
	end)
end
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)

-- Переключатель AutoBuy
local toggleFrame = Instance.new("Frame", buy)
toggleFrame.Size = UDim2.new(0,280,0,60)
toggleFrame.Position = UDim2.new(0,20,0,210)
toggleFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)

local toggle = Instance.new("TextButton", toggleFrame)
toggle.Size = UDim2.new(0,60,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Font = Enum.Font.Code
toggle.TextSize = 24
toggle.Text = "?"
toggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
toggle.TextColor3 = Color3.new(1,1,1)

local toggleLabel = Instance.new("TextLabel", toggleFrame)
toggleLabel.Size = UDim2.new(1, -80, 0, 40)
toggleLabel.Position = UDim2.new(0, 80, 0, 10)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "AutoBuy toggle 😋"
toggleLabel.TextColor3 = Color3.new(1,1,1)
toggleLabel.Font = Enum.Font.Code
toggleLabel.TextSize = 16
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка очистки выбранных семян
local clearBtn = Instance.new("TextButton", toggleFrame)
clearBtn.Size = UDim2.new(0, 40, 0, 40)
clearBtn.Position = UDim2.new(1, -45, 0, 10)
clearBtn.Text = "X"
clearBtn.TextColor3 = Color3.new(1, 0.6, 0.6)
clearBtn.Font = Enum.Font.Code
clearBtn.TextSize = 18
clearBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
clearBtn.BorderSizePixel = 0

clearBtn.MouseButton1Click:Connect(function()
	for name in pairs(selected) do
		selected[name] = false
	end
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = Color3.fromRGB(35,35,55)
		end
	end
	label.Text = "Выбрано: "
end)

-- Обновление текста выбранных семян
local function updateSelectedText()
	local s = {}; for k,v in pairs(selected) do if v then table.insert(s, k) end end
	local text = table.concat(s, ", ")
	label.Text = "Выбрано: " .. text
	label.TextScaled = false
	label.TextSize = 14
	label.TextWrapped = true
	if label.TextBounds.X > label.AbsoluteSize.X then
		label.TextScaled = true
	end
end

local enabled = false
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "👍" or "?"
end)

spawn(function()
	while true do
		wait(1)
		if not enabled then continue end
		for seed in pairs(selected) do
			if selected[seed] then
				GameEvents.BuySeedStock:FireServer(seed)
			end
		end
	end
end)

autoBuyBtn.MouseButton1Click:Connect(function()
	switchPage("buy")
end)

-- Auto Plant page
local autoPlant = Instance.new("Frame", Content)
autoPlant.Size = UDim2.new(1,0,1,0)
autoPlant.BackgroundTransparency = 1
autoPlant.Visible = false
pages["autoPlant"] = autoPlant

local backAutoPlant = Instance.new("ImageButton", autoPlant)
backAutoPlant.Size = UDim2.new(0,28,0,28)
backAutoPlant.Position = UDim2.new(0,10,0,10)
backAutoPlant.Image = "rbxassetid://4952231049"
backAutoPlant.BackgroundTransparency = 1
backAutoPlant.MouseButton1Click:Connect(function()
	switchPage("home")
end)

local toggleFrameAP = Instance.new("Frame", autoPlant)
toggleFrameAP.Size = UDim2.new(0,280,0,60)
toggleFrameAP.Position = UDim2.new(0,20,0,60)
toggleFrameAP.BackgroundColor3 = Color3.fromRGB(25,25,45)

local toggleAP = Instance.new("TextButton", toggleFrameAP)
toggleAP.Size = UDim2.new(0,60,0,40)
toggleAP.Position = UDim2.new(0,10,0,10)
toggleAP.Font = Enum.Font.Code
toggleAP.TextSize = 24
toggleAP.Text = "?"
toggleAP.BackgroundColor3 = Color3.fromRGB(35,35,55)
toggleAP.TextColor3 = Color3.new(1,1,1)

local toggleLabelAP = Instance.new("TextLabel", toggleFrameAP)
toggleLabelAP.Size = UDim2.new(1, -80, 0, 40)
toggleLabelAP.Position = UDim2.new(0, 80, 0, 10)
toggleLabelAP.BackgroundTransparency = 1
toggleLabelAP.Text = "AutoPlant toggle 🌿"
toggleLabelAP.TextColor3 = Color3.new(1,1,1)
toggleLabelAP.Font = Enum.Font.Code
toggleLabelAP.TextSize = 16
toggleLabelAP.TextXAlignment = Enum.TextXAlignment.Left

local autoPlantEnabled = false
toggleAP.MouseButton1Click:Connect(function()
	autoPlantEnabled = not autoPlantEnabled
	toggleAP.Text = autoPlantEnabled and "👍" or "?"
end)

autoPlantBtn.MouseButton1Click:Connect(function()
	switchPage("autoPlant")
end)

switchPage("home")

-- Логика автопосадки
spawn(function()
	while true do
		wait(0.5)
		if not autoPlantEnabled then continue end
		for _, seed in ipairs(seedsToPlant) do
			local toolName = seed .. " Seed"
			local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
			if tool then
				tool.Parent = LocalPlayer.Character
				wait(0.1) -- Небольшая задержка для экипировки
				local args = {plantPosition, seed}
				GameEvents.Plant_RE:FireServer(unpack(args))
				break
			end
		end
	end
end)
