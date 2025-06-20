-- AutoFarmAndPlant.lua
-- Клиентский скрипт для Executor: автопокупка и автопосадка семян

--// Services
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Remote Events
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlantRE    = GameEvents:WaitForChild("Plant_RE")      -- событие посадки
local BuySeedRE  = GameEvents:WaitForChild("BuySeedStock")  -- событие покупки

--// Модуль данных семян
local SeedData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData"))
local SeedList  = {}
for name, data in pairs(SeedData) do
    if data.DisplayInShop then
        table.insert(SeedList, name)
    end
end
table.sort(SeedList)

--// Поиск фермы игрока
local function GetFarm(playerName)
    for _, farm in ipairs(workspace:WaitForChild("Farm"):GetChildren()) do
        local ownerVal = farm:FindFirstChild("Important")
            and farm.Important:FindFirstChild("Data")
            and farm.Important.Data:FindFirstChild("Owner")
        if ownerVal and ownerVal.Value == playerName then
            return farm
        end
    end
end

local MyFarm = GetFarm(LocalPlayer.Name)
assert(MyFarm, "AutoFarmAndPlant: не найдена ваша ферма в workspace.Farm")

-- Пространства для посадки
local PlantLocations = MyFarm:WaitForChild("Important"):WaitForChild("Plant_Locations")

-- Вычисление области одного участка
local function GetArea(part)
    local c = part:GetPivot()
    local sx, sz = part.Size.X/2, part.Size.Z/2
    local x1 = math.ceil(c.X - sx)
    local z1 = math.ceil(c.Z - sz)
    local x2 = math.floor(c.X + sx)
    local z2 = math.floor(c.Z + sz)
    return x1, z1, x2, z2
end

-- Случайная точка в пределах фермы
local function GetRandomFarmPoint()
    local lands = PlantLocations:GetChildren()
    local land = lands[math.random(1, #lands)]
    local x1, z1, x2, z2 = GetArea(land)
    local x = math.random(x1, x2)
    local z = math.random(z1, z2)
    return Vector3.new(x, land.Position.Y + 0.5, z)
end

-- Поиск инструмента-семени в рюкзаке
local function findSeedInBackpack(name)
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == name then
            return tool
        end
    end
    return nil
end

--// GUI
local old = PlayerGui:FindFirstChild("WaveGui")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name           = "WaveGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size              = UDim2.new(0, 320, 0, 400)
MainFrame.Position          = UDim2.new(0, -320, 0.5, -200)
MainFrame.BackgroundColor3  = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.ClipsDescendants  = true

local Content = Instance.new("Frame", MainFrame)
Content.Size              = UDim2.new(1,0,1,-40)
Content.Position          = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1

local pages = {}
local function switchPage(name)
    for _, f in pairs(pages) do f.Visible = false end
    pages[name].Visible = true
end

-- Главная страница
local home = Instance.new("Frame", Content)
home.Size = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pages["home"] = home

local autoPlantBtn = Instance.new("TextButton", home)
autoPlantBtn.Size              = UDim2.new(0,280,0,50)
autoPlantBtn.Position          = UDim2.new(0,20,0,20)
autoPlantBtn.Text              = "AutoPlantSeeds 🌱"
autoPlantBtn.Font              = Enum.Font.Code
autoPlantBtn.TextSize          = 18
autoPlantBtn.BackgroundColor3  = Color3.fromRGB(20,20,40)
autoPlantBtn.TextColor3        = Color3.new(1,1,1)
autoPlantBtn.MouseButton1Click:Connect(function()
    switchPage("plant")
end)

-- Страница AutoPlant
local plant = Instance.new("Frame", Content)
plant.Size = UDim2.new(1,0,1,0)
plant.BackgroundTransparency = 1
plant.Visible = false
pages["plant"] = plant

local back = Instance.new("ImageButton", plant)
back.Size = UDim2.new(0,28,0,28)
back.Position = UDim2.new(0,10,0,10)
back.Image = "rbxassetid://4952231049"
back.BackgroundTransparency = 1
back.MouseButton1Click:Connect(function() switchPage("home") end)

-- Drop‑box и выбор семян
local selectedPlant = {}
local dropFrame = Instance.new("Frame", plant)
dropFrame.Size = UDim2.new(0,280,0,100)
dropFrame.Position = UDim2.new(0,20,0,60)
dropFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)

local scroll = Instance.new("ScrollingFrame", dropFrame)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollingDirection = Enum.ScrollingDirection.Y

local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local label = Instance.new("TextLabel", plant)
label.Size = UDim2.new(0,280,0,40)
label.Position = UDim2.new(0,20,0,165)
label.Text = "Выбрано: "
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextWrapped = true
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)

