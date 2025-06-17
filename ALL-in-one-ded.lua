local VirtualInputManager = game:GetService("VirtualInputManager")
local player = game.Players.LocalPlayer

-- Ждём загрузки игры
repeat
    task.wait(1)
until game:IsLoaded()

-- Ждём появления персонажа
while not player.Character do
    task.wait()
end
local character = player.Character

-- Нажимаем Space 10 раз с задержкой 0.5 секунды между нажатиями
for i = 1, 10 do
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, nil)
    task.wait(0.01) -- Короткая задержка для эмуляции нажатия
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, nil)
    task.wait(0.5) -- Задержка между нажатиями
end

-- Убиваем персонажа
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.Health = 0
end

-- Ждём возрождения персонажа
player.CharacterAdded:Wait()

-- Зажимаем W на 2 секунды
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
task.wait(2)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
