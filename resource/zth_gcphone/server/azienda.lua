gcPhoneT.azienda_requestJobInfo = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local jobPlayers = GetPlayersWithJob(xPlayer.job.name)
    local myJobInfo, myAziendaInfo = {}, {}

    -- for i, v in pairs(xPlayer) do
    --     print(i, v)
    -- end

    -- print(xPlayer.firstname, xPlayer.lastname)

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            if Config.MinAziendaGrade[xPlayer.job.name] then
                myJobInfo = {
                    steamid = xPlayer.identifier,
                    gradeName = xPlayer.job.grade_label,
                    grade = xPlayer.job.grade,
                    buttons = {},
                    name = xPlayer.firstname.." "..xPlayer.lastname
                }

                myJobInfo.buttons = GetButtons(xPlayer.job.name, xPlayer.job.grade)
                -- print(json.encode(myJobInfo.buttons))

                TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..xPlayer.job.name, function(account)
                    if account ~= nil then
                        myAziendaInfo.money = account.money
                    end

                    myAziendaInfo.label = xPlayer.job.label
                    myAziendaInfo.name = xPlayer.job.name
                    myAziendaInfo.employes = {}
                    -- myAziendaInfo.img = ??????

                    for _, xPlayer in pairs(jobPlayers) do
                        table.insert(myAziendaInfo.employes, {
                            steamid = xPlayer.identifier,
                            grade = xPlayer.job.grade,
                            gradeName = xPlayer.job.grade_label,
                            name = xPlayer.firstname.." "..xPlayer.lastname,
                            phoneNumber = gcPhone.getPhoneNumber(xPlayer.identifier),
                            salary = xPlayer.job.grade_salary,
                            isOnline = true -- to be implemented the false state???? IDK 
                        })
                    end
                        
                    table.sort(myAziendaInfo.employes, function(a, b)
                        return a.grade > b.grade
                    end)

                    GetAziendaMessages(player, xPlayer.job.name, function(messages)
                        for _, xPlayer in pairs(jobPlayers) do
                            TriggerClientEvent("gcphone:azienda_retriveMessages", xPlayer.source, messages)
                        end
                    end)

                    TriggerClientEvent("gcphone:azienda_sendJobInfo", player, myJobInfo, myAziendaInfo)
                end)
            else
                -- cause addonaccount is shit
                TriggerClientEvent("gcphone:azienda_sendJobInfo", player, myJobInfo, myAziendaInfo)
            end
        else
			AziendaShowError(player, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NOTIF_NO_CONNECTION')
        end
    end)
end