for _, name in ipairs(SeedList) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = name
    btn.Font = Enum.Font.Code
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        selectedPlant[name] = not selectedPlant[name]
        btn.BackgroundColor3 = selectedPlant[name] and Color3.fromRGB(60,100,60) or Color3.fromRGB(35,35,55)
        local t = {}
        for k,v in pairs(selectedPlant) do if v then table.insert(t, k) end end
        label.Text = "Выбрано: " .. table.concat(t, ", ")
    end)
end
scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)

-- Переключатель
local plantToggle = Instance.new("TextButton", plant)
plantToggle.Size = UDim2.new(0,60,0,40)
plantToggle.Position = UDim2.new(0,20,0,220)
plantToggle.Text = "?"
plantToggle.Font = Enum.Font.Code
plantToggle.TextSize = 24
plantToggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
plantToggle.TextColor3 = Color3.new(1,1,1)

local plantToggleLabel = Instance.new("TextLabel", plant)
plantToggleLabel.Size = UDim2.new(1,-100,0,40)
plantToggleLabel.Position = UDim2.new(0,90,0,220)
plantToggleLabel.Text = "AutoPlantSeeds 😋"
plantToggleLabel.Font = Enum.Font.Code
plantToggleLabel.TextSize = 16
plantToggleLabel.BackgroundTransparency = 1
plantToggleLabel.TextColor3 = Color3.new(1,1,1)

local plantClear = Instance.new("TextButton", plant)
plantClear.Size = UDim2.new(0,40,0,40)
plantClear.Position = UDim2.new(1,-50,0,220)
plantClear.Text = "X"
plantClear.Font = Enum.Font.Code
plantClear.TextSize = 18
plantClear.TextColor3 = Color3.new(1,0.6,0.6)
plantClear.BackgroundColor3 = Color3.fromRGB(45,25,25)
plantClear.BorderSizePixel = 0
plantClear.MouseButton1Click:Connect(function()
    table.clear(selectedPlant)
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35,35,55) end
    end
    label.Text = "Выбрано: "
end)

-- Глобальные флаги
_G.AutoPlantEnabled = false
_G.AutoPlantSeeds   = {}

plantToggle.MouseButton1Click:Connect(function()
    _G.AutoPlantEnabled = not _G.AutoPlantEnabled
    plantToggle.Text    = _G.AutoPlantEnabled and "👍" or "?"
    _G.AutoPlantSeeds   = {}
    for k,v in pairs(selectedPlant) do if v then table.insert(_G.AutoPlantSeeds, k) end end
end)

-- Основной цикл автопосадки (0.5 сек) с экипировкой семян
spawn(function()
    while wait(0.5) do
        if _G.AutoPlantEnabled and #_G.AutoPlantSeeds > 0 then
            for _, seedName in ipairs(_G.AutoPlantSeeds) do
                -- находим инструмент в рюкзаке
                local tool = findSeedInBackpack(seedName)
                if tool then
                    -- экипируем в руки
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                        wait(0.1)
                        -- вызываем посадку на случайной точке
                        Plant(GetRandomFarmPoint(), seedName)
                    end
                end
            end
        end
    end
end)

-- Начать с главной вкладки
switchPage("home")
