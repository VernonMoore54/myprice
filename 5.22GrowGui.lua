--// Services
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents  = ReplicatedStorage:WaitForChild("GameEvents")
local SeedData    = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData"))

--// Configurations
-- Автопосадка: список семян и интервалы
local autoPlantSeeds    = {"Coconut", "Bamboo"}
local autoPlantInterval = 0.5  -- сек между посадками
local equipInterval     = 3    -- сек между повторным взятием в руки

--// Собираем доступные семена для покупки
local SeedStock = {}
for key, data in pairs(SeedData) do
    if data.DisplayInShop then
        SeedStock[key] = true
    end
end

--// Удаление старого GUI
local old = PlayerGui:FindFirstChild("WaveGui")
if old then old:Destroy() end

--// Поиск фермы игрока
local MyFarm = (function()
    local Farms = workspace:WaitForChild("Farm")
    for _, farm in ipairs(Farms:GetChildren()) do
        local imp = farm:FindFirstChild("Important")
        if imp and imp.Data.Owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end)()
assert(MyFarm, "Ферма не найдена")

--// Создание GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name            = "WaveGui"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size             = UDim2.new(0, 320, 0, 400)
MainFrame.Position         = UDim2.new(0, -320, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel       = 0
MainFrame.ClipsDescendants      = true

local bg = Instance.new("ImageLabel", MainFrame)
bg.Size              = UDim2.new(1,0,1,0)
bg.Image             = "rbxassetid://70998571392678"
bg.BackgroundTransparency = 1
bg.ImageTransparency = 0.2
bg.ScaleType         = Enum.ScaleType.Crop
bg.ZIndex            = 0

local Header = Instance.new("TextLabel", MainFrame)
Header.Size             = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = Color3.fromRGB(25,25,40)
Header.Text             = "🌱 Wave Garden"
Header.TextColor3       = Color3.new(1,1,1)
Header.Font             = Enum.Font.Code
Header.TextSize         = 18
Header.ZIndex            = 1

local Content = Instance.new("Frame", MainFrame)
Content.Size             = UDim2.new(1,0,1,-40)
Content.Position         = UDim2.new(0,0,0,40)
Content.BackgroundTransparency = 1
Content.ZIndex           = 1

--// Выезжающие стрелки
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
RightArrow.Visible          = false
RightArrow.BackgroundColor3 = Color3.fromRGB(15,15,25)
RightArrow.TextColor3       = Color3.new(0.8,0.8,1)
RightArrow.Font             = Enum.Font.Code
RightArrow.TextSize         = 20

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

--// Страницы
local pages  = {}
local current
local function switchPage(name)
    if current then pages[current].Visible = false end
    pages[name].Visible = true
    current = name
end

-- Home
local home = Instance.new("Frame", Content)
home.Size             = UDim2.new(1,0,1,0)
home.BackgroundTransparency = 1
pages["home"]         = home

-- Кнопка AutoBuy
local autoBuyBtn = Instance.new("TextButton", home)
autoBuyBtn.Size             = UDim2.new(0,280,0,50)
autoBuyBtn.Position         = UDim2.new(0,20,0,20)
autoBuyBtn.Text             = "AutoBuySeeds 🌱"
autoBuyBtn.Font             = Enum.Font.Code
autoBuyBtn.TextColor3       = Color3.new(1,1,1)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(20,20,40)

-- Кнопка AutoPlant
local autoPlantBtn = Instance.new("TextButton", home)
autoPlantBtn.Size             = UDim2.new(0,280,0,50)
autoPlantBtn.Position         = UDim2.new(0,20,0,90)
autoPlantBtn.Text             = "AutoPlantSeeds 🌱"
autoPlantBtn.Font             = Enum.Font.Code
autoPlantBtn.TextColor3       = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20,20,40)

-- Buy page
local buy = Instance.new("Frame", Content)
buy.Size             = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible          = false
pages["buy"]         = buy

