--// Настройки
local PLACE_ID = 116495829188952
local KEYWORDS = {
    "You","you","Kicked","kicked","Disconnected","disconnected",
    "conn","Error","error","Code","code","message",
    "ID=17","id=17","ID","id","Failed","Teleport"
}

--// Сервисы
local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local NetworkClient   = game:GetService("NetworkClient")
local CoreGui         = game:GetService("CoreGui")

--// Функция проверки текста на ключи
local function shouldHop(text)
    if not text then return false end
    for _, kw in ipairs(KEYWORDS) do
        -- plain find, без паттернов
        if string.find(text, kw, 1, true) then
            return true
        end
    end
    return false
end

--// Мягкий вызов телепорта (чтобы скрипт не падал)
local function teleportHop()
    pcall(function()
        TeleportService:Teleport(PLACE_ID, Players.LocalPlayer)
    end)
end

---------------------------------------------------------------
-- ВАРИАНТ 1: ловим появление любых GUI-ошибок в CoreGui
---------------------------------------------------------------
coroutine.wrap(function()
    CoreGui.DescendantAdded:Connect(function(child)
        -- смотрим на все окна, содержащие в названии Error/Prompt
        if child.Name:match("Error") or child.Name:match("Prompt") then
            coroutine.wrap(function()
                -- ищем текстовый лейбл
                local lbl = child:FindFirstChildWhichIsA("TextLabel", true)
                if not lbl then
                    lbl = child:FindFirstChild("ErrorMessage", true)
                end
                if lbl then
                    -- ждём, пока Roblox заполнит настоящий текст
                    repeat task.wait() until lbl.Text and lbl.Text ~= "" and lbl.Text ~= "Label"
                    if shouldHop(lbl.Text) then
                        teleportHop()
                    end
                end
            end)()
        end
    end)
end)()

---------------------------------------------------------------
-- ВАРИАНТ 2: низкоуровневое событие обрывов соединения
---------------------------------------------------------------
coroutine.wrap(function()
    NetworkClient.ConnectionFailed:Connect(function(msg)
        if shouldHop(msg) then
            teleportHop()
        end
    end)
end)()

---------------------------------------------------------------
-- ВАРИАНТ 3: TeleportInitFailed (если доступно)
---------------------------------------------------------------
if TeleportService.TeleportInitFailed then
    coroutine.wrap(function()
        TeleportService.TeleportInitFailed:Connect(function(msg)
            if shouldHop(msg) then
                teleportHop()
            end
        end)
    end)()
end

---------------------------------------------------------------
-- ВАРИАНТ 4: watchdog-таймаут на stage «Joining Server»
---------------------------------------------------------------
coroutine.wrap(function()
    if not game:IsLoaded() then
        local start = tick()
        -- ждём загрузки, но не больше 15 секунд
        repeat task.wait(1) until game:IsLoaded() or tick() - start > 15
        if not game:IsLoaded() then
            teleportHop()
        end
    end
end)()

---------------------------------------------------------------
-- ВАРИАНТ 5: TeleportError (если доступно)
---------------------------------------------------------------
if TeleportService.TeleportError then
    coroutine.wrap(function()
        TeleportService.TeleportError:Connect(function(msg)
            if shouldHop(msg) then
                teleportHop()
            end
        end)
    end)()
end
