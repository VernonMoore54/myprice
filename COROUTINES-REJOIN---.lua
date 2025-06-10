local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

task.wait(25)

if game:GetService("Players").LocalPlayer.PlayerGui.LoadingScreenPrefab then

while true do
TeleportService:Teleport(116495829188952, localPlayer)
task.wait(1)
end

else

while true do
task.wait(3)
end
end
