-- AutoFarmAndPlant.lua
-- Lua‑скрипт для автопокупки и автопосадки семян в Roblox

--// Services
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents     = ReplicatedStorage:WaitForChild("GameEvents")
local SeedDataModule = ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData")

-- Получение данных семян из модуля
local SeedData = require(SeedDataModule)
local SeedList  = {}
for name, data in pairs(SeedData) do
    if data.DisplayInShop then
        table.insert(SeedList, name)
    end
end
table.sort(SeedList)

-- Удаляем старый GUI, если есть
local oldGui = PlayerGui:FindFirstChild("WaveGui")
if oldGui then oldGui:Destroy() end

-- Создаём новый ScreenGui
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name           = "WaveGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true

-- Основной фрейм
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size              = UDim2.new(0,320,0,400)
MainFrame.Position          = UDim2.new(0,-320,0.5,-200)
MainFrame.BackgroundColor3  = Color3.fromRGB(10,10,20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel   = 0
MainFrame.ClipsDescendants  = true

-- Фон
local bg = Instance.new("ImageLabel", MainFrame)
bg.Size              = UDim2.new(1,0,1,0)
bg.Image             = "rbxassetid://70998571392678"
bg.BackgroundTransparency = 1
bg.ImageTransparency = 0.2
bg.ScaleType         = Enum.ScaleType.Crop
bg.ZIndex            = 0

-- Заголовок
local Header = Instance.new("TextLabel", MainFrame)
Header.Size             = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = Color3.fromRGB(25,25,40)
Header.Text             = "🌱 Wave Garden"
Header.TextColor3       = Color3.new(1,1,1)
Header.Font             = Enum.Font.Code
Header.TextSize         = 18
Header.ZIndex           = 1

-- Контент
local Content = Instance.new("Frame", MainFrame)
Content.Size              = UDim2.new(1,0,1,-40)
Content.Position          = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1
Content.ZIndex            = 1

-- Стрелки для открытия/закрытия
local LeftArrow = Instance.new("TextButton", ScreenGui)
LeftArrow.Size             = UDim2.new(0,24,0,50)
LeftArrow.Position         = UDim2.new(0,0,0.5,-25)
LeftArrow.Text             = "▶"
LeftArrow.BackgroundColor3 = Color3.fromRGB(15,15,25)
LeftArrow.TextColor3       = Color3.new(0.8,0.8,1)
LeftArrow.Font             = Enum.Font.Code
LeftArrow.TextSize         = 20

local RightArrow = Instance.new("TextButton", MainFrame)
RightArrow.Size             = UDim2.new(0,24,0,50)
RightArrow.Position         = UDim2.new(1,-24,0.5,-25)
RightArrow.Text             = "◀"
RightArrow.BackgroundColor3 = Color3.fromRGB(15,15,25)
RightArrow.TextColor3       = Color3.new(0.8,0.8,1)
RightArrow.Font             = Enum.Font.Code
RightArrow.TextSize         = 20
RightArrow.Visible          = false

local openTween  = TweenService:Create(MainFrame, TweenInfo.new(0.35), {Position = UDim2.new(0,0,0.5,-200)})
local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.35), {Position = UDim2.new(0,-320,0.5,-200)})

LeftArrow.MouseButton1Click:Connect(function()
    openTween:Play()
    LeftArrow.Visible  = false
    RightArrow.Visible = true
end)
RightArrow.MouseButton1Click:Connect(function()
    closeTween:Play()
    LeftArrow.Visible  = true
    RightArrow.Visible = false
end)

-- Таб менеджер
local pages = {}
local function switchPage(name)
    for _, frame in pairs(pages) do frame.Visible = false end
    pages[name].Visible = true
end

-- === Домашняя страница ===
local home = Instance.new("Frame", Content)
home.Size               = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pages["home"]           = home

