--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SeedDataModule = ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData")
local Backpack = LocalPlayer:WaitForChild("Backpack")

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

--// Функции для работы с семенами (адаптировано из autofarm.lua)
local OwnedSeeds = {}

local function GetSeedInfo(Seed: Tool)
	local PlantName = Seed:FindFirstChild("Plant_Name")
	local Count = Seed:FindFirstChild("Numbers")
	if not PlantName then return end
	return PlantName.Value, Count.Value
end

local function CollectSeedsFromParent(Parent, Seeds: table)
	for _, Tool in next, Parent:GetChildren() do
		local Name, Count = GetSeedInfo(Tool)
		if not Name then continue end
		Seeds[Name] = {
			Count = Count,
			Tool = Tool
		}
	end
end

local function GetOwnedSeeds(): table
	OwnedSeeds = {}
	local Character = LocalPlayer.Character
	if Character then
		CollectSeedsFromParent(Backpack, OwnedSeeds)
		CollectSeedsFromParent(Character, OwnedSeeds)
	end
	return OwnedSeeds
end

local function GetArea(Base: BasePart)
	local Center = Base:GetPivot()
	local Size = Base.Size
	local X1 = math.ceil(Center.X - (Size.X/2))
	local Z1 = math.ceil(Center.Z - (Size.Z/2))
	local X2 = math.floor(Center.X + (Size.X/2))
	local Z2 = math.floor(Center.Z + (Size.Z/2))
	return X1, Z1, X2, Z2
end

local function EquipCheck(Tool)
	local Character = LocalPlayer.Character
	if not Character then return false end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return false end
	if Tool.Parent ~= Backpack then return true end
	Humanoid:EquipTool(Tool)
	return true
end

local MyImportant = MyFarm:FindFirstChild("Important")
local PlantLocations = MyImportant and MyImportant:FindFirstChild("Plant_Locations")
local Dirt = PlantLocations and PlantLocations:FindFirstChildOfClass("Part")
local X1, Z1, X2, Z2 = Dirt and GetArea(Dirt) or nil, nil, nil, nil

local function GetRandomFarmPoint(): Vector3?
	if not Dirt then return nil end
	local X = math.random(X1, X2)
	local Z = math.random(Z1, Z2)
	return Vector3.new(X, 4, Z)
end

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
autoPlantBtn.Text = "AutoPlantSeeds 🌱"
autoPlantBtn.Font = Enum.Font.Code
autoPlantBtn.TextColor3 = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)

-- Buy page
local buy = Instance.new("Frame", Content)
buy.Size = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible = false
pages["buy"] = buy

local backBuy = Instance.new("ImageButton", buy)
backBuy.Size = UDim2.new(0,28,0,28)
backBuy.Position = UDim2.new(0,10,0,10)
backBuy.Image = "rbxassetid://4952231049"
backBuy.BackgroundTransparency = 1
backBuy.MouseButton1Click:Connect(function()
	switchPage("home")
end)

-- Buy drop list
local selectedBuy = {}
local dropBuy = Instance.new("Frame", buy)
dropBuy.Size = UDim2.new(0,280,0,100)
dropBuy.Position = UDim2.new(0,20,0,60)
dropBuy.BackgroundColor3 = Color3.fromRGB(25,25,45)

local scrollBuy = Instance.new("ScrollingFrame", dropBuy)
scrollBuy.Size = UDim2.new(1,0,1,0)
scrollBuy.CanvasSize = UDim2.new(0,0,0,0)
scrollBuy.BackgroundTransparency = 1
scrollBuy.ScrollBarThickness = 6
scrollBuy.ScrollBarImageTransparency = 0.4
scrollBuy.ScrollBarImageColor3 = Color3.fromRGB(100,100,150)
scrollBuy.ScrollingDirection = Enum.ScrollingDirection.Y
scrollBuy.ClipsDescendants = true

local layoutBuy = Instance.new("UIListLayout", scrollBuy)
layoutBuy.SortOrder = Enum.SortOrder.LayoutOrder

-- Plant page
local plant = Instance.new("Frame", Content)
plant.Size = UDim2.new(1,0,1,0)
plant.BackgroundTransparency = 1
plant.Visible = false
pages["plant"] = plant

