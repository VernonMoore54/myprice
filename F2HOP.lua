local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Api = "https://games.roblox.com/v1/games/"

local _place = game.PlaceId
local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"

-- Функция для получения списка серверов
function ListServers(cursor)
    local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
    return Http:JSONDecode(Raw)
end

-- Функция для поиска сервера с меньшей задержкой и выполнения перехода
local function teleportToLowPingServer()
    while task.wait() do
        pcall(function()
            local Server, Next; repeat
                local Servers = ListServers(Next)
                for _, s in ipairs(Servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then -- Проверяем, что это другой сервер
                        Server = s
                        break
                    end
                end
                Next = Servers.nextPageCursor
            until Server

            if Server then
                TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)

                -- Если телепортация не удалась, пробуем снова
                TPS.TeleportInitFailed:Connect(function()
                    TPS:TeleportToPlaceInstance(_place, Server.id, game.Players.LocalPlayer)
                end)

                repeat task.wait() until game.JobId ~= game.JobId
            end
        end)
    end
end

-- Подключение к событию нажатия клавиши
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F2 then
        teleportToLowPingServer() -- Запускаем сервер-хоп при нажатии F2
    end
end)
