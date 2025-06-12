repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

task.wait()

setfpscap(15)

task.wait(3 * 60)

while true do
    
task.wait(2)

-- Помещаем логику в отдельную функцию
local function killLocalCharacterAfterDelay()
    -- Ждём 5 минут (5 * 60 секунд)

    local player = game.Players.LocalPlayer
    if not player then
        warn("LocalPlayer не найден")
        return
    end

    -- Убедимся, что персонаж загружен
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then
        warn("Character не загружен")
        return
    end

    -- Ищем Humanoid и обнуляем его здоровье
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    else
        warn("Humanoid не найден в Character")
    end
end

-- Создаём и запускаем корутину
local co = coroutine.create(killLocalCharacterAfterDelay)
coroutine.resume(co)

end