local backPlant = Instance.new("ImageButton", plant)
backPlant.Size = UDim2.new(0,28,0,28)
backPlant.Position = UDim2.new(0,10,0,10)
backPlant.Image = "rbxassetid://4952231049"
backPlant.BackgroundTransparency = 1
backPlant.MouseButton1Click:Connect(function()
	switchPage("home")
end)

-- Plant drop list
local selectedPlant = {}
local dropPlant = Instance.new("Frame", plant)
dropPlant.Size = UDim2.new(0,280,0,100)
dropPlant.Position = UDim2.new(0,20,0,60)
dropPlant.BackgroundColor3 = Color3.fromRGB(25,25,45)

local scrollPlant = Instance.new("ScrollingFrame", dropPlant)
scrollPlant.Size = UDim2.new(1,0,1,0)
scrollPlant.CanvasSize = UDim2.new(0,0,0,0)
scrollPlant.BackgroundTransparency = 1
scrollPlant.ScrollBarThickness = 6
scrollPlant.ScrollBarImageTransparency = 0.4
scrollPlant.ScrollBarImageColor3 = Color3.fromRGB(100,100,150)
scrollPlant.ScrollingDirection = Enum.ScrollingDirection.Y
scrollPlant.ClipsDescendants = true

local layoutPlant = Instance.new("UIListLayout", scrollPlant)
layoutPlant.SortOrder = Enum.SortOrder.LayoutOrder

local sorted = {}
for name in pairs(SeedStock) do
	table.insert(sorted, name)
end
table.sort(sorted)

-- Кнопки сортировки для AutoBuy
local sortModeBuy = "name" -- name or price

local azBtnBuy = Instance.new("TextButton", buy)
azBtnBuy.Size = UDim2.new(0, 50, 0, 28)
azBtnBuy.Position = UDim2.new(0, 250, 0, 30)
azBtnBuy.Text = "A-Z"
azBtnBuy.Font = Enum.Font.Code
azBtnBuy.TextSize = 14
azBtnBuy.TextColor3 = Color3.new(1,1,1)
azBtnBuy.BackgroundColor3 = Color3.fromRGB(40,40,60)

local priceBtnBuy = Instance.new("TextButton", buy)
priceBtnBuy.Size = UDim2.new(0, 70, 0, 28)
priceBtnBuy.Position = UDim2.new(0, 170, 0, 30)
priceBtnBuy.Text = "Price ↓"
priceBtnBuy.Font = Enum.Font.Code
priceBtnBuy.TextSize = 14
priceBtnBuy.TextColor3 = Color3.new(1,1,1)
priceBtnBuy.BackgroundColor3 = Color3.fromRGB(40,40,60)

-- Кнопки сортировки для AutoPlant
local sortModePlant = "name" -- name or price

local azBtnPlant = Instance.new("TextButton", plant)
azBtnPlant.Size = UDim2.new(0, 50, 0, 28)
azBtnPlant.Position = UDim2.new(0, 250, 0, 30)
azBtnPlant.Text = "A-Z"
azBtnPlant.Font = Enum.Font.Code
azBtnPlant.TextSize = 14
azBtnPlant.TextColor3 = Color3.new(1,1,1)
azBtnPlant.BackgroundColor3 = Color3.fromRGB(40,40,60)

local priceBtnPlant = Instance.new("TextButton", plant)
priceBtnPlant.Size = UDim2.new(0, 70, 0, 28)
priceBtnPlant.Position = UDim2.new(0, 170, 0, 30)
priceBtnPlant.Text = "Price ↓"
priceBtnPlant.Font = Enum.Font.Code
priceBtnPlant.TextSize = 14
priceBtnPlant.TextColor3 = Color3.new(1,1,1)
priceBtnPlant.BackgroundColor3 = Color3.fromRGB(40,40,60)

