local Players = game:GetService("Players")
local KeepInfYield = false
local TeleportCheck = false
local queueteleport = queue_on_teleport or syn and syn.queue_on_teleport

--=== Ваш loadstring для исполнения после телепортации ===--
-- Вставьте вашу ссылку или скрипт в следующий блок:
local script_to_execute = [[
    -- Здесь ваш loadstring
    -- Например:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/queue_hop.lua"))()
]]

-- Функция вызова queue_on_teleport
local function setupTeleportQueue()
    if KeepInfYield and not TeleportCheck and queueteleport then
        TeleportCheck = true
        queueteleport(script_to_execute)
    end
end

-- Перехват события телепорта
Players.LocalPlayer.OnTeleport:Connect(function(state)
    setupTeleportQueue()
end)

-- Команды для управления queue_on_teleport:
-- Активировать очередь после телепорта
function enableQueue()
    if queueteleport then
        KeepInfYield = true
        -- здесь можно добавить сохранение/уведомление
    else
        warn("Ваш эксплойт не поддерживает queue_on_teleport")
    end
end

-- Отключить очередь
function disableQueue()
    if queueteleport then
        KeepInfYield = false
    else
        warn("Ваш эксплойт не поддерживает queue_on_teleport")
    end
end

-- Переключить состояние queue_on_teleport
function toggleQueue()
    if queueteleport then
        KeepInfYield = not KeepInfYield
    else
        warn("Ваш эксплойт не поддерживает queue_on_teleport")
    end
end

--=== Ваш скрипт, который нужно будет исполнять через queue_on_teleport ===--
-- Просто вставьте нужный Lua-код в переменную script_to_execute выше.
