-- Укажите ссылку на скрипт, который нужно загружать
local scriptURL = "https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua"

-- Функция для загрузки скрипта
local function loadScript()
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptURL))()
    end)
    if not success then
        warn("Ошибка при загрузке скрипта: " .. err)
    end
end

-- Проверяем, поддерживает ли эксплойт queue_on_teleport
if syn and syn.queue_on_teleport then
    -- Используем queue_on_teleport для авто-загрузки на новом сервере
    syn.queue_on_teleport([[
        loadstring(game:HttpGet("]] .. scriptURL .. [["))()
    ]])
elseif queue_on_teleport then
    -- Альтернативный вариант для эксплойтов с queue_on_teleport
    queue_on_teleport([[
        loadstring(game:HttpGet("]] .. scriptURL .. [["))()
    ]])
else
    warn("Ваш эксплойт не поддерживает queue_on_teleport. Авто-загрузка невозможна.")
end

-- Первоначальная загрузка скрипта
loadScript()
