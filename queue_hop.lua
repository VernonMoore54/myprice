repeat
    task.wait(0.1)
until game:IsLoaded()



local script = [[
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
]]



local teleportFunc = queueonteleport or queue_on_teleport
if teleportFunc then
    teleportFunc([[
        repeat
        task.wait(0.1)
        until game:IsLoaded()
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/queue_hop-0.lua"))()
    ]])
end

script()

