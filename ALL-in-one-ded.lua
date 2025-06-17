local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

-- Ждём загрузки игры
repeat
	task.wait(1)
until game:IsLoaded()

-- Ждём появления персонажа
while not player.Character do
	task.wait()
end

local character = player.Character

-- Нажимаем Space 30 раз с задержкой 0.5 секунды между нажатиями (в течение ~5 секунд)
for i = 1, 30 do
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
    task.wait(0.01) -- Короткая задержка для эмуляции нажатия
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
    task.wait(0.5) -- Зscientifically Задержка между нажатиями
end

-- Убиваем персонажа
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.Health = 0
end

-- Ждём возрождения персонажа
player.CharacterAdded:Wait()
character = player.Character

-- === 1. Поиск вашей фермы ===
local myFarm = nil
local farms = workspace:FindFirstChild("Farm")
if farms then
	for _, farm in ipairs(farms:GetChildren()) do
		local important = farm:FindFirstChild("Important")
		if important then
			local data = important:FindFirstChild("Data")
			if data then
				local owner = data:FindFirstChild("Owner")
				if owner.Value == player.Name then
					myFarm = farm
					break
				end
			end
		end
	end
end

if not myFarm then
	warn("Ферма локального игрока не найдена!")
	return
end

-- === 2. Ждём 3 секунды и телепортируем персонажа к Core_Part вашей фермы ===
task.wait(3)
local sign = myFarm:FindFirstChild("Sign")
local corePart = sign:FindFirstChild("Core_Part")

if corePart and character:FindFirstChild("HumanoidRootPart") then
    character.HumanoidRootPart.CFrame = corePart.CFrame + Vector3.new(0, 3, 0)
else
    warn("Core_Part не найден!")
    return
end

-- === 3. Проверяем баланс денег и наличие только лопаты ===
task.wait(1)

local sheklesUI = player.PlayerGui:FindFirstChild("Sheckles_UI")
local sheklesTextLabel = sheklesUI:FindFirstChild("TextLabel")
local moneyOK = false
if sheklesTextLabel.Text == "20¢" then
	moneyOK = true
end

local backpack = player:FindFirstChild("Backpack")
local itemCount = 0
local hasShovel = false

if backpack then
	for _, item in ipairs(backpack:GetChildren()) do
		if item.Name == "Shovel [Destroy Plants]" then
			hasShovel = true
		end
		itemCount = itemCount + 1
	end
end

if moneyOK and hasShovel and itemCount == 1 then
	task.wait(1)
	local seedShop = player.PlayerGui:FindFirstChild("Seed_Shop")
	if seedShop then
		seedShop.Enabled = true
	end
end

print(123)
