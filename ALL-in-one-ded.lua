--[[
  Скрипт для автоматического клика после загрузки игры и интерфейса
  Последовательность действий:
  1. Ждём полной загрузки игры
  2. Ждём завершения загрузки интерфейса (когда значение достигнет 2500)
  3. Совершаем 3 клика в центре экрана с маленькой задержкой
]]

-- Получаем сервисы которые будем использовать
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- Функция для безопасного ожидания условия
local function waitUntilCondition(condition)
    repeat
        task.wait(1) -- Ждём 1 секунду перед следующей проверкой
    until condition()
end

-- Функция для имитации клика мышью
local function simulateClick()
    -- Получаем размеры экрана (координаты от 0 до 1)
    local screenCenter = Vector2.new(0.5, 0.5)
    
    -- Имитируем нажатие левой кнопки мыши
    VirtualInputManager:SendMouseButtonEvent(
        screenCenter.X,  -- X координата (50% ширины экрана)
        screenCenter.Y,  -- Y координата (50% высоты экрана)
        0,               -- Код левой кнопки мыши (0 = левая, 1 = правая)
        true,            -- Состояние кнопки (нажата)
        game            -- Игровый объект
    )
    
    -- Имитируем отпускание кнопки через 0.01 секунды
    task.wait(0.01)
    VirtualInputManager:SendMouseButtonEvent(
        screenCenter.X,
        screenCenter.Y,
        0,
        false,
        game
    )
end

-- Основная логика скрипта
local function main()
    -- Шаг 1: Ждём полной загрузки игры
    waitUntilCondition(function()
        return game:IsLoaded()
    end)
    
    -- Шаг 2: Ждём когда значение Loaded станет 2500
    local player = Players.LocalPlayer
    waitUntilCondition(function()
        -- Проверяем существование объекта перед доступом
        if player and player:FindFirstChild("PlayerGui") then
            local gui = player.PlayerGui:FindFirstChild("Intro_SCREEN")
            if gui and gui:FindFirstChild("Frame") then
                return gui.Frame.Loaded.Value == 2500
            end
        end
        return false
    end)
    
    -- Шаг 3: Выполняем 3 клика с задержкой 0.05 секунд между ними
    for i = 1, 3 do
        simulateClick()
        if i < 3 then -- Не ждём после последнего клика
            task.wait(0.05)
        end
    end
end

-- Запускаем основную функцию
main()
