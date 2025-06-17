-- Этот скрипт написан на Luau (язык для Roblox) и делает следующее:
-- 1. Ждет, пока определенный элемент интерфейса станет видимым
-- 2. Выполняет три клика левой кнопкой мыши в центре экрана
-- 3. Работает как на компьютере, так и на мобильных устройствах

-- Подключаем сервис для эмуляции пользовательских действий
local VirtualUser = game:GetService("VirtualUser")

-- Получаем игрока, который запустил скрипт
local LocalPlayer = game.Players.LocalPlayer

-- Ждем, пока не появится PlayerGui (интерфейс игрока)
while not LocalPlayer.PlayerGui do
    task.wait() -- Задержка, чтобы не перегружать игру
end

-- Путь к нужному элементу интерфейса
local IntroScreen = LocalPlayer.PlayerGui:WaitForChild("Intro_SCREEN")
local Frame = IntroScreen:WaitForChild("Frame")
local SideFrame3 = Frame:WaitForChild("Side_Frame_3")

-- Ждем, пока Side_Frame_3 станет видимым
-- repeat будет повторять проверку каждую секунду, пока условие не выполнится
repeat
    task.wait(1) -- Ждем 1 секунду между проверками
until SideFrame3.Visible == true

-- Когда Side_Frame_3 стал видимым, начинаем клики

-- Получаем размер экрана для вычисления центра
local screenSize = workspace.CurrentCamera.ViewportSize
local centerPoint = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

-- Выполняем три клика с задержкой
for i = 1, 3 do
    -- Эмулируем клик левой кнопкой мыши в центре экрана
    VirtualUser:ClickButton1(centerPoint)
    
    -- Задержка 0.05 секунды между кликами
    task.wait(0.05)
end

-- Сообщение в консоль для отладки (можно увидеть в F9)
print("Скрипт выполнил три клика в центре экрана!")
