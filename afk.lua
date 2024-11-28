local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

local function monitorIdleTime()
    -- Задержка только при первом входе
    task.wait(15)
    print("HUY ALO ALO")

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local idleTime = 0
    local threshold = 15 -- время в секундах для переподключения
    local lastPosition = humanoidRootPart.Position
    local lastVelocity = humanoidRootPart.Velocity

    -- Функция для проверки движения
    local function isMoving()
        return humanoid.MoveDirection.Magnitude > 0.1 or (lastVelocity.Magnitude > 0.1)
    end

    while true do
        wait(1) -- проверка каждую секунду
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
            -- Переподключение к текущему месту
            local placeId = game.PlaceId
            
            TeleportService:Teleport(placeId, player)
            break -- выходим из цикла после переподключения
        end
        
        -- Ожидаем, что персонаж может умереть и снова появиться
        if not character or not character:IsDescendantOf(workspace) then
            break -- выходим из цикла, если персонаж умер
        end
    end
end

-- Подписываемся на событие CharacterAdded, чтобы отслеживать смерть персонажа
player.CharacterAdded:Connect(monitorIdleTime)

-- Запускаем мониторинг при первом входе в игру
monitorIdleTime()
