
task.wait()

setfpscap(15)


task.wait(360)

while true do
    
task.wait(2)
-- Получаем необходимые сервисы
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- Сохраняем ссылку на локального игрока
local player = Players.LocalPlayer

-- Создаём и запускаем корутину
local teleportCoroutine = coroutine.create(function()
    -- Ждём 6 минуты (360 секунд)
    -- Телепортируем игрока в placeId 116495829188952
    TeleportService:Teleport(116495829188952, player)
end)

coroutine.resume(teleportCoroutine)

end