local function refreshSeedButtons(scroll, selected, sortMode)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local seeds = {}
	for name in pairs(SeedStock) do
		table.insert(seeds, name)
	end

	if sortMode == "price" then
		table.sort(seeds, function(a, b)
			local ad = SeedData[a]
			local bd = SeedData[b]
			return (ad and ad.Price or math.huge) < (bd and bd.Price or math.huge)
		end)
	else
		table.sort(seeds)
	end

	for _, name in ipairs(seeds) do
		local b = Instance.new("TextButton", scroll)
		b.Size = UDim2.new(1,0,0,30)
		b.Text = name
		b.BackgroundColor3 = selected[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.Code
		b.TextSize = 16
		b.MouseButton1Click:Connect(function()
			selected[name] = not selected[name]
			b.BackgroundColor3 = selected[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
			if scroll == scrollBuy then
				updateSelectedBuyText()
			else
				updateSelectedPlantText()
			end
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, scroll:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y)
end

azBtnBuy.MouseButton1Click:Connect(function()
	sortModeBuy = "name"
	refreshSeedButtons(scrollBuy, selectedBuy, sortModeBuy)
end)

priceBtnBuy.MouseButton1Click:Connect(function()
	sortModeBuy = "price"
	refreshSeedButtons(scrollBuy, selectedBuy, sortModeBuy)
end)

azBtnPlant.MouseButton1Click:Connect(function()
	sortModePlant = "name"
	refreshSeedButtons(scrollPlant, selectedPlant, sortModePlant)
end)

priceBtnPlant.MouseButton1Click:Connect(function()
	sortModePlant = "price"
	refreshSeedButtons(scrollPlant, selectedPlant, sortModePlant)
end)

-- Первичная отрисовка
refreshSeedButtons(scrollBuy, selectedBuy, sortModeBuy)
refreshSeedButtons(scrollPlant, selectedPlant, sortModePlant)

-- Метки для AutoBuy
local labelBuy = Instance.new("TextLabel", buy)
labelBuy.Size = UDim2.new(0, 280, 0, 40)
labelBuy.Position = UDim2.new(0, 20, 0, 165)
labelBuy.Text = "Выбрано: "
labelBuy.TextColor3 = Color3.new(1,1,1)
labelBuy.Font = Enum.Font.Code
labelBuy.TextSize = 14
labelBuy.TextWrapped = true
labelBuy.TextXAlignment = Enum.TextXAlignment.Left
labelBuy.BackgroundTransparency = 1

-- Метки для AutoPlant
local labelPlant = Instance.new("TextLabel", plant)
labelPlant.Size = UDim2.new(0, 280, 0, 40)
labelPlant.Position = UDim2.new(0, 20, 0, 165)
labelPlant.Text = "Выбрано: "
labelPlant.TextColor3 = Color3.new(1,1,1)
labelPlant.Font = Enum.Font.Code
labelPlant.TextSize = 14
labelPlant.TextWrapped = true
labelPlant.TextXAlignment = Enum.TextXAlignment.Left
labelPlant.BackgroundTransparency = 1

-- Переключатель AutoBuy
local toggleFrameBuy = Instance.new("Frame", buy)
toggleFrameBuy.Size = UDim2.new(0,280,0,60)
toggleFrameBuy.Position = UDim2.new(0,20,0,210)
toggleFrameBuy.BackgroundColor3 = Color3.fromRGB(25,25,45)

local toggleBuy = Instance.new("TextButton", toggleFrameBuy)
toggleBuy.Size = UDim2.new(0,60,0,40)
toggleBuy.Position = UDim2.new(0,10,0,10)
toggleBuy.Font = Enum.Font.Code
toggleBuy.TextSize = 24
toggleBuy.Text = "?"
toggleBuy.BackgroundColor3 = Color3.fromRGB(35,35,55)
toggleBuy.TextColor3 = Color3.new(1,1,1)

local toggleLabelBuy = Instance.new("TextLabel", toggleFrameBuy)
toggleLabelBuy.Size = UDim2.new(1, -80, 0, 40)
toggleLabelBuy.Position = UDim2.new(0, 80, 0, 10)
toggleLabelBuy.BackgroundTransparency = 1
toggleLabelBuy.Text = "AutoBuy toggle 😋"
toggleLabelBuy.TextColor3 = Color3.new(1,1,1)
toggleLabelBuy.Font = Enum.Font.Code
toggleLabelBuy.TextSize = 16
toggleLabelBuy.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка очистки AutoBuy
local clearBtnBuy = Instance.new("TextButton", toggleFrameBuy)
clearBtnBuy.Size = UDim2.new(0, 40, 0, 40)
clearBtnBuy.Position = UDim2.new(1, -45, 0, 10)
clearBtnBuy.Text = "X"
clearBtnBuy.TextColor3 = Color3.new(1, 0.6, 0.6)
clearBtnBuy.Font = Enum.Font.Code
clearBtnBuy.TextSize = 18
clearBtnBuy.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
clearBtnBuy.BorderSizePixel = 0

-- Переключатель AutoPlant
local toggleFramePlant = Instance.new("Frame", plant)
toggleFramePlant.Size = UDim2.new(0,280,0,60)
toggleFramePlant.Position = UDim2.new(0,20,0,210)
toggleFramePlant.BackgroundColor3 = Color3.fromRGB(25,25,45)

local togglePlant = Instance.new("TextButton", toggleFramePlant)
togglePlant.Size = UDim2.new(0,60,0,40)
togglePlant.Position = UDim2.new(0,10,0,10)
togglePlant.Font = Enum.Font.Code
togglePlant.TextSize = 24
togglePlant.Text = "?"
togglePlant.BackgroundColor3 = Color3.fromRGB(35,35,55)
togglePlant.TextColor3 = Color3.new(1,1,1)

local toggleLabelPlant = Instance.new("TextLabel", toggleFramePlant)
toggleLabelPlant.Size = UDim2.new(1, -80, 0, 40)
toggleLabelPlant.Position = UDim2.new(0, 80, 0, 10)
toggleLabelPlant.BackgroundTransparency = 1
toggleLabelPlant.Text = "AutoPlant toggle 😋"
toggleLabelPlant.TextColor3 = Color3.new(1,1,1)
toggleLabelPlant.Font = Enum.Font.Code
toggleLabelPlant.TextSize = 16
toggleLabelPlant.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка очистки AutoPlant
local clearBtnPlant = Instance.new("TextButton", toggleFramePlant)
clearBtnPlant.Size = UDim2.new(0, 40, 0, 40)
clearBtnPlant.Position = UDim2.new(1, -45, 0, 10)
clearBtnPlant.Text = "X"
clearBtnPlant.TextColor3 = Color3.new(1, 0.6, 0.6)
clearBtnPlant.Font = Enum.Font.Code
clearBtnPlant.TextSize = 18
clearBtnPlant.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
clearBtnPlant.BorderSizePixel = 0

-- Обновление текста выбранных семян для AutoBuy
local function updateSelectedBuyText()
	local s = {}; for k,v in pairs(selectedBuy) do if v then table.insert(s, k) end end
	local text = table.concat(s, ", ")
	labelBuy.Text = "Выбрано: " .. text
	labelBuy.TextScaled = false
	labelBuy.TextSize = 14
	labelBuy.TextWrapped = true
	if labelBuy.TextBounds.X > labelBuy.AbsoluteSize.X then
		labelBuy.TextScaled = true
	end
end

-- Обновление текста выбранных семян для AutoPlant
local function updateSelectedPlantText()
	local s = {}; for k,v in pairs(selectedPlant) do if v then table.insert(s, k) end end
	local text = table.concat(s, ", ")
	labelPlant.Text = "Выбрано: " .. text
	labelPlant.TextScaled = false
	labelPlant.TextSize = 14
	labelPlant.TextWrapped = true
	if labelPlant.TextBounds.X > labelPlant.AbsoluteSize.X then
		labelPlant.TextScaled = true
	end
end

-- Очистка выбранных семян для AutoBuy
clearBtnBuy.MouseButton1Click:Connect(function()
	for name in pairs(selectedBuy) do
		selectedBuy[name] = false
	end
	for _, child in ipairs(scrollBuy:GetChildren()) do
		if child:IsA("TextButton") then
			child.BackgroundColor3 = Color3.fromRGB(35,35,55)
		end
	end
	updateSelectedBuyText()
end)

-- Очистка выбранных семян для
