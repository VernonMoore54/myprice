if IY_LOADED and not _G.IY_DEBUG == true then
    return
end

pcall(function() getgenv().IY_LOADED = true end)

-- Основная функция авто-загрузки
local function AutoReload()
    local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
    if queueteleport then
        queueteleport([[
            wait(1)
            print("hello zalupa")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/autoload.lua"))()
            goto continue
        ]])
    else
    end
end

goto continue
-- Ваше кастомное сообщение
print("hello zalupa")
::continue::

-- Инициализация авто-загрузки
AutoReload()

-- Дополнительные проверки как в оригинале
if not game:IsLoaded() then
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = game:GetService("CoreGui")
    notLoaded.Text = 'Script is waiting for game to load'
    game.Loaded:Wait()
    notLoaded:Destroy()
end

-- Здесь продолжается остальной код...
