-- AutoFarmAndPlant.lua
-- Исправленный клиентский скрипт для Executor: автопокупка и автопосадка семян с видимым GUI

--// Services
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

-- Parent для GUI. Используем gethui() для поддержки некоторых Executors
local GuiParent = (gethui and gethui()) or CoreGui

local LocalPlayer = Players.LocalPlayer

-- Remote Events
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlantRE    = GameEvents:WaitForChild("Plant_RE")
local BuySeedRE  = GameEvents:WaitForChild("BuySeedStock")

--// SeedData
local SeedData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData"))
local SeedList  = {}
for name, data in pairs(SeedData) do
    if data.DisplayInShop then table.insert(SeedList, name) end
end
table.sort(SeedList)

--// Find Farm
local function GetFarm(playerName)
    for _, farm in ipairs(workspace:WaitForChild("Farm"):GetChildren()) do
        local ownerVal = farm:FindFirstChild("Important")
            and farm.Important:FindFirstChild("Data")
            and farm.Important.Data:FindFirstChild("Owner")
        if ownerVal and ownerVal.Value == playerName then return farm end
    end
end
local MyFarm = GetFarm(LocalPlayer.Name)
assert(MyFarm, "AutoFarmAndPlant: ферма не найдена")
local PlantLocations = MyFarm.Important:WaitForChild("Plant_Locations")

-- Helper
local function GetArea(part)
    local c = part:GetPivot()
    local sx, sz = part.Size.X/2, part.Size.Z/2
    return math.ceil(c.X-sx), math.ceil(c.Z-sz), math.floor(c.X+sx), math.floor(c.Z+sz)
