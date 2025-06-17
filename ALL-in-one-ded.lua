--[[ 
    Основной скрипт для автоматизации действий в GUI
    Автор: [Ваше имя]
    Версия: 1.0
--]]

-- 1. Ожидание появления целевого GUI элемента
while not game.Players.LocalPlayer.PlayerGui.Intro_SCREEN.Frame.Side_Frame_3.Visible do
    task.wait(1) -- Проверка каждую секунду для оптимизации производительности
end

-- 2. Настройка параметров кликов
local clickPosition = Vector2.new(
    workspace.CurrentCamera.ViewportSize.X / 2,  -- Центр экрана по X
    workspace.CurrentCamera.ViewportSize.Y / 2   -- Центр экран по Y
)

local clickParameters = {
    Position = clickPosition,
    Button = Enum.UserInputType.MouseButton1,    -- Левая кнопка мыши
    UserInputType = Enum.UserInputType.MouseButton1
}

-- 3. Выполнение серии кликов
for i = 1, 3 do  -- Повторить 3 раза
    -- Имитация нажатия кнопки мыши
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(
        clickPosition.X,
        clickPosition.Y,
        clickParameters.Button,
        true,   -- Состояние: нажата
        nil,    -- Используемый игровой объект (не требуется)
        1       | Force для корректной работы
    )
    
    -- Имитация отпускания кнопки мыши
    task.wait(0.05)  -- Задержка между нажатием и отпусканием
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(
        clickPosition.X,
        clickPosition.Y,
        clickParameters.Button,
        false,  -- Состояние: отпущена
        nil,
        1
    )
    
    if i < 3 then  -- Не делать задержку после последнего клика
        task.wait(0.05)  -- Пауза между кликами
    end
end

--[[ 
    Примечания для разработчика:
    1. Для изменения количества кликов измените значение в цикле for
    2. Для регулировки скорости кликов измените параметры в task.wait()
    3. Все координаты считаются от верхнего левого угла экрана
    4. Для безопасности добавьте проверку на существование объектов
--]]
