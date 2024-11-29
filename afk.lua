local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local fileName = "IdleTimeData.json"  -- Имя файла для хранения данных
local idleData = {}

-- Попытка загрузить данные из файла
local success, err = pcall(function()
    idleData = HttpService:JSONDecode(readfile(fileName))  -- Чтение данных из файла
end)

-- Если файл не был загружен, создаем новый с текущими данными
if not success then
    print("Не удалось загрузить файл, создаем новый...")
    idleData = {
        lastIdleTime = 0,  -- Последнее время бездействия
        lastConnectionTime = os.time(),  -- Время последнего подключения
    }
    writefile(fileName, HttpService:JSONEncode(idleData))  -- Запись данных в файл
end

local function monitorIdleTime()
    print("Йоу, я заработал")
    task.wait(15)  -- Задержка перед началом мониторинга

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local idleTime = 0
    local threshold = 15  -- Время в секундах для переподключения
    local lastPosition = humanoidRootPart.Position
    local lastConnectionTime = idleData.lastConnectionTime  -- Время последнего подключения

    -- Проверяем прошло ли достаточно времени с последнего подключения
    if os.time() - lastConnectionTime < 60 then
        print("Переподключение не требуется, прошло слишком мало времени.")
        return
    end

    while true do
        wait(1)  -- Проверка каждую секунду
        print("Йоу, я слежу 15 секунд")

        local currentPosition = humanoidRootPart.Position

        -- Проверяем, изменились ли координаты
        if (currentPosition - lastPosition).Magnitude < 0.1 then
            idleTime = idleTime + 1
        else
            idleTime = 0  -- Сбрасываем время бездействия, если персонаж двигается
            lastPosition = currentPosition  -- Обновляем последнюю позицию
        end

        if idleTime >= threshold then
            -- Переподключение к текущему месту
            print("Переподключение...")

            -- Обновляем время последнего подключения
            idleData.lastConnectionTime = os.time()

            -- Записываем обновленные данные в файл
            writefile(fileName, HttpService:JSONEncode(idleData))

            -- Телепортация
            local placeId = game.PlaceId
            TeleportService:Teleport(placeId, player)

            break  -- Выходим из цикла после переподключения
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
