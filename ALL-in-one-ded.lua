--// Список URL’ов для загрузки
local urls = {
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/COROUTINES-REJOIN.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/bondi.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/COROUTINES-REJOIN---.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/AutoTP-To-Lobby.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/AutoKill-To-Lobby.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/Auto-start.lua",
    "https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/Auto-renew.lua",
}

--// Асинхронная загрузка каждого скрипта
for _, url in ipairs(urls) do
    task.spawn(function()
        local ok, err = pcall(function()
            -- Получаем код по HTTP
            local response = game:HttpGet(url, true)
            -- Превращаем в функцию и выполняем
            local func, loadErr = loadstring(response)
            assert(func, "Loadstring error: "..tostring(loadErr))
            func()
        end)
        if not ok then
            warn(("[Loader] Ошибка при загрузке %s:\n%s"):format(url, err))
        else
            print(("[Loader] Успешно загрузили %s"):format(url))
        end
    end)
end
