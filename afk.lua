local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage:WaitForChild("GetServerList")

local function monitorIdleTime()
    -- Задержка только при первом входе
    task.wait(15)
    print("HUY ALO ALO")

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local idleTime = 0
    local threshold = 20 -- время в секундах для переподключения
    local lastPosition = humanoidRootPart.Position
    local lastVelocity = humanoidRootPart.Velocity

    -- Функция для проверки движения
    local function isMoving()
        return humanoid.MoveDirection.Magnitude > 0.1 or (lastVelocity.Magnitude > 0.1)
    end

    while true do
        task.wait(1) -- проверка каждую секунду
        print("HUY PRIOM PRIOM")

        local currentPosition = humanoidRootPart.Position
        local currentVelocity = humanoidRootPart.Velocity

        -- Проверяем, изменились ли координаты и скорость
        if (currentPosition - lastPosition).Magnitude < 0.1 and (currentVelocity.Magnitude < 0.1) then
            idleTime = idleTime + 1 -- Увеличиваем счетчик бездействия
        else
            idleTime = 0 -- Сбрасываем счетчик, если персонаж движется или скорость больше нуля
            lastPosition = currentPosition -- Обновляем последнюю позицию
        end

        lastVelocity = currentVelocity -- Обновляем последнюю скорость

        if idleTime >= threshold then
            -- Запрос списка серверов с наименьшим количеством игроков
            RemoteEvent:FireServer()

            break -- выходим из цикла после запроса списка серверов
        end
        
        -- Ожидаем, что персонаж может умереть и снова появиться
        if not character or not character:IsDescendantOf(workspace) then
            break -- выходим из цикла, если персонаж умер
        end
    end
end

-- Обработка ответа от сервера с информацией о серверах
RemoteEvent.OnClientEvent:Connect(function(servers)
    local targetServerId = nil
    local minPlayersCount = math.huge

    for _, server in ipairs(servers) do
        if server.PlayerCount < minPlayersCount then
            minPlayersCount = server.PlayerCount
            targetServerId = server.Id
        end
    end

    if targetServerId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, player)
    end
end)

-- Подписываемся на событие CharacterAdded, чтобы отслеживать смерть персонажа
player.CharacterAdded:Connect(monitorIdleTime)

-- Запускаем мониторинг при первом входе в игру
monitorIdleTime()
