print("Started afk-kick")

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

-- Функция для повторной попытки загрузки данных, если не удалось загрузить с первого раза
local function tryLoadFile()
    local success, err = pcall(function()
        AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
    end)

    if not success then
        print("Failed to load file, retrying...")
        wait(1)  -- Задержка перед повторной попыткой
        tryLoadFile()  -- Рекурсивно пытаемся загрузить файл снова
    end
end

tryLoadFile()  -- Запускаем загрузку файла

if #AllIDs == 0 then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end

-- Функция для поиска серверов с наименьшим количеством игроков
function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        local players = tonumber(v.playing)
        
        -- Ищем серверы с количеством игроков от 1 до 4
        if tonumber(v.maxPlayers) > players and players >= 1 and players <= 4 then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end

            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    -- Телепортация на сервер с минимальным количеством игроков
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

-- Функция для мониторинга бездействия
local function monitorIdleTime()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local idleTime = 0
    local threshold = 20  -- время в секундах для переподключения
    local lastPosition = humanoidRootPart.Position
    local lastVelocity = humanoidRootPart.Velocity

    -- Функция для проверки движения
    local function isMoving()
        return humanoid.MoveDirection.Magnitude > 0.1 or lastVelocity.Magnitude > 0.1
    end

    while true do
        task.wait(1)  -- проверка каждую секунду
        print("Я слежу чтобы ты на месте не стоял, 20 секунд")

        local currentPosition = humanoidRootPart.Position
        local currentVelocity = humanoidRootPart.Velocity

        -- Проверяем, изменились ли координаты и скорость
        if (currentPosition - lastPosition).Magnitude < 0.1 and currentVelocity.Magnitude < 0.1 then
            idleTime = idleTime + 1  -- Увеличиваем счетчик бездействия
        else
            idleTime = 0  -- Сбрасываем счетчик, если персонаж движется или скорость больше нуля
            lastPosition = currentPosition  -- Обновляем последнюю позицию
        end

        lastVelocity = currentVelocity  -- Обновляем последнюю скорость

        if idleTime >= threshold then
            -- После 20 секунд бездействия выполняем телепортацию
            TPReturner()
            break  -- Выходим из цикла после выполнения телепортации
        end

        -- Проверка на смерть персонажа
        if not character or not character:IsDescendantOf(workspace) then
            break  -- Выходим из цикла, если персонаж умер
        end
    end
end

-- Подписка на событие появления персонажа, чтобы запускать мониторинг
game.Players.LocalPlayer.CharacterAdded:Connect(monitorIdleTime)

-- Запуск мониторинга при первом входе в игру
monitorIdleTime()