local autoBuyBtn = Instance.new("TextButton", home)
autoBuyBtn.Size              = UDim2.new(0,280,0,50)
autoBuyBtn.Position          = UDim2.new(0,20,0,20)
autoBuyBtn.Text              = "AutoBuySeeds 🌱"
autoBuyBtn.Font              = Enum.Font.Code
autoBuyBtn.TextColor3        = Color3.new(1,1,1)
autoBuyBtn.BackgroundColor3  = Color3.fromRGB(20,20,40)

local autoPlantBtn = Instance.new("TextButton", home)
autoPlantBtn.Size             = UDim2.new(0,280,0,50)
autoPlantBtn.Position         = UDim2.new(0,20,0,80)
autoPlantBtn.Text             = "AutoPlantSeeds 🌱"
autoPlantBtn.Font             = Enum.Font.Code
autoPlantBtn.TextColor3       = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20,20,40)

autoBuyBtn.MouseButton1Click:Connect(function() switchPage("buy") end)
autoPlantBtn.MouseButton1Click:Connect(function() switchPage("plant") end)

-- === Страница AutoBuy ===
local buy = Instance.new("Frame", Content)
buy.Size               = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible            = false
pages["buy"]           = buy

local backBuy = Instance.new("ImageButton", buy)
backBuy.Size           = UDim2.new(0,28,0,28)
backBuy.Position       = UDim2.new(0,10,0,10)
backBuy.Image          = "rbxassetid://4952231049"
backBuy.BackgroundTransparency = 1
backBuy.MouseButton1Click:Connect(function() switchPage("home") end)

-- Buy: элементы выбора
local selectedBuy = {}
local buyDrop = Instance.new("Frame", buy)
buyDrop.Size             = UDim2.new(0,280,0,100)
buyDrop.Position         = UDim2.new(0,20,0,60)
buyDrop.BackgroundColor3 = Color3.fromRGB(25,25,45)

local buyScroll = Instance.new("ScrollingFrame", buyDrop)
buyScroll.Size             = UDim2.new(1,0,1,0)
buyScroll.BackgroundTransparency = 1
buyScroll.CanvasSize       = UDim2.new(0,0,0,0)
buyScroll.ScrollBarThickness = 6
buyScroll.ScrollingDirection = Enum.ScrollingDirection.Y

local buyLayout = Instance.new("UIListLayout", buyScroll)
buyLayout.SortOrder = Enum.SortOrder.LayoutOrder

local buyLabel = Instance.new("TextLabel", buy)
buyLabel.Size             = UDim2.new(0,280,0,40)
buyLabel.Position         = UDim2.new(0,20,0,165)
buyLabel.Text             = "Выбрано: "
buyLabel.TextColor3       = Color3.new(1,1,1)
buyLabel.Font             = Enum.Font.Code
buyLabel.TextSize         = 14
buyLabel.BackgroundTransparency = 1

