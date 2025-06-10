
-- Скрипт для автоматического телепорта после загрузочного экрана

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Пытаемся дождаться появления ScreenGui LoadingScreenPrefab (таймаут 20 секунд)
local playerGui = localPlayer:WaitForChild("PlayerGui")
local loadingGui = playerGui:WaitForChild("LoadingScreenPrefab", 10)

-- Если объект не найден, выходим из скрипта
if not loadingGui then
    return
end

-- Дождаться 20 секунд после появления GUI
task.wait(20)

-- Проверяем, всё ещё ли GUI активен
if loadingGui.Enabled then
    -- Запускаем бесконечный цикл с задержкой 1 секунда
    while true do
        TeleportService:Teleport(116495829188952, localPlayer)
        task.wait(1)
    end
end
