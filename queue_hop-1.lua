local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local queueteleport = (syn and syn.queue_on_teleport) 
                     or queue_on_teleport 
                     or (fluxus and fluxus.queue_on_teleport)

-- Функция для самовоспроизводства
local function setupQueue(scriptUrl)
    if queueteleport then
        queueteleport(string.format("loadstring(game:HttpGet('%s'))()", scriptUrl))
    end
end

-- URL твоего скрипта
local SCRIPT_URL = "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/queue_hop.lua"

-- Настройка очереди при телепорте
local TeleportCheck = false
player.OnTeleport:Connect(function(State)
    if not TeleportCheck and queueteleport then
        TeleportCheck = true
        setupQueue(SCRIPT_URL)
    end
end)

-- Ждём персонажа
local char = player.Character or player.CharacterAdded:Wait()

-- Главный цикл хопа
while true do
    if game.PlaceId == 12807820316 then
        TeleportService:Teleport(2809202155, player)
    elseif game.PlaceId == 2809202155 then
        TeleportService:Teleport(12807820316, player)
    end
    task.wait(3)
end
