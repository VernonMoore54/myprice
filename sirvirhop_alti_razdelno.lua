local function Teleport123()
    do
        -- Функция для чтения JobId из Avaible-Server.txt
        local function readAvailableJobId()
            local success, jobId = pcall(function()
                if isfile('Avaible-Server.txt') then
                    return readfile('Avaible-Server.txt'):match('^%s*(.-)%s*$')
                end
                return nil
            end)
            if success and jobId and jobId ~= '' then
                return jobId
            else
                warn(
                    'Не удалось прочитать JobId из Avaible-Server.txt или файл пуст'
                )
                return nil
            end
        end
        -- Функция для чтения файла и парсинга в {username = {job = jobId, start = timestamp}}
        local function readFarmFile()
            if not isfile('current-farm.txt') then
                return {}
            end
            local content = readfile('current-farm.txt')
            local data = {}
            for line in content:gmatch('[^\r\n]+') do
                local user, job, start_str = line:match('^(.-):(.+):(%d+)$')
                if user and job and start_str then
                    data[user] = { job = job, start = tonumber(start_str) }
                end
            end
            return data
        end
        -- Функция для группировки по JobId: {jobId = { {user=user, start=start}, ... }}
        local function groupByJobId(data)
            local groups = {}
            for user, info in pairs(data) do
                local job = info.job
                if not groups[job] then
                    groups[job] = {}
                end
                table.insert(groups[job], { user = user, start = info.start })
            end
            return groups
        end
        -- Функция для сервер-хопа с нажатием F9
        local function ServerHop()
            -- Запускаем корутину для нажатий F9
            local function clickF9()
                task.spawn(function()
                    for i = 1, 4 do
                        VirtualInputManager:SendKeyEvent(
                            true,
                            Enum.KeyCode.F9,
                            false,
                            game
                        )
                        task.wait(0.05) -- Короткая задержка для имитации нажатия
                        VirtualInputManager:SendKeyEvent(
                            false,
                            Enum.KeyCode.F9,
                            false,
                            game
                        )
                        task.wait(0.2) -- Задержка между нажатиями
                    end
                end)
            end
            -- Логика сервер-хопа
            local PlaceID = game.PlaceId
            local jobId = readAvailableJobId()
            if jobId and jobId ~= game.JobId then
                while true do
                    local data = readFarmFile()
                    local groups = groupByJobId(data)
                    local targetGroup = groups[jobId]
                    if targetGroup and #targetGroup > 0 then
                        warn(
                            'Сервер занят альт-аккаунтом, реролл JobId...'
                        )
                        jobId = readAvailableJobId() -- Перечитываем новый JobId
                        if not jobId or jobId == game.JobId then
                            warn(
                                'Нет свободного JobId, ждём...'
                            )
                            task.wait(1)
                            continue
                        end
                    else
                        -- Сервер свободен, телепортируем
                        pcall(function()
                            while true do
                                clickF9()
                                TeleportService:TeleportToPlaceInstance(
                                    PlaceID,
                                    jobId,
                                    player
                                )
                                clickF9()
                                task.wait(2)
                            end
                        end)
                        task.wait(4)
                        break
                    end
                    task.wait(0.5)
                end
            else
                warn(
                    'Телепортация не выполнена: JobId не найден или совпадает с текущим сервером'
                )
            end
        end
        ServerHop()
    end
end

Teleport123()
