
[WaveAI - Roblox Grow GUI Script Development Log]

1. ✅ Изначальный GUI (всплывающее меню, стили ImGui, автопоиск фермы).
2. ✅ Создание AutoBuySeeds раздела (дропбокс с семенами, переключатель).
3. ✅ Добавлен фон (rbxassetid://70998571392678) с прозрачностью и блюром.
4. ✅ AutoBuy toggle имеет подпись, добавлен функционал циклической покупки.
5. ✅ Список семян заполняется из game.ReplicatedStorage.Data.SeedData с фильтром DisplayInShop = true.
6. ✅ Под списком отображаются выбранные семена.
7. ✅ Добавлена кнопка "Clear" — сбрасывает все выбранные семена.
8. ✅ Улучшено отображение "Выбрано:" — автоуменьшение текста если не помещается.
9. ✅ Кнопка сортировки теперь одна (по умолчанию Price ↓, по нажатию меняется на A-Z).
10. 📂 Все версии скриптов экспортированы в `.lua` файлы по ходу работы.

⏭ Следующий шаг можно продолжить на другом аккаунте, импортируя последний `.lua`:
GrowGUI_SeedData_ToggleSort.lua

— WaveAI by SPDM Team

Вот скрипт из которого ведётся извлечение функций (копи пастим):
```
--[[
    @author depso (depthso)
    @description Grow a Garden auto-farm script
    https://www.roblox.com/games/126884695634066
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Leaderstats = LocalPlayer.leaderstats
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui

local ShecklesCount = Leaderstats.Sheckles
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)

--// ReGui
local ReGui = loadstring(game:HttpGet('https://raw.githubusercontent.com/depthso/Dear-ReGui/refs/heads/main/ReGui.lua'))()
local PrefabsId = "rbxassetid://" .. ReGui.PrefabsId

--// Folders
local GameEvents = ReplicatedStorage.GameEvents
local Farms = workspace.Farm

local Accent = {
    DarkGreen = Color3.fromRGB(45, 95, 25),
    Green = Color3.fromRGB(69, 142, 40),
    Brown = Color3.fromRGB(26, 20, 8),
}

--// ReGui configuration (Ui library)
ReGui:Init({
	Prefabs = InsertService:LoadLocalAsset(PrefabsId)
})
ReGui:DefineTheme("GardenTheme", {
	WindowBg = Accent.Brown,
	TitleBarBg = Accent.DarkGreen,
	TitleBarBgActive = Accent.Green,
    ResizeGrab = Accent.DarkGreen,
    FrameBg = Accent.DarkGreen,
    FrameBgActive = Accent.Green,
	CollapsingHeaderBg = Accent.Green,
    ButtonsBg = Accent.Green,
    CheckMark = Accent.Green,
    SliderGrab = Accent.Green,
})

--// Dicts
local SeedStock = {}
local OwnedSeeds = {}
local HarvestIgnores = {
	Normal = false,
	Gold = false,
	Rainbow = false
}

--// Globals
local SelectedSeed, AutoPlantRandom, AutoPlant, AutoHarvest, AutoBuy, SellThreshold, NoClip, AutoWalkAllowRandom

local function CreateWindow()
	local Window = ReGui:Window({
		Title = `{GameInfo.Name} | Depso`,
        Theme = "GardenTheme",
		Size = UDim2.fromOffset(300, 200)
	})
	return Window
end

--// Interface functions
local function Plant(Position: Vector3, Seed: string)
	GameEvents.Plant_RE:FireServer(Position, Seed)
	wait(.3)
end

local function GetFarms()
	return Farms:GetChildren()
end

local function GetFarmOwner(Farm: Folder): string
	local Important = Farm.Important
	local Data = Important.Data
	local Owner = Data.Owner

	return Owner.Value
end

local function GetFarm(PlayerName: string): Folder?
	local Farms = GetFarms()
	for _, Farm in next, Farms do
		local Owner = GetFarmOwner(Farm)
		if Owner == PlayerName then
			return Farm
		end
	end
    return
end

local IsSelling = false
local function SellInventory()
	local Character = LocalPlayer.Character
	local Previous = Character:GetPivot()
	local PreviousSheckles = ShecklesCount.Value

	--// Prevent conflict
	if IsSelling then return end
	IsSelling = true

	Character:PivotTo(CFrame.new(62, 4, -26))
	while wait() do
		if ShecklesCount.Value ~= PreviousSheckles then break end
		GameEvents.Sell_Inventory:FireServer()
	end
	Character:PivotTo(Previous)

	wait(0.2)
	IsSelling = false
end

local function BuySeed(Seed: string)
	GameEvents.BuySeedStock:FireServer(Seed)
end

local function BuyAllSelectedSeeds()
    local Seed = SelectedSeedStock.Selected
    local Stock = SeedStock[Seed]

	if not Stock or Stock <= 0 then return end

    for i = 1, Stock do
        BuySeed(Seed)
    end
end

local function GetSeedInfo(Seed: Tool): number?
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

local function CollectCropsFromParent(Parent, Crops: table)
	for _, Tool in next, Parent:GetChildren() do
		local Name = Tool:FindFirstChild("Item_String")
		if not Name then continue end

		table.insert(Crops, Tool)
	end
end

local function GetOwnedSeeds(): table
	local Character = LocalPlayer.Character
	
	CollectSeedsFromParent(Backpack, OwnedSeeds)
	CollectSeedsFromParent(Character, OwnedSeeds)

	return OwnedSeeds
end

local function GetInvCrops(): table
	local Character = LocalPlayer.Character
	
	local Crops = {}
	CollectCropsFromParent(Backpack, Crops)
	CollectCropsFromParent(Character, Crops)

	return Crops
end

local function GetArea(Base: BasePart)
	local Center = Base:GetPivot()
	local Size = Base.Size

	--// Bottom left
	local X1 = math.ceil(Center.X - (Size.X/2))
	local Z1 = math.ceil(Center.Z - (Size.Z/2))

	--// Top right
	local X2 = math.floor(Center.X + (Size.X/2))
	local Z2 = math.floor(Center.Z + (Size.Z/2))

	return X1, Z1, X2, Z2
end

local function EquipCheck(Tool)
    local Character = LocalPlayer.Character
    local Humanoid = Character.Humanoid

    if Tool.Parent ~= Backpack then return end
    Humanoid:EquipTool(Tool)
end

--// Auto farm functions
local MyFarm = GetFarm(LocalPlayer.Name)
local MyImportant = MyFarm.Important
local PlantLocations = MyImportant.Plant_Locations
local PlantsPhysical = MyImportant.Plants_Physical

local Dirt = PlantLocations:FindFirstChildOfClass("Part")
local X1, Z1, X2, Z2 = GetArea(Dirt)

local function GetRandomFarmPoint(): Vector3
    local FarmLands = PlantLocations:GetChildren()
    local FarmLand = FarmLands[math.random(1, #FarmLands)]

    local X1, Z1, X2, Z2 = GetArea(FarmLand)
    local X = math.random(X1, X2)
    local Z = math.random(Z1, Z2)

    return Vector3.new(X, 4, Z)
end

local function AutoPlantLoop()
	local Seed = SelectedSeed.Selected

	local SeedData = OwnedSeeds[Seed]
	if not SeedData then return end

    local Count = SeedData.Count
    local Tool = SeedData.Tool

	--// Check for stock
	if Count <= 0 then return end

    local Planted = 0
	local Step = 1

	--// Check if the client needs to equip the tool
    EquipCheck(Tool)

	--// Plant at random points
	if AutoPlantRandom.Value then
		for i = 1, Count do
			local Point = GetRandomFarmPoint()
			Plant(Point, Seed)
		end
	end
	
	--// Plant on the farmland area
	for X = X1, X2, Step do
		for Z = Z1, Z2, Step do
			if Planted > Count then break end
			local Point = Vector3.new(X, 0.13, Z)

			Planted += 1
			Plant(Point, Seed)
		end
	end
end

local function HarvestPlant(Plant: Model)
	local Prompt = Plant:FindFirstChild("ProximityPrompt", true)

	--// Check if it can be harvested
	if not Prompt then return end
	fireproximityprompt(Prompt)
end

local function GetSeedStock(IgnoreNoStock: boolean?): table
	local SeedShop = PlayerGui.Seed_Shop
	local Items = SeedShop:FindFirstChild("Blueberry", true).Parent

	local NewList = {}

	for _, Item in next, Items:GetChildren() do
		local MainFrame = Item:FindFirstChild("Main_Frame")
		if not MainFrame then continue end

		local StockText = MainFrame.Stock_Text.Text
		local StockCount = tonumber(StockText:match("%d+"))

		--// Seperate list
		if IgnoreNoStock then
			if StockCount <= 0 then continue end
			NewList[Item.Name] = StockCount
			continue
		end

		SeedStock[Item.Name] = StockCount
	end

	return IgnoreNoStock and NewList or SeedStock
end

local function CanHarvest(Plant): boolean?
    local Prompt = Plant:FindFirstChild("ProximityPrompt", true)
	if not Prompt then return end
    if not Prompt.Enabled then return end

    return true
end

local function CollectHarvestable(Parent, Plants, IgnoreDistance: boolean?)
	local Character = LocalPlayer.Character
	local PlayerPosition = Character:GetPivot().Position

    for _, Plant in next, Parent:GetChildren() do
        --// Fruits
		local Fruits = Plant:FindFirstChild("Fruits")
		if Fruits then
			CollectHarvestable(Fruits, Plants, IgnoreDistance)
		end

		--// Distance check
		local PlantPosition = Plant:GetPivot().Position
		local Distance = (PlayerPosition-PlantPosition).Magnitude
		if not IgnoreDistance and Distance > 15 then continue end

		--// Ignore check
		local Variant = Plant:FindFirstChild("Variant")
		if HarvestIgnores[Variant.Value] then continue end

        --// Collect
        if CanHarvest(Plant) then
            table.insert(Plants, Plant)
        end
	end
    return Plants
end

local function GetHarvestablePlants(IgnoreDistance: boolean?)
    local Plants = {}
    CollectHarvestable(PlantsPhysical, Plants, IgnoreDistance)
    return Plants
end

local function HarvestPlants(Parent: Model)
	local Plants = GetHarvestablePlants()
    for _, Plant in next, Plants do
        HarvestPlant(Plant)
    end
end

local function AutoSellCheck()
    local CropCount = #GetInvCrops()

    if not AutoSell.Value then return end
    if CropCount < SellThreshold.Value then return end

    SellInventory()
end

local function AutoWalkLoop()
	if IsSelling then return end

    local Character = LocalPlayer.Character
    local Humanoid = Character.Humanoid

    local Plants = GetHarvestablePlants(true)
	local RandomAllowed = AutoWalkAllowRandom.Value
	local DoRandom = #Plants == 0 or math.random(1, 3) == 2

    --// Random point
    if RandomAllowed and DoRandom then
        local Position = GetRandomFarmPoint()
        Humanoid:MoveTo(Position)
		AutoWalkStatus.Text = "Random point"
        return
    end
   
    --// Move to each plant
    for _, Plant in next, Plants do
        local Position = Plant:GetPivot().Position
        Humanoid:MoveTo(Position)
		AutoWalkStatus.Text = Plant.Name
    end
end

local function NoclipLoop()
    local Character = LocalPlayer.Character
    if not NoClip.Value then return end
    if not Character then return end

    for _, Part in Character:GetDescendants() do
        if Part:IsA("BasePart") then
            Part.CanCollide = false
        end
    end
end

local function MakeLoop(Toggle, Func)
	coroutine.wrap(function()
		while wait(.01) do
			if not Toggle.Value then continue end
			Func()
		end
	end)()
end

local function StartServices()
	--// Auto-Walk
	MakeLoop(AutoWalk, function()
		local MaxWait = AutoWalkMaxWait.Value
		AutoWalkLoop()
		wait(math.random(1, MaxWait))
	end)

	--// Auto-Harvest
	MakeLoop(AutoHarvest, function()
		HarvestPlants(PlantsPhysical)
	end)

	--// Auto-Buy
	MakeLoop(AutoBuy, BuyAllSelectedSeeds)

	--// Auto-Plant
	MakeLoop(AutoPlant, AutoPlantLoop)

	--// Get stocks
	while wait(.1) do
		GetSeedStock()
		GetOwnedSeeds()
	end
end

local function CreateCheckboxes(Parent, Dict: table)
	for Key, Value in next, Dict do
		Parent:Checkbox({
			Value = Value,
			Label = Key,
			Callback = function(_, Value)
				Dict[Key] = Value
			end
		})
	end
end

--// Window
local Window = CreateWindow()

--// Auto-Plant
local PlantNode = Window:TreeNode({Title="Auto-Plant 🥕"})
SelectedSeed = PlantNode:Combo({
	Label = "Seed",
	Selected = "",
	GetItems = GetSeedStock,
})
AutoPlant = PlantNode:Checkbox({
	Value = false,
	Label = "Enabled"
})
AutoPlantRandom = PlantNode:Checkbox({
	Value = false,
	Label = "Plant at random points"
})
PlantNode:Button({
	Text = "Plant all",
	Callback = AutoPlantLoop,
})

--// Auto-Harvest
local HarvestNode = Window:TreeNode({Title="Auto-Harvest 🚜"})
AutoHarvest = HarvestNode:Checkbox({
	Value = false,
	Label = "Enabled"
})
HarvestNode:Separator({Text="Ignores:"})
CreateCheckboxes(HarvestNode, HarvestIgnores)

--// Auto-Buy
local BuyNode = Window:TreeNode({Title="Auto-Buy 🥕"})
local OnlyShowStock

SelectedSeedStock = BuyNode:Combo({
	Label = "Seed",
	Selected = "",
	GetItems = function()
		local OnlyStock = OnlyShowStock and OnlyShowStock.Value
		return GetSeedStock(OnlyStock)
	end,
})
AutoBuy = BuyNode:Checkbox({
	Value = false,
	Label = "Enabled"
})
OnlyShowStock = BuyNode:Checkbox({
	Value = false,
	Label = "Only list stock"
})
BuyNode:Button({
	Text = "Buy all",
	Callback = BuyAllSelectedSeeds,
})

--// Auto-Sell
local SellNode = Window:TreeNode({Title="Auto-Sell 💰"})
SellNode:Button({
	Text = "Sell inventory",
	Callback = SellInventory, 
})
AutoSell = SellNode:Checkbox({
	Value = false,
	Label = "Enabled"
})
SellThreshold = SellNode:SliderInt({
    Label = "Crops threshold",
    Value = 15,
    Minimum = 1,
    Maximum = 199,
})

--// Auto-Walk
local WallNode = Window:TreeNode({Title="Auto-Walk 🚶"})
AutoWalkStatus = WallNode:Label({
	Text = "None"
})
AutoWalk = WallNode:Checkbox({
	Value = false,
	Label = "Enabled"
})
AutoWalkAllowRandom = WallNode:Checkbox({
	Value = true,
	Label = "Allow random points"
})
NoClip = WallNode:Checkbox({
	Value = false,
	Label = "NoClip"
})
AutoWalkMaxWait = WallNode:SliderInt({
    Label = "Max delay",
    Value = 10,
    Minimum = 1,
    Maximum = 120,
})

--// Connections
RunService.Stepped:Connect(NoclipLoop)
Backpack.ChildAdded:Connect(AutoSellCheck)

--// Services
StartServices()
```


И вот сам скрипт к которому смогли развиться:
```
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


-- Кнопки сортировки
local sortMode = "name" -- name or price

local azBtn = Instance.new("TextButton", buy)
azBtn.Size = UDim2.new(0, 50, 0, 28)
azBtn.Position = UDim2.new(0, 250, 0, 30)
azBtn.Text = "A-Z"
azBtn.Font = Enum.Font.Code
azBtn.TextSize = 14
azBtn.TextColor3 = Color3.new(1,1,1)
azBtn.BackgroundColor3 = Color3.fromRGB(40,40,60)

local priceBtn = Instance.new("TextButton", buy)
priceBtn.Size = UDim2.new(0, 70, 0, 28)
priceBtn.Position = UDim2.new(0, 170, 0, 30)
priceBtn.Text = "Price ↓"
priceBtn.Font = Enum.Font.Code
priceBtn.TextSize = 14
priceBtn.TextColor3 = Color3.new(1,1,1)
priceBtn.BackgroundColor3 = Color3.fromRGB(40,40,60)

local function refreshSeedButtons()
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
			updateSelectedText()
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

azBtn.MouseButton1Click:Connect(function()
	sortMode = "name"
	refreshSeedButtons()
end)

priceBtn.MouseButton1Click:Connect(function()
	sortMode = "price"
	refreshSeedButtons()
end)

-- Первичная отрисовка
refreshSeedButtons()

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

refreshSeedButtons()

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
local toggleLabel = Instance.new("TextLabel", toggleFrame)
toggleLabel.Size = UDim2.new(1, -130, 0, 40)
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
switchPage("home")
```



--// AutoPlantSeeds Feature

--// AutoPlantSeeds Feature
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Backpack = LocalPlayer:WaitForChild("Backpack")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

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

local PlantLocations = MyFarm.Important.Plant_Locations
local targetPart
for _, obj in ipairs(PlantLocations:GetChildren()) do
    if obj:IsA("BasePart") and obj:GetAttribute("Side") == "Right" then
        targetPart = obj
        break
    end
end

assert(targetPart, "Не найдена правая грядка")
local function getPlantPosition()
    return targetPart.Position
end

local planting = false
local selectedSeeds = {} -- Установите это из GUI

local function equipTool(tool)
    if tool and tool:IsA("Tool") and tool.Parent == Backpack then
        tool.Parent = Character
    end
end

local function getAllToolsWithName(seedName)
    local tools = {}
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == (seedName .. " seed") then
            table.insert(tools, t)
        end
    end
    for _, t in ipairs(Character:GetChildren()) do
        if t:IsA("Tool") and t.Name == (seedName .. " seed") then
            table.insert(tools, t)
        end
    end
    return tools
end

local function startPlanting()
    if planting then return end
    planting = true
    coroutine.wrap(function()
        while planting do
            local sorted = {}
            for k, v in pairs(selectedSeeds) do
                if v then table.insert(sorted, k) end
            end
            table.sort(sorted)
            for _, seed in ipairs(sorted) do
                local tools = getAllToolsWithName(seed)
                if #tools == 0 then continue end
                for _, tool in ipairs(tools) do
                    equipTool(tool)
                    local pos = getPlantPosition()
                    GameEvents.Plant_RE:FireServer(pos, seed)
                    wait(0.5)
                end
            end
            wait(1)
        end
    end)()
end

local function stopPlanting()
    planting = false
end

return {
    Start = startPlanting,
    Stop = stopPlanting,
    SetSeeds = function(seeds)
        selectedSeeds = seeds
    end
}