for _, name in ipairs(SeedList) do
    local btn = Instance.new("TextButton", buyScroll)
    btn.Size             = UDim2.new(1,0,0,30)
    btn.Text             = name
    btn.Font             = Enum.Font.Code
    btn.TextColor3       = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.MouseButton1Click:Connect(function()
        selectedBuy[name] = not selectedBuy[name]
        btn.BackgroundColor3 = selectedBuy[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
        local t = {}
        for k,v in pairs(selectedBuy) do if v then table.insert(t,k) end end
        buyLabel.Text = "Выбрано: " .. table.concat(t, ", ")
    end)
end
buyScroll.CanvasSize = UDim2.new(0,0,0, buyLayout.AbsoluteContentSize.Y)

local buyToggle = Instance.new("TextButton", buy)
buyToggle.Size             = UDim2.new(0,60,0,40)
buyToggle.Position         = UDim2.new(0,20,0,220)
buyToggle.Text             = "?"
buyToggle.Font             = Enum.Font.Code
buyToggle.TextSize         = 24
buyToggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
buyToggle.TextColor3       = Color3.new(1,1,1)

local buyToggleLabel = Instance.new("TextLabel", buy)
buyToggleLabel.Size             = UDim2.new(1,-100,0,40)
buyToggleLabel.Position         = UDim2.new(0,90,0,220)
buyToggleLabel.Text             = "AutoBuySeeds 😋"
buyToggleLabel.Font             = Enum.Font.Code
buyToggleLabel.TextSize         = 16
buyToggleLabel.TextColor3       = Color3.new(1,1,1)
buyToggleLabel.BackgroundTransparency = 1

local buyClear = Instance.new("TextButton", buy)
buyClear.Size             = UDim2.new(0,40,0,40)
buyClear.Position         = UDim2.new(1,-50,0,220)
buyClear.Text             = "X"
buyClear.Font             = Enum.Font.Code
buyClear.TextSize         = 18
buyClear.TextColor3       = Color3.new(1,0.6,0.6)
buyClear.BackgroundColor3 = Color3.fromRGB(45,25,25)
buyClear.BorderSizePixel   = 0
buyClear.MouseButton1Click:Connect(function()
    for k in pairs(selectedBuy) do selectedBuy[k] = nil end
    for _, c in ipairs(buyScroll:GetChildren()) do
        if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35,35,55) end
    end
    buyLabel.Text = "Выбрано: "
end)

-- Флаги и массивы
_G.AutoBuyEnabled = false
_G.AutoBuySeeds   = {}

buyToggle.MouseButton1Click:Connect(function()
    _G.AutoBuyEnabled = not _G.AutoBuyEnabled
    buyToggle.Text    = _G.AutoBuyEnabled and "👍" or "?"
    _G.AutoBuySeeds   = {}
    for k,v in pairs(selectedBuy) do if v then table.insert(_G.AutoBuySeeds, k) end end
end)

-- Цикл автопокупки
spawn(function()
    while wait(1) do
        if _G.AutoBuyEnabled then
            for _, seedName in ipairs(_G.AutoBuySeeds) do
                GameEvents.BuySeedStock:FireServer(seedName)
            end
        end
    end
end)

-- === Страница AutoPlant ===
local plant = Instance.new("Frame", Content)
plant.Size               = UDim2.new(1,0,1,0)
plant.BackgroundTransparency = 1
plant.Visible            = false
pages["plant"]           = plant

local backPlant = Instance.new("ImageButton", plant)
backPlant.Size           = UDim2.new(0,28,0,28)
backPlant.Position       = UDim2.new(0,10,0,10)
backPlant.Image          = "rbxassetid://4952231049"
backPlant.BackgroundTransparency = 1
backPlant.MouseButton1Click:Connect(function() switchPage("home") end)

-- Plant: элементы выбора
local selectedPlant = {}
local plantDrop = Instance.new("Frame", plant)
plantDrop.Size             = UDim2.new(0,280,0,100)
plantDrop.Position         = UDim2.new(0,20,0,60)
plantDrop.BackgroundColor3 = Color3.fromRGB(25,25,45)

local plantScroll = Instance.new("ScrollingFrame", plantDrop)
plantScroll.Size             = UDim2.new(1,0,1,0)
plantScroll.BackgroundTransparency = 1
plantScroll.CanvasSize       = UDim2.new(0,0,0,0)
plantScroll.ScrollBarThickness = 6
plantScroll.ScrollingDirection = Enum.ScrollingDirection.Y

local plantLayout = Instance.new("UIListLayout", plantScroll)
plantLayout.SortOrder = Enum.SortOrder.LayoutOrder

local plantLabel = Instance.new("TextLabel", plant)
plantLabel.Size             = UDim2.new(0,280,0,40)
plantLabel.Position         = UDim2.new(0,20,0,165)
plantLabel.Text             = "Выбрано: "
plantLabel.TextColor3       = Color3.new(1,1,1)
plantLabel.Font             = Enum.Font.Code
plantLabel.TextSize         = 14
plantLabel.BackgroundTransparency = 1

