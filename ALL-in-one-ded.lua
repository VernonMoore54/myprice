--[[
    Скрипт для автоматического запуска игры и имитации кликов
    Подробные комментарии для начинающих разработчиков
]]

-- Ожидаем полной загрузки игры
repeat
    task.wait(1) -- Ждём 1 секунду перед повторной проверкой
until game:IsLoaded() -- Проверяем статус загрузки игры

-- Ожидаем завершения прогресс-бара в интерфейсе
local interfacePath = game.Players.LocalPlayer.PlayerGui.Intro_SCREEN.Frame
repeat
    task.wait(1) -- Проверяем значение каждую секунду
until interfacePath.Loaded.Value == 2500 -- Ждём нужного значения

-- Получаем сервис для управления виртуальным вводом
local VirtualInput = game:GetService("VirtualInputManager")

-- Вычисляем центр экрана (ширина и высота экрана Roblox)
local screenCenterX = game:GetService("GuiService"):GetScreenResolution().X / 2
local screenCenterY = game:GetService("GuiService"):GetScreenResolution().Y / 2

-- Совершаем 3 клика с интервалом 0.05 секунды
for i = 1, 3 do
    -- Имитируем нажатие левой кнопки мыши
    VirtualInput:SendMouseButtonEvent(
        screenCenterX,   -- X-координата
        screenCenterY,   -- Y-координата
        0,               -- Номер кнопки (0 - левая)
        true,            -- Состояние: нажатие
        nil              -- Игнорируемый параметр
    )
    
    -- Имитируем отпускание кнопки (обязательно для корректной работы)
    VirtualInput:SendMouseButtonEvent(
        screenCenterX,
        screenCenterY,
        0,
        false,
        nil
    )
    
    -- Пауза между кликами (0.05 секунды)
    if i < 3 then  -- Не ждём после последнего клика
        task.wait(0.05)
    end
end