local backBuy = Instance.new("ImageButton", buy)
backBuy.Size    = UDim2.new(0,28,0,28)
backBuy.Position= UDim2.new(0,10,0,10)
backBuy.Image   = "rbxassetid://4952231049"
backBuy.BackgroundTransparency = 1
backBuy.MouseButton1Click:Connect(function() switchPage("home") end)

-- ... (здесь весь код покупки семян без изменений) ...

-- AutoPlant page
local plant = Instance.new("Frame", Content)
plant.Size             = UDim2.new(1,0,1,0)
plant.BackgroundTransparency = 1
plant.Visible          = false
pages["autoPlant"]     = plant

local backPlant = Instance.new("ImageButton", plant)
backPlant.Size     = UDim2.new(0,28,0,28)
backPlant.Position = UDim2.new(0,10,0,10)
backPlant.Image    = "rbxassetid://4952231049"
backPlant.BackgroundTransparency = 1
backPlant.MouseButton1Click:Connect(function() switchPage("home") end)

-- Toggle для AutoPlant
local toggleFrame = Instance.new("Frame", plant)
toggleFrame.Size             = UDim2.new(0,280,0,60)
toggleFrame.Position         = UDim2.new(0,20,0,60)
toggleFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)

local togglePlant = Instance.new("TextButton", toggleFrame)
togglePlant.Size             = UDim2.new(0,60,0,40)
togglePlant.Position         = UDim2.new(0,10,0,10)
togglePlant.Font             = Enum.Font.Code
togglePlant.TextSize         = 24
togglePlant.Text             = "?"
togglePlant.BackgroundColor3 = Color3.fromRGB(35,35,55)
togglePlant.TextColor3       = Color3.new(1,1,1)

local toggleLabel = Instance.new("TextLabel", toggleFrame)
toggleLabel.Size             = UDim2.new(1,-80,0,40)
toggleLabel.Position         = UDim2.new(0,80,0,10)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text             = "AutoPlant toggle 😋"
toggleLabel.TextColor3       = Color3.new(1,1,1)
toggleLabel.Font             = Enum.Font.Code
toggleLabel.TextSize         = 16
toggleLabel.TextXAlignment   = Enum.TextXAlignment.Left

-- Логика автопосадки
local plantEnabled = false
togglePlant.MouseButton1Click:Connect(function()
    plantEnabled = not plantEnabled
    togglePlant.Text = plantEnabled and "👍" or "?"
    if plantEnabled then
        spawn(function()
            local lastEquip = 0
            while plantEnabled do
                for _, seedName in ipairs(autoPlantSeeds) do
                    if not plantEnabled then break end
                    local toolName = seedName .. " Seed"
                    -- ищем в рюкзаке или уже в руках
                    local tool = backpack:FindFirstChild(toolName) or LocalPlayer.Character:FindFirstChild(toolName)
                    if tool then
                        local now = tick()
                        if now - lastEquip >= equipInterval then
                            tool.Parent = LocalPlayer.Character
                            lastEquip = now
                        end
                        -- находим точку посадки Side="Right"
                        for _, loc in ipairs(MyFarm.Important.Plant_Locations.Can_Plant:GetChildren()) do
                            if loc:GetAttribute("Side") == "Right" then
                                local p = loc.Position
                                -- отправляем запрос на посадку
                                GameEvents.Plant_RE:FireServer(vector.create(p.X, p.Y, p.Z), seedName)
                                break
                            end
                        end
                        wait(autoPlantInterval)
                    end
                end
                wait(autoPlantInterval)
            end
        end)
    end
end)

-- Подключаем переключатели страниц
autoBuyBtn.MouseButton1Click   :Connect(function() switchPage("buy")    end)
autoPlantBtn.MouseButton1Click :Connect(function() switchPage("autoPlant") end)

-- Сразу показываем главную
switchPage("home")
