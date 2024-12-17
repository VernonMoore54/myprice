local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

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

local function monitorIdleTime()
    print("Йоу, я заработал")
    task.wait(10)  -- Задержка перед началом мониторинга

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local idleTime = 0
    local threshold = 30  -- Время в секундах для проверки на бездействие
    local lastPosition = humanoidRootPart.Position
    local lastConnectionTime = idleData.lastConnectionTime  -- Время последнего подключения

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

for i = 1, 1 do
    task.spawn(function()
        task.wait(5) -- Задержка перед выполнением кода
        pcall(function()
            getgenv().standList = {
                ["The World"] = true,
                ["Star Platinum"] = true,
                ["Star Platinum: The World"] = true,
                ["Crazy Diamond"] = true,
                ["King Crimson"] = true,
                ["King Crimson Requiem"] = true
            }
            getgenv().waitUntilCollect = 0.75
            getgenv().sortOrder = "Asc"
            getgenv().lessPing = false
            getgenv().autoRequiem = true
            getgenv().NPCTimeOut = 15
            getgenv().HamonCharge = 70
            getgenv().webhook = "https://discord.com/api/webhooks/1288789321192570972/nmuQYBwSVNjtZVp0afW2DACovpQ59kphCs0bWMi4bR9Wea4UavtbFjhxeuK8OLoQSqnI"

            loadstring(game:HttpGet("https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/iou.lua"))()
        end)
    end)
    task.wait(1) -- Задержка между выполнениями
end
