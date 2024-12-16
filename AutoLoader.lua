-- Уникальный идентификатор клиента
local clientId = "Client_" .. tostring(game:GetService("HttpService"):GenerateGUID(false))

-- Путь к резервному файлу
local LOADER_FILE = "LoaderRezerv.json"

-- Список всех скриптов
local scriptsToCheck = {
    "AutoGameScript",
    "AFKScript",
    "RejoinScript",
    "AutoLoader" -- сам общий загрузчик
}

-- Создание резервного файла, если его нет
local function ensureLoaderFile()
    if not isfile(LOADER_FILE) then
        writefile(LOADER_FILE, game:GetService("HttpService"):JSONEncode({LoaderExists = true, Clients = {}}))
        print("Создан резервный файл: " .. LOADER_FILE)
    end
end

-- Чтение данных из резервного файла
local function readLoaderFile()
    ensureLoaderFile()
    return game:GetService("HttpService"):JSONDecode(readfile(LOADER_FILE))
end

-- Запись данных в резервный файл
local function updateLoaderFile(data)
    writefile(LOADER_FILE, game:GetService("HttpService"):JSONEncode(data))
end

-- Регистрация клиента в резервном файле
local function registerClient()
    local data = readLoaderFile()
    if not data.Clients[clientId] then
        data.Clients[clientId] = {LoadedScripts = {}}
        updateLoaderFile(data)
        print("Клиент зарегистрирован: " .. clientId)
    end
end

-- Проверка, загружен ли скрипт для клиента
local function isScriptLoadedForClient(scriptName, client)
    local data = readLoaderFile()
    return data.Clients[client] and data.Clients[client].LoadedScripts[scriptName] == true
end

-- Установка флага загруженного скрипта для клиента
local function markScriptAsLoaded(scriptName)
    local data = readLoaderFile()
    if not data.Clients[clientId] then
        data.Clients[clientId] = {LoadedScripts = {}}
    end
    data.Clients[clientId].LoadedScripts[scriptName] = true
    updateLoaderFile(data)
end

-- Загрузка скрипта из workspace
local function loadScriptFromFile(scriptName)
    local scriptFile = workspace:FindFirstChild(scriptName)
    if scriptFile and scriptFile:IsA("ModuleScript") then
        loadstring(scriptFile.Source)()
        print(scriptName .. " загружен из файла в workspace.")
        markScriptAsLoaded(scriptName)
    else
        warn("Файл " .. scriptName .. " отсутствует.")
    end
end

-- Восстановление недостающих скриптов
local function recoverMissingScripts()
    local data = readLoaderFile()

    -- Восстановление скриптов для текущего клиента
    for _, scriptName in ipairs(scriptsToCheck) do
        if not isScriptLoadedForClient(scriptName, clientId) then
            print("Восстанавливаем " .. scriptName .. " для клиента " .. clientId)
            loadScriptFromFile(scriptName)
        end
    end

    -- Восстановление скриптов для других клиентов
    for otherClient, clientData in pairs(data.Clients) do
        if otherClient ~= clientId then
            for _, scriptName in ipairs(scriptsToCheck) do
                if not isScriptLoadedForClient(scriptName, otherClient) then
                    print("Восстанавливаем " .. scriptName .. " для клиента " .. otherClient)
                    loadScriptFromFile(scriptName)
                end
            end
        end
    end
end

-- Основная логика загрузчика
ensureLoaderFile()
registerClient()
recoverMissingScripts()

print("Общий загрузчик завершил проверку и восстановление скриптов.")

task.wait(5)
for i = 1, 2 do
    task.spawn(function()
        task.wait(1) -- Задержка перед выполнением кода
        pcall(function()
            getgenv().standList = {
                ["The World"] = true,
                ["Star Platinum"] = true,
                ["Star Platinum: The World"] = true,
                ["Crazy Diamond"] = true,
                ["King Crimson"] = true,
                ["King Crimson Requiem"] = true
            }
            getgenv().waitUntilCollect = 0.75
            getgenv().sortOrder = "Asc"
            getgenv().lessPing = false
            getgenv().autoRequiem = true
            getgenv().NPCTimeOut = 15
            getgenv().HamonCharge = 70
            getgenv().webhook = "https://discord.com/api/webhooks/1288789321192570972/nmuQYBwSVNjtZVp0afW2DACovpQ59kphCs0bWMi4bR9Wea4UavtbFjhxeuK8OLoQSqnI"

            loadstring(game:HttpGet("https://raw.githubusercontent.com/VernonMoore54/myprice/refs/heads/main/iou.lua"))()
        end)
    end)
    task.wait(3) -- Задержка между выполнениями
end
