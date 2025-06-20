--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

local SeedStock = {} -- Инициализация

--// Удаляем старый GUI
do
	local old = PlayerGui:FindFirstChild("WaveGui")
	if old then old:Destroy() end
end

--// Поиск фермы игрока (единожды на запуск)
local FarmsFolder = workspace:WaitForChild("Farm")
local function GetFarms()
	return FarmsFolder:GetChildren()
end

local function GetFarmOwner(Farm)
	return Farm:FindFirstChild("Important").Data.Owner.Value
end

local function FindMyFarm()
	local name = LocalPlayer.Name
	for _, farm in ipairs(GetFarms()) do
		if GetFarmOwner(farm) == name then
			return farm
		end
	end
	return nil
end

local MyFarm = FindMyFarm()
assert(MyFarm, "Не найдена ваша ферма!")

--// Создание GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "WaveGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

--// Основной фрейм
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
Header.Text = "🌱 Wave Garden"
Header.TextColor3 = Color3.new(1,1,1)
Header.Font = Enum.Font.Code
Header.TextSize = 18

--// Контейнер для страниц
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1,0,1,-40)
Content.Position = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1

--// Кнопки свёртки
local LeftArrow = Instance.new("TextButton", ScreenGui)
LeftArrow.Name = "OpenBtn"
LeftArrow.Size = UDim2.new(0, 24, 0, 50)
LeftArrow.Position = UDim2.new(0, 0, 0.5, -25)
LeftArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LeftArrow.Text = "▶"
LeftArrow.TextColor3 = Color3.new(200/255,200/255,1)
LeftArrow.Font = Enum.Font.Code
LeftArrow.TextSize = 20

local RightArrow = Instance.new("TextButton", MainFrame)
RightArrow.Name = "CloseBtn"
RightArrow.Size = UDim2.new(0, 24, 0, 50)
RightArrow.Position = UDim2.new(1, -24, 0.5, -25)
RightArrow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
RightArrow.Text = "◀"
RightArrow.TextColor3 = Color3.new(200/255,200/255,1)
RightArrow.Font = Enum.Font.Code
RightArrow.TextSize = 20
RightArrow.Visible = false

--// Анимация свёртывания/развёртывания
local isOpen = false
local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
	Position = UDim2.new(0, 0, 0.5, -200)
})
local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
	Position = UDim2.new(0, -320, 0.5, -200)
})

LeftArrow.MouseButton1Click:Connect(function()
	isOpen = true
	openTween:Play()
	LeftArrow.Visible = false
	RightArrow.Visible = true
end)
RightArrow.MouseButton1Click:Connect(function()
	isOpen = false
	closeTween:Play()
	LeftArrow.Visible = true
	RightArrow.Visible = false
end)

--// Навигация и страницы
local currentPage = nil
local pageFrames = {}

local function switchPage(name)
	if currentPage then
		pageFrames[currentPage].Visible = false
	end
	pageFrames[name].Visible = true
	currentPage = name
end

--// Главная страница (выбор разделов)
local home = Instance.new("Frame", Content)
home.Size = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pageFrames["home"] = home

local autoBuyBtn = Instance.new("TextButton", home)
autoBuyBtn.Size = UDim2.new(0, 280, 0, 50)
autoBuyBtn.Position = UDim2.new(0, 20, 0, 20)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
autoBuyBtn.Text = "AutoBuySeeds 🌱"
autoBuyBtn.TextColor3 = Color3.new(1,1,1)
autoBuyBtn.Font = Enum.Font.Code
autoBuyBtn.TextSize = 18
autoBuyBtn.BorderSizePixel = 0

--// Страница AutoBuySeeds
local buyPage = Instance.new("Frame", Content)
buyPage.Size = UDim2.new(1,0,1,0)
buyPage.BackgroundTransparency = 1
buyPage.Visible = false
pageFrames["buy"] = buyPage

