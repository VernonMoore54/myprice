local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Api = "https://games.roblox.com/v1/games/"

local _place = game.PlaceId
local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"

-- Функция для получения списка серверов
function ListServers(cursor)
    local success, result
    repeat
        success, result = pcall(function()
            return game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        end)

        if not success then
            if string.find(result, "429") then
                warn("Превышен лимит запросов. Ожидание...")
                task.wait(5) -- Ожидание перед повторной попыткой
            else
                error("Ошибка при получении серверов: " .. result)
            end
        end
    until success

    return Http:JSONDecode(result)
end

-- Функция для поиска сервера с меньшим количеством игроков и выполнения перехода
local function teleportToServerWithFewestPlayers()
    local visitedServers = {}
    local foundServer = false

    while not foundServer do
        local Next;
        repeat
            local Servers = ListServers(Next)
            for _, s in ipairs(Servers.data) do
                if s.playing < s.maxPlayers and not visitedServers[s.id] then -- Проверяем, что сервер не посещался
                    visitedServers[s.id] = true
                    TPS:TeleportToPlaceInstance(_place, s.id, game.Players.LocalPlayer)
                    foundServer = true
                    break
                end
            end
            Next = Servers.nextPageCursor
            task.wait(0.5) -- Задержка между запросами для снижения нагрузки
        until not Next or foundServer

        if not foundServer then
            warn("Не удалось найти подходящий сервер. Повторная попытка...")
            task.wait(1)
        end
    end
end

-- Подключение к событию нажатия клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F2 then
        print("Инициализация сервер-хопа...")
        teleportToServerWithFewestPlayers() -- Запускаем сервер-хоп при нажатии F2
    end
end)
