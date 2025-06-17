-- Этот скрипт написан на Luau (язык для Roblox) и делает следующее:
-- 1. Ждет, пока игра полностью загрузится (game:IsLoaded())
-- 2. Нажимает клавишу пробела (Space) с интервалом 0.05 секунды, пока атрибут Finished_Loading локального игрока не станет true
-- 3. Работает как на компьютере, так и на мобильных устройствах

-- Подключаем необходимые сервисы
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- Получаем локального игрока
local LocalPlayer = Players.LocalPlayer

-- Ждем, пока игра полностью загрузится
-- game:IsLoaded() возвращает true, когда все ресурсы игры готовы

-- Сообщение в консоль для отладки, чтобы знать, что игра загрузилась
print("Игра полностью загрузилась, начинаем проверять атрибут Finished_Loading!")

-- Ждем, пока атрибут Finished_Loading не появится и не станет true
-- Проверяем наличие атрибута и его значение
while not (LocalPlayer:GetAttribute("Finished_Loading") == true) do
    -- Эмулируем нажатие и отпускание клавиши пробела
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.01) -- Короткая задержка для имитации нажатия
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    
    -- Задержка 0.05 секунды между нажатиями
    task.wait(0.05)
end

-- Сообщение в консоль для отладки, чтобы знать, что условие выполнено
print("Атрибут Finished_Loading стал true, нажатия пробела остановлены!")
