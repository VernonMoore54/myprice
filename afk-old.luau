local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local idleTime = 0

local player = Players.LocalPlayer
local fileName = "IdleTimeData.json"  -- Имя файла для хранения данных
local idleData = {}

-- Функция для безопасной работы с файлами
local function safeReadFile()
    local success, data = pcall(function()
        return readfile(fileName)
    end)
    if success then
        return HttpService:JSONDecode(data)
    else
        return nil
    end
end

local function safeWriteFile(data)
    local success, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    return success, err
end

-- Попытка загрузить данные из файла
idleData = safeReadFile()

-- Если файл не был загружен, создаем новый с текущими данными
if not idleData then
    print("Не удалось загрузить файл, создаем новый...")
    idleData = {
        lastIdleTime = 0,  -- Последнее время бездействия
        lastConnectionTime = os.time(),  -- Время последнего подключения
    }
    safeWriteFile(idleData)  -- Запись данных в файл
end

-- Функция для создания UI элементов
local function createTeleportAndAnchorButtons()
    local screenGui = Instance.new("ScreenGui")
    local teleportButton = Instance.new("TextButton")
    local anchorButton = Instance.new("TextButton")

    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.Name = "TeleportUI"
    screenGui.ResetOnSpawn = false

    teleportButton.Name = "TeleportButton"
    teleportButton.Parent = screenGui
    teleportButton.Text = "Teleport"
    teleportButton.Size = UDim2.new(0, 120, 0, 40)
    teleportButton.Position = UDim2.new(0, 10, 1, -50)
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    teleportButton.TextColor3 = Color3.fromRGB(0, 255, 255)
    teleportButton.TextScaled = true
    teleportButton.BorderSizePixel = 0

    teleportButton.MouseButton1Click:Connect(function()
        print("Телепортация по кнопке")
        idleTime = 31
    end)

    anchorButton.Name = "AnchorButton"
    anchorButton.Parent = screenGui
    anchorButton.Text = "Anchor Parts"
    anchorButton.Size = UDim2.new(0, 120, 0, 40)
    anchorButton.Position = UDim2.new(0, 10, 1, -100)
    anchorButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    anchorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    anchorButton.TextScaled = true
    anchorButton.BorderSizePixel = 0

    anchorButton.MouseButton1Click:Connect(function()
        print("Все части тела персонажа стали зафиксированными.")
        local character = player.Character or player.CharacterAdded:Wait()
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
    end)

    -- Адаптация к изменению размеров окна
    game:GetService("RunService").RenderStepped:Connect(function()
        teleportButton.Position = UDim2.new(0, 10, 1, -50)
        anchorButton.Position = UDim2.new(0, 10, 1, -100)
    end)
end

-- Запуск создания UI элементов
createTeleportAndAnchorButtons()

-- Функция мониторинга времени бездействия
function monitorIdleTime()
    print("Йоу, я заработал")
    task.wait(5)  -- Задержка перед началом мониторинга

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local threshold = 15  -- Время в секундах для проверки на бездействие
    local lastPosition = humanoidRootPart.Position

    while true do
        wait(1)  -- Проверка каждую секунду
        print("Йоу, я слежу 30 секунд")

        local currentPosition = humanoidRootPart.Position

        -- Проверяем, изменились ли координаты
        if (currentPosition - lastPosition).Magnitude < 0.1 then
            idleTime = idleTime + 1
        else
            idleTime = 0  -- Сбрасываем время бездействия, если персонаж двигается
            lastPosition = currentPosition  -- Обновляем последнюю позицию
        end

        if idleTime >= threshold then
            print("Персонаж бездействует 30 секунд, проверяю состояние...")

            -- Обновляем время последнего бездействия
            idleData.lastIdleTime = os.time()

            -- Пробуем обновить данные в файле, пока не удастся
            local success, err
            repeat
                success, err = safeWriteFile(idleData)
                if not success then
                    print("Ошибка записи в файл: " .. err .. ", повторная попытка...")
                    wait(1)  -- Задержка перед повторной попыткой записи
                end
            until success

            print("Данные обновлены в файле.")

            -- Телепортация
            local placeId = game.PlaceId
            TeleportService:Teleport(placeId, player)

            break  -- Выходим из цикла после телепортации
        end

        -- Ожидаем, что персонаж может умереть и снова появиться
        if not character or not humanoidRootPart:IsDescendantOf(workspace) then
            break  -- Выходим из цикла, если персонаж умер
        end
    end
end

-- Подписка на событие CharacterAdded, чтобы отслеживать смерть персонажа
player.CharacterAdded:Connect(monitorIdleTime)

-- Запуск мониторинга при первом входе в игру
monitorIdleTime()