end
local function GetRandomFarmPoint()
    local lands = PlantLocations:GetChildren()
    local land = lands[math.random(#lands)]
    local x1,z1,x2,z2 = GetArea(land)
    return Vector3.new(math.random(x1,x2), land.Position.Y+0.5, math.random(z1,z2))
end

-- Equip helper
local function findSeedInBackpack(name)
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name == name then return tool end
    end
end

--// GUI Creation
-- Удаляем старое
for _, child in ipairs(GuiParent:GetChildren()) do if child.Name == "WaveGui" then child:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "WaveGui"
ScreenGui.ResetOnSpawn     = false
ScreenGui.Parent           = GuiParent

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size             = UDim2.new(0,320,0,400)
-- Изначально открыто
MainFrame.Position         = UDim2.new(0,0,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10,10,20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.ClipsDescendants = true

-- Arrow toggles не нужны, сразу открываем GUI

local Content = Instance.new("Frame", MainFrame)
Content.Size              = UDim2.new(1,0,1,-40)
Content.Position          = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1

local pages = {}
local function switchPage(name)
    for _, p in pairs(pages) do p.Visible = false end
    pages[name].Visible = true
end

-- Home
local home = Instance.new("Frame", Content)
home.Size = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pages["home"] = home

local buyBtn = Instance.new("TextButton", home)
buyBtn.Size              = UDim2.new(0,280,0,50)
buyBtn.Position          = UDim2.new(0,20,0,20)
buyBtn.Text              = "AutoBuySeeds 🌱"
buyBtn.Font              = Enum.Font.Code
buyBtn.TextSize          = 18
buyBtn.BackgroundColor3  = Color3.fromRGB(20,20,40)
buyBtn.TextColor3        = Color3.new(1,1,1)
buyBtn.MouseButton1Click:Connect(function() switchPage("buy") end)

local plantBtn = Instance.new("TextButton", home)
plantBtn.Size              = UDim2.new(0,280,0,50)
plantBtn.Position          = UDim2.new(0,20,0,90)
plantBtn.Text              = "AutoPlantSeeds 🌱"
plantBtn.Font              = Enum.Font.Code
plantBtn.TextSize          = 18
plantBtn.BackgroundColor3  = Color3.fromRGB(20,20,40)
plantBtn.TextColor3        = Color3.new(1,1,1)
plantBtn.MouseButton1Click:Connect(function() switchPage("plant") end)

-- Buy Page
local buy = Instance.new("Frame", Content)
buy.Size = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible = false
pages["buy"] = buy
-- Back
local backBuy = Instance.new("TextButton", buy)
backBuy.Size = UDim2.new(0,60,0,30)
backBuy.Position = UDim2.new(0,20,0,20)
backBuy.Text = "<- Back"
backBuy.MouseButton1Click:Connect(function() switchPage("home") end)
-- (Добавьте элементы Buy как ранее)

-- Plant Page
local plant = Instance.new("Frame", Content)
plant.Size = UDim2.new(1,0,1,0)
plant.BackgroundTransparency = 1
plant.Visible = false
pages["plant"] = plant
local backPlant = Instance.new("TextButton", plant)
backPlant.Size = UDim2.new(0,60,0,30)
backPlant.Position = UDim2.new(0,20,0,20)
backPlant.Text = "<- Back"
backPlant.MouseButton1Click:Connect(function() switchPage("home") end)

-- Drop list
local selectedPlant = {}
local frame = Instance.new("Frame", plant)
frame.Size = UDim2.new(0,280,0,100)
frame.Position = UDim2.new(0,20,0,70)
frame.BackgroundColor3 = Color3.fromRGB(25,25,45)
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
local layout = Instance.new("UIListLayout", scroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local label = Instance.new("TextLabel", plant)
label.Size = UDim2.new(0,280,0,40)
label.Position = UDim2.new(0,20,0,180)
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
        for k,v in pairs(selectedPlant) do if v then table.insert(t,k) end end
        label.Text = "Выбрано: "..table.concat(t, ", ")
    end)
end
scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
-- Toggle & Clear
local toggle = Instance.new("TextButton", plant)
toggle.Size = UDim2.new(0,60,0,40)
toggle.Position = UDim2.new(0,20,0,230)
toggle.Text = "?"
toggle.Font = Enum.Font.Code
toggle.TextSize = 24
toggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
toggle.TextColor3 = Color3.new(1,1,1)
local toggleLabel = Instance.new("TextLabel", plant)
toggleLabel.Size = UDim2.new(1,-100,0,40)
toggleLabel.Position = UDim2.new(0,90,0,230)
toggleLabel.Text = "AutoPlantSeeds 😋"
toggleLabel.Font = Enum.Font.Code
toggleLabel.TextSize = 16
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextColor3 = Color3.new(1,1,1)
local clearBtn = Instance.new("TextButton", plant)
clearBtn.Size = UDim2.new(0,40,0,40)
clearBtn.Position = UDim2.new(1,-60,0,230)
clearBtn.Text = "X"
clearBtn.Font = Enum.Font.Code
clearBtn.TextSize = 18
clearBtn.TextColor3 = Color3.new(1,0.6,0.6)
clearBtn.BackgroundColor3 = Color3.fromRGB(45,25,25)
clearBtn.BorderSizePixel = 0
clearBtn.MouseButton1Click:Connect(function()
    table.clear(selectedPlant)
    for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(35,35,55) end end
    label.Text = "Выбрано: "
end)

_G.AutoPlantEnabled = false
_G.AutoPlantSeeds   = {}
toggle.MouseButton1Click:Connect(function()
    _G.AutoPlantEnabled = not _G.AutoPlantEnabled
toggle.Text = _G.AutoPlantEnabled and "👍" or "?"
    _G.AutoPlantSeeds = {}
    for k,v in pairs(selectedPlant) do if v then table.insert(_G.AutoPlantSeeds, k) end end
end)

-- AutoPlant Loop
spawn(function()
    while wait(0.5) do
        if _G.AutoPlantEnabled then
            for _, seed in ipairs(_G.AutoPlantSeeds) do
                local tool = findSeedInBackpack(seed)
                if tool then
                    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(tool)
                        wait(0.1)
                        PlantRE:FireServer(GetRandomFarmPoint(), seed)
                    end
                end
            end
        end
    end
end)

-- Show home
switchPage("home")