for _, name in ipairs(SeedList) do
    local btn = Instance.new("TextButton", plantScroll)
    btn.Size             = UDim2.new(1,0,0,30)
    btn.Text             = name
    btn.Font             = Enum.Font.Code
    btn.TextColor3       = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.MouseButton1Click:Connect(function()
        selectedPlant[name] = not selectedPlant[name]
        btn.BackgroundColor3 = selectedPlant[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
        local t = {}
        for k,v in pairs(selectedPlant) do if v then table.insert(t,k) end end
        plantLabel.Text = "Выбрано: " .. table.concat(t, ", ")
    end)
end
plantScroll.CanvasSize = UDim2.new(0,0,0, plantLayout.AbsoluteContentSize.Y)

local plantToggle = Instance.new("TextButton", plant)
plantToggle.Size             = UDim2.new(0,60,0,40)
plantToggle.Position         = UDim2.new(0,20,0,220)
plantToggle.Text             = "?"
plantToggle.Font             = Enum.Font.Code
plantToggle.TextSize         = 24
plantToggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
plantToggle.TextColor3       = Color3.new(1,1,1)

local plantToggleLabel = Instance.new("TextLabel", plant)
plantToggleLabel.Size             = UDim2.new(1,-100,0,40)
plantToggleLabel.Position         = UDim2.new(0,90,0,220)
plantToggleLabel.Text             = "AutoPlantSeeds 😋"
plantToggleLabel.Font             = Enum.Font.Code
plantToggleLabel.TextSize         = 16
plantToggleLabel.TextColor3       = Color3.new(1,1,1)
plantToggleLabel.BackgroundTransparency = 1

local plantClear = Instance.new("TextButton", plant)
plantClear.Size             = UDim2.new(0,40,0,40)
plantClear.Position         = UDim2.new(1,-50,0,220)
plantClear.Text             = "X"
plantClear.Font             = Enum.Font.Code
plantClear.TextSize         = 18
plantClear.TextColor3       = Color3.new(1,0.6,0.6)
plantClear.BackgroundColor3 = Color3.fromRGB(45,25,25)
plantClear.BorderSizePixel   = 0
plantClear.MouseButton1Click:Connect(function()
    for k in pairs(selectedPlant) do selectedPlant[k] = nil end
    for _, c in ipairs(plantScroll:GetChildren()) do
        if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35,35,55) end
    end
    plantLabel.Text = "Выбрано: "
end)

_G.AutoPlantEnabled = false
_G.AutoPlantSeeds   = {}

plantToggle.MouseButton1Click:Connect(function()
    _G.AutoPlantEnabled = not _G.AutoPlantEnabled
    plantToggle.Text    = _G.AutoPlantEnabled and "👍" or "?"
    _G.AutoPlantSeeds   = {}
    for k,v in pairs(selectedPlant) do if v then table.insert(_G.AutoPlantSeeds, k) end end
end)

-- Вспомогательные функции для посадки
local function findSeedInBackpack(name)
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == name then return tool end
    end
    return nil
end

local function findEmptyField()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Field" and not obj:FindFirstChild("Crop") then
            return obj
        end
    end
    return nil
end

-- Цикл автопосадки (0.5 сек)
spawn(function()
    while wait(0.5) do
        if _G.AutoPlantEnabled then
            for _, seedName in ipairs(_G.AutoPlantSeeds) do
                local tool = findSeedInBackpack(seedName)
                if tool then
                    local field = findEmptyField()
                    if field then
                        -- Вызываем серверное событие посадки (как в autofarm.lua)
                        ReplicatedStorage:WaitForChild("ManipulateCrop"):FireServer(field, "PlantSeed", seedName)
                    end
                end
            end
        end
    end
end)

-- Старт на главной
switchPage("home")
