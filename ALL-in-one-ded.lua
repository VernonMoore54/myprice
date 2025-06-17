-- Подключаем необходимые сервисы
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Получаем RemoteEvent "Finish_Loading"
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local FinishLoadingEvent = GameEvents:WaitForChild("Finish_Loading")

-- Создаем флаг для отслеживания завершения загрузки
local finishedLoading = false

-- Сохраняем оригинальный метод FireServer
local originalFireServer = FinishLoadingEvent.FireServer

-- Переопределяем FireServer, чтобы отследить вызов
FinishLoadingEvent.FireServer = function(...)
    finishedLoading = true
    originalFireServer(...) -- Вызываем оригинальный метод
end

-- Цикл нажатий Space до завершения загрузки
while not finishedLoading do
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)  -- Нажатие Space
    task.wait(0.01)  -- Короткая задержка для имитации нажатия
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) -- Отпускание Space
    task.wait(0.05)  -- Задержка между нажатиями
end

-- Сообщение об остановке
print("Запрос Finish_Loading выполнен, нажатия Space остановлены!")
