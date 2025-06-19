-- URL скрипта для загрузки
local url = "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/clickconfig4.lua"

-- Запуск через «корутину»
task.spawn(function()
    local success, err = pcall(function()
        -- Получаем код по HTTP
        local code = game:HttpGet(url, true)
        -- Парсим и выполняем
        local fn, loadErr = loadstring(code)
        assert(fn, "Loadstring error: "..tostring(loadErr))
        fn()
    end)
    if not success then
        setclipboard("[GrowAcc Loader] Ошибка при загрузке %s:\n%s"):format(url, err))
    else
        setclipboard("[GrowAcc Loader] Скрипт успешно загружен и выполнен"))
    end
end)
