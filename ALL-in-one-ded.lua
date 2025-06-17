-- Этот скрипт написан на Luau (язык для Roblox) и делает следующее:
-- 1. Ждет, пока камера не прикрепится к персонажу локального игрока
-- 2. Нажимает клавишу пробела (Space) с интервалом 0.05 секунды
-- 3. Работает как на компьютере, так и на мобильных устройствах

-- Подключаем необходимые сервисы
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Получаем локального игрока
local LocalPlayer = Players.LocalPlayer

-- Ждем, пока персонаж игрока не появится
while not LocalPlayer.Character do
    task.wait() -- Задержка, чтобы не перегружать игру
end

-- Получаем персонажа и камеру
local Character = LocalPlayer.Character
local Camera = Workspace.CurrentCamera

-- Ждем, пока камера не будет привязана к персонажу
-- Проверяем, совпадает ли объект, к которому привязана камера, с персонажем
while Camera.CameraSubject ~= Character.Humanoid do
    -- Эмулируем нажатие и отпускание клавиши пробела
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.01) -- Небольшая задержка для имитации нажатия
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    
    -- Задержка 0.05 секунды между нажатиями
    task.wait(0.05)
end

-- Сообщение в консоль для отладки (можно увидеть в F9)
print("Камера прикрепилась к персонажу, нажатия пробела остановлены!")