--// Кнопка домой
local homeBtn = Instance.new("ImageButton", buyPage)
homeBtn.Size = UDim2.new(0,28,0,28)
homeBtn.Position = UDim2.new(0,10,0,10)
homeBtn.Image = "rbxassetid://651321733" -- иконка домика
homeBtn.BackgroundTransparency = 1
homeBtn.MouseButton1Click:Connect(function()
	switchPage("home")
end)

--// Дропбокс мультивыбор
local seedList = {} -- заполнится динамически через SeedStock
local selectedSeeds = {}

local drop = Instance.new("Frame", buyPage)
drop.Size = UDim2.new(0, 280, 0, 100)
drop.Position = UDim2.new(0,20,0,60)
drop.BackgroundColor3 = Color3.fromRGB(25,25,45)

local uilist = Instance.new("ScrollingFrame", drop)
local layout = Instance.new("UIListLayout", uilist)
layout.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Size = UDim2.new(1,0,1,0)
game:GetService("RunService").RenderStepped:Wait()
uilist.CanvasSize = UDim2.new(0, 0, 0, uilist.UIListLayout.AbsoluteContentSize.Y)
uilist.BackgroundTransparency = 1
uilist.ScrollBarThickness = 6

-- Получаем текущий список семян из интерфейса
local function GetSeedStock()
	local gui = PlayerGui:FindFirstChild("Seed_Shop")
	if not gui then return {} end

	local Items = gui:FindFirstChild("Blueberry", true)
	if not Items then return {} end

	local List = Items.Parent
	for _, Item in pairs(List:GetChildren()) do
		local MainFrame = Item:FindFirstChild("Main_Frame")
		if MainFrame then
			local stockText = MainFrame:FindFirstChild("Stock_Text")
			if stockText then
				local count = tonumber(stockText.Text:match("%d+"))
				SeedStock[Item.Name] = count or 0
			end
		end
	end
end

local function refreshSeedList()
	for _, child in ipairs(uilist:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local sorted = {}
	for seedName in pairs(SeedStock) do
		table.insert(sorted, seedName)
	end
	table.sort(sorted)

	for i, seedName in ipairs(sorted) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.Text = seedName
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
		btn.Font = Enum.Font.Code
		btn.TextSize = 16
		btn.BorderSizePixel = 0
		btn.Parent = uilist

		btn.MouseButton1Click:Connect(function()
			selectedSeeds[seedName] = not selectedSeeds[seedName]
			btn.BackgroundColor3 = selectedSeeds[seedName] and Color3.fromRGB(60, 100, 60) or Color3.fromRGB(35, 35, 55)
		end)
	end

	-- Авто CanvasSize
	task.wait() -- UI обновление
	uilist.CanvasSize = UDim2.new(0, 0, 0, uilist.UIListLayout.AbsoluteContentSize.Y)
end

GetSeedStock()
refreshSeedList()

--// Переключатель включения AutoBuy
local toggleFrame = Instance.new("Frame", buyPage)
toggleFrame.Size = UDim2.new(0,280,0,60)
toggleFrame.Position = UDim2.new(0,20,0,180)
toggleFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)
local toggle = Instance.new("TextButton", toggleFrame)
toggle.Size = UDim2.new(0,60,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Font = Enum.Font.Code
toggle.TextSize = 24
toggle.Text = "?"
toggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
toggle.TextColor3 = Color3.new(1,1,1)
local autoBuyEnabled = false
toggle.MouseButton1Click:Connect(function()
	autoBuyEnabled = not autoBuyEnabled
	toggle.Text = autoBuyEnabled and "👍" or "?"
end)

--// Циклическая покупка
spawn(function()
	while true do
		wait(1)
		if not autoBuyEnabled then continue end
		for seed,_ in pairs(selectedSeeds) do
			GameEvents.BuySeedStock:FireServer(seed)
		end
	end
end)

--// Подключаем переключение страниц
autoBuyBtn.MouseButton1Click:Connect(function()
	switchPage("buy")
end)

--// Изначальная страница
switchPage("home")

--// Конфиг UI готов
