--// Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local SeedDataModule = ReplicatedStorage:WaitForChild("Data"):WaitForChild("SeedData")

-- Конфигурация для Auto Plant
local AUTO_PLANT_SEEDS = {"Coconut", "Bamboo"} -- Семена, которые будут автоматически сажаться

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

-- Поиск любой точки для посадки на ферме
local rightPlantSpot = nil -- Переименовано для ясности, но переменная остается прежней
local plantLocationsFolder = MyFarm.Important.Plant_Locations:WaitForChild("Can_Plant") -- Убедимся, что это существует
for _, spot in ipairs(plantLocationsFolder:GetChildren()) do
    if spot:IsA("BasePart") then -- Удален фильтр по атрибуту "Side"
        rightPlantSpot = spot
        break -- Берем первую найденную точку
    end
end
assert(rightPlantSpot, "Точка посадки 'Can_Plant' не найдена на вашей ферме.")
local plantPosition = rightPlantSpot.Position

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
MainFrame.AnchorPoint = Vector2.new(0, 0.5) -- Центрирование по вертикали

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
LeftArrow.ZIndex = 2 -- Выше MainFrame

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
autoBuyBtn.Name = "AutoBuyButton"

local autoPlantBtn = Instance.new("TextButton", home)
autoPlantBtn.Size = UDim2.new(0,280,0,50)
autoPlantBtn.Position = UDim2.new(0,20,0,80) -- Смещение ниже AutoBuyBtn
autoPlantBtn.Text = "AutoPlant 🌾"
autoPlantBtn.Font = Enum.Font.Code
autoPlantBtn.TextColor3 = Color3.new(1,1,1)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
autoPlantBtn.Name = "AutoPlantButton"

-- Buy page
local buy = Instance.new("Frame", Content)
buy.Size = UDim2.new(1,0,1,0)
buy.BackgroundTransparency = 1
buy.Visible = false
pages["buy"] = buy

local backFromBuy = Instance.new("ImageButton", buy)
backFromBuy.Size = UDim2.new(0,28,0,28)
backFromBuy.Position = UDim2.new(0,10,0,10)
backFromBuy.Image = "rbxassetid://4952231049" -- Стрелка назад
backFromBuy.BackgroundTransparency = 1
backFromBuy.MouseButton1Click:Connect(function()
	switchPage("home")
end)

-- Drop list (for AutoBuy)
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
	updateSelectedText() -- Обновление текста после очистки
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

local autoBuyEnabled = false
toggle.MouseButton1Click:Connect(function()
	autoBuyEnabled = not autoBuyEnabled
	toggle.Text = autoBuyEnabled and "👍" or "?"
end)

spawn(function()
	while true do
		wait(1)
		if not autoBuyEnabled then continue end
		for seed in pairs(selected) do
			if selected[seed] then
				-- Используем pcall для безопасного вызова GameEvents.BuySeedStock
				local success, err = pcall(function()
					GameEvents.BuySeedStock:FireServer(seed)
				end)
				if not success then
					warn("Ошибка при покупке семян " .. seed .. ": " .. err)
				end
			end
		end
	end
end)

autoBuyBtn.MouseButton1Click:Connect(function()
	switchPage("buy")
end)

-- Auto Plant page
local autoPlantPage = Instance.new("Frame", Content)
autoPlantPage.Size = UDim2.new(1,0,1,0)
autoPlantPage.BackgroundTransparency = 1
autoPlantPage.Visible = false
pages["autoPlant"] = autoPlantPage

local backFromAutoPlant = Instance.new("ImageButton", autoPlantPage)
backFromAutoPlant.Size = UDim2.new(0,28,0,28)
backFromAutoPlant.Position = UDim2.new(0,10,0,10)
backFromAutoPlant.Image = "rbxassetid://4952231049" -- Стрелка назад
backFromAutoPlant.BackgroundTransparency = 1
backFromAutoPlant.MouseButton1Click:Connect(function()
	switchPage("home")
end)

local autoPlantToggleFrame = Instance.new("Frame", autoPlantPage)
autoPlantToggleFrame.Size = UDim2.new(0,280,0,60)
autoPlantToggleFrame.Position = UDim2.new(0,20,0,60) -- Смещение ниже кнопки "назад"
autoPlantToggleFrame.BackgroundColor3 = Color3.fromRGB(25,25,45)

local autoPlantToggle = Instance.new("TextButton", autoPlantToggleFrame)
autoPlantToggle.Size = UDim2.new(0,60,0,40)
autoPlantToggle.Position = UDim2.new(0,10,0,10)
autoPlantToggle.Font = Enum.Font.Code
autoPlantToggle.TextSize = 24
autoPlantToggle.Text = "?"
autoPlantToggle.BackgroundColor3 = Color3.fromRGB(35,35,55)
autoPlantToggle.TextColor3 = Color3.new(1,1,1)

local autoPlantToggleLabel = Instance.new("TextLabel", autoPlantToggleFrame)
autoPlantToggleLabel.Size = UDim2.new(1, -80, 0, 40)
autoPlantToggleLabel.Position = UDim2.new(0, 80, 0, 10)
autoPlantToggleLabel.BackgroundTransparency = 1
autoPlantToggleLabel.Text = "AutoPlant Toggle 😋"
autoPlantToggleLabel.TextColor3 = Color3.new(1,1,1)
autoPlantToggleLabel.Font = Enum.Font.Code
autoPlantToggleLabel.TextSize = 16
autoPlantToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local autoPlantEnabled = false
autoPlantToggle.MouseButton1Click:Connect(function()
	autoPlantEnabled = not autoPlantEnabled
	autoPlantToggle.Text = autoPlantEnabled and "👍" or "?"
end)

-- Логика Auto Plant
spawn(function()
	while true do
		wait(0.5) -- Задержка между попытками посадки
		if not autoPlantEnabled then continue end

		-- Проверяем наличие семян в инвентаре игрока (LocalPlayer.Backpack)
		for _, seedName in ipairs(AUTO_PLANT_SEEDS) do
			local seedTool = LocalPlayer.Backpack:FindFirstChild(seedName .. " Seed") -- Пример: "Coconut Seed"
			if seedTool then
				-- Экипируем инструмент (перемещаем в LocalPlayer.Character)
				local success, err = pcall(function()
					seedTool.Parent = LocalPlayer.Character
				end)
				if not success then
					warn("Ошибка при экипировке семян " .. seedName .. ": " .. err)
				else
					-- Отправляем запрос на посадку
					local plantArgs = {
						plantPosition, -- Используем найденную позицию
						seedName
					}
					local plantSuccess, plantErr = pcall(function()
						GameEvents.Plant_RE:FireServer(unpack(plantArgs))
					end)
					if not plantSuccess then
						warn("Ошибка при посадке семян " .. seedName .. ": " .. plantErr)
					end
					-- После успешной посадки или попытки, можно снова убрать инструмент в рюкзак, если нужно,
					-- но обычно игра делает это автоматически или оставляет его экипированным до следующего действия.
					-- Для непрерывной посадки лучше оставить его экипированным или быстро переключать.
					break -- Сажаем только одно семя за цикл, чтобы не спамить
				end
			end
		end
	end
end)

autoPlantBtn.MouseButton1Click:Connect(function()
	switchPage("autoPlant")
end)

-- Изначально отображаем домашнюю страницу
switchPage("home")