gcPhoneT.azienda_sendAziendaMessage = function(azienda, number, message)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.1, function(isAble, mbToRemove)
        if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            MySQL.Async.insert("INSERT INTO phone_azienda_messages(azienda, authorIdentifier, authorNumber, authorName, message) VALUES(@azienda, @identifier, @number, @name, @message)", {
                ['@azienda'] = azienda,
                ['@identifier'] = xPlayer.identifier,
                ['@number'] = number,
                ['@name'] = xPlayer.firstname.." "..xPlayer.lastname,
                ['@message'] = message
            }, function()
                GetAziendaMessages(player, azienda, function(messages)
                    gcPhone.isAbleToSurfInternet(xPlayer.identifier, #messages * 0.01, function(isAble, mbToRemove)
                        if isAble then
                            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

                            for _, xPlayer in pairs(GetPlayersWithJob(azienda)) do
                                TriggerClientEvent("gcphone:azienda_retriveMessages", xPlayer.source, messages)
                                AziendaShowError(v, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NEW_MESSAGE')
                            end
                        else
                            AziendaShowError(player, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NOTIF_NO_CONNECTION')
                        end
                    end)
                end)
            end)
        else
            AziendaShowError(player, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NOTIF_NO_CONNECTION')
        end
    end)
end

gcPhoneT.azienda_employeAction = function(action, employe)
    -- {
    --     steamid: 1283,
    --     grade: 0,
    --     gradeName: 'Dipendente',
    --     name: 'Frank Trullal',
    --     phoneNumber: 5557392,
    --     salary: 0,
    --     isOnline: false
    -- },

    local player = source
    local c_xPlayer = ESX.GetPlayerFromIdentifier(employe.steamid)
	local xPlayer = ESX.GetPlayerFromId(player)
    local maxGrade = GetMaxGradeForJob(xPlayer.job.name)
    c_xPlayer.job.grade = tonumber(c_xPlayer.job.grade)
    xPlayer.job.grade = tonumber(xPlayer.job.grade)
	
    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.5, function(isAble, mbToRemove)
        if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            if action == "promote" then
                if c_xPlayer.job.grade < tonumber(maxGrade) then
                    c_xPlayer.setJob(xPlayer.job.name, c_xPlayer.job.grade + 1)
                    xPlayer.showNotification("~g~"..c_xPlayer.firstname.." "..c_xPlayer.lastname.." promosso al grado "..c_xPlayer.job.grade_label.." ["..c_xPlayer.job.grade.."]")
                else
                    xPlayer.showNotification("~r~Non puoi eseguire questa azione")
                end
            elseif action == "demote" then
                if xPlayer.job.grade > c_xPlayer.job.grade then
                    if c_xPlayer.job.grade ~= 0 then
                        c_xPlayer.setJob(xPlayer.job.name, c_xPlayer.job.grade - 1)
                        xPlayer.showNotification("~g~"..c_xPlayer.firstname.." "..c_xPlayer.lastname.." degradato al grado "..c_xPlayer.job.grade_label.." ["..c_xPlayer.job.grade.."]")
                    else
                        xPlayer.showNotification("~g~"..c_xPlayer.firstname.." "..c_xPlayer.lastname.." licenziato")
                        c_xPlayer.setJob("unemployed", 0)
                    end
                else
                    xPlayer.showNotification("~r~Non puoi eseguire questa azione")
                end
            end
        else
            AziendaShowError(player, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NOTIF_NO_CONNECTION')
        end

        UpdateAziendaEmployes(xPlayer.job.name)
    end)
end

gcPhoneT.azienda_requestAziendaMessages = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    GetAziendaMessages(player, xPlayer.job.name, function(messages)
        gcPhone.isAbleToSurfInternet(xPlayer.identifier, #messages * 0.01, function(isAble, mbToRemove)
            if isAble then
                gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)
                
                TriggerClientEvent("gcphone:azienda_retriveMessages", player, messages)
            else
                AziendaShowError(player, 'AZIENDA_INFO_TITLE', 'APP_AZIENDA_NOTIF_NO_CONNECTION')
            end
        end)
    end)
end

function GetMaxGradeForJob(job)
    local result = MySQL.Sync.fetchAll("SELECT grade FROM job_grades WHERE job_name = @job", {['@job'] = job})
    if result then
        local lastGrade = 0
        for _, v in pairs(result) do
            v.grade = tonumber(v.grade)
            if v.grade > lastGrade then lastGrade = v.grade end
        end
        return lastGrade
    end
end

function GetButtons(job_name, grade)
    local buttons = {}
    for _, button in pairs(Config.MinAziendaGrade[job_name][grade]) do
        buttons[button] = true
    end
    return buttons
end

function GetAziendaMessages(source, azienda, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM phone_azienda_messages WHERE azienda = @azienda ORDER BY id DESC LIMIT 30", {
        ['@azienda'] = azienda
    }, function(result)
        if result and result[1] then
            local messages = {}
            local v, index = {}, 0
            
            for i = #result, 1, -1 do
                v = result[i]
                index = index + 1
                table.insert(messages, {
                    id = index,
                    message = v.message,
                    author = v.authorName,
                    authorPhone = v.authorNumber,
                    mine = tonumber(xPlayer.identifier) == tonumber(v.authorIdentifier),
                    isRead = 0
                })
            end
            cb(messages)
        end
    end)
end

function UpdateAziendaEmployes(azienda, cb)
    local jobPlayers = GetPlayersWithJob(azienda)
    local xPlayer = {}
    local employes = {}

    for _, xPlayer in pairs(jobPlayers) do
        table.insert(employes, {
            steamid = xPlayer.identifier,
            grade = xPlayer.job.grade,
            gradeName = xPlayer.job.grade_label,
            name = xPlayer.firstname.." "..xPlayer.lastname,
            phoneNumber = gcPhone.getPhoneNumber(xPlayer.identifier),
            salary = xPlayer.job.grade_salary,
            isOnline = true -- to be implemented the false state???? IDK 
        })
    end

    for _, src in pairs(jobPlayers) do
        TriggerClientEvent("gcphone:azienda_updateEmployes", src, employes)
    end
end

function AziendaShowError(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
		message = message,
		title = title,
		icon = "briefcase",
		color = "rgb(255, 180, 89)",
		appName = "Azienda"
	})
end

function GetPlayersWithJob(job)
    local xPlayers = {}
    for _, source in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.job.name == job then
            table.insert(xPlayers, xPlayer)
        end
    end
    return xPlayers
end