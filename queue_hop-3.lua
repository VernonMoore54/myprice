repeat
    task.wait(1)
until game:IsLoaded()


    local ZOV = loadstring(game:HttpGet('https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/queue_hop-2.lua'))()

    queue_on_teleport(
        ZOV
    )


local Players = game:GetService('Players')
local TeleportService = game:GetService('TeleportService')

local player = Players.LocalPlayer

-- Ждём персонажа
local char = player.Character or player.CharacterAdded:Wait()

while true do
    if game.PlaceId == 12807820316 then
        TeleportService:Teleport(2809202155, player)
    elseif game.PlaceId == 2809202155 then
        TeleportService:Teleport(12807820316, player)
    end
    task.wait(3)
end
