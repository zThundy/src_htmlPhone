local cachedGroups = {}

MySQL.ready(function()
    updateCachedGroups()
end)


function updateCachedGroups()
    local query = false
    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups", {}, function(r)
        for k, v in pairs(r) do
            cachedGroups[tonumber(v.id)] = v
        end

        query = true
    end)

    while not query do Citizen.Wait(1000) end

    return cachedGroups
end


function formatTableIndex(table)
    local tb = {}
    for k, v in pairs(table) do
        if k ~= "creator" then
            tb[tonumber(k)] = v
        else
            tb["creator"] = v
        end
    end
    return tb
end


ESX.RegisterServerCallback("gcPhone:getMessaggiFromGroupId", function(source, cb, id)
    local messages = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    messages[tostring(id)] = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_messages WHERE idgruppo = @id", {['@id'] = id}, function(result)
        for k, v in pairs(result) do
            -- inserisco i valori nella table come li vuole vue
            -- diobestemmia
            -- print("index on server is", k)
            table.insert(messages[tostring(v.idgruppo)], {
                id = v.idgruppo,
                sender = v.sender,
                message = v.message
            })
        end

        gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.1 * #messages, function(isAble, mbToRemove)
			if isAble then
				gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)
                cb(messages)
            else
                TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
                cb(false)
            end
        end)
    end)
end)


ESX.RegisterServerCallback("gcPhone:getPhoneNumber", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(gcPhone.getPhoneNumber(xPlayer.identifier))
end)


RegisterServerEvent("gcPhone:getAllGroups")
AddEventHandler("gcPhone:getAllGroups", function()
    local player = source
    TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups())
end)


RegisterServerEvent("gcphone:whatsapp_sendMessage")
AddEventHandler("gcphone:whatsapp_sendMessage", function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 1.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            MySQL.Async.insert("INSERT INTO phone_whatsapp_messages(idgruppo, sender, message) VALUES(@id, @sender, @message)", {
                ['@id'] = data.id,
                ['@sender'] = data.phoneNumber,
                ['@message'] = data.messaggio
            }, function(id)
                -- print("ho fatto la query. id è", id)
                if id > 0 then
                    local group = cachedGroups[tonumber(data.id)]

                    for _, val in pairs(json.decode(group.partecipanti)) do
                        -- print(val.number, "il numero del partecipante è questo")
                        local g_source = gcPhone.getSourceFromPhoneNumber(val.number)
                        -- print(g_source, "ho ricevuto la source")

                        if g_source ~= nil then
                            -- message, label, sender, id | sender, label, message, id
                            TriggerClientEvent("gcphone:whatsapp_sendNotificationToMembers", g_source, data.phoneNumber, group.gruppo, data.messaggio, data.id)
                        end
                    end
                end
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        end
    end)
end)


function isUserInGroup(number, partecipanti)
    for k, v in pairs(partecipanti) do
        if tostring(v.number) == tostring(number) then
            return true
        end
    end

    return false
end


function getPartecipanti(groupid)
    local result = MySQL.Sync.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = groupid})
    if result[1] == nil then return nil end
    return json.decode(result[1].partecipanti)
end


-- ATTENZIONE
-- l'aggiornamento istantaneo dei partecipanti al gruppo, è solo per chi lo fa in quell'istante,
-- gli altri devono chiudere e riaprire il telefono
-- FIX
-- usi la funzione che ho fatto su getSourceFromPhoneNumber loopando i numeri sul
-- loop sotto. Non ho intenzione di farlo ora.
RegisterServerEvent("gcphone:whatsapp_addGroupMembers")
AddEventHandler("gcphone:whatsapp_addGroupMembers", function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local myNumber = gcPhone.getPhoneNumber(xPlayer.identifier)

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 1, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)
            
            local partecipanti = formatTableIndex(getPartecipanti(data.gruppo.id))

            -- print(ESX.DumpTable(partecipanti))
            -- print(ESX.DumpTable(data.selected))
            -- print("---------------------------------------------")

            for _, val in pairs(data.contacts) do
                if partecipanti[tostring(val.id)] ~= nil then partecipanti[tostring(val.id)] = nil end
                if partecipanti[tonumber(val.id)] ~= nil then partecipanti[tonumber(val.id)] = nil end
                -- visto che nel js non ho voglia di passare contacts su i mutuate states
                -- controllo qua se il contatto non è stato toccato
                if val.number ~= myNumber then
                    -- + 1 A CAZZIO DIOCAN MA PORCODDIO
                    if data.selected[tonumber(val.id) + 1] then
                        partecipanti[tonumber(val.id)] = {
                            display = val.display,
                            icon = val.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                            id = val.id,
                            number = val.number
                        }
                    end
                end
            end

            -- print(ESX.DumpTable(partecipanti))

            gcPhone.isAbleToSurfInternet(xPlayer.identifier, #partecipanti * 0.2, function(isAble, mbToRemove)
                if isAble then
                    gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

                    MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                        ['@id'] = data.gruppo.id,
                        ['@partecipanti'] = json.encode(partecipanti)
                    }, function(rowsChanged)
                        if rowsChanged > 0 then TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups()) end
                    end)
                else
                    TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
                end
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        end
    end)
end)


RegisterServerEvent("gcphone:whatsapp_leaveGroup")
AddEventHandler("gcphone:whatsapp_leaveGroup", function(group)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local number = gcPhone.getPhoneNumber(xPlayer.identifier)

    -- print(number, group.id)
    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 5.0, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function(r)
                if r[1] == nil then return end

                local partecipanti = formatTableIndex(json.decode(r[1].partecipanti))

                -- print(ESX.DumpTable(partecipanti))
                -- print("-------------------------------------------")
                
                for id, v in pairs(partecipanti) do
                    if v.number == number then
                        partecipanti[tonumber(id)] = nil
                        break
                    end
                end

                -- print(ESX.DumpTable(partecipanti))
                -- print(#partecipanti)

                if #partecipanti == 0 then
                    MySQL.Async.execute("DELETE FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function() updateCachedGroups() end)
                    return
                end

                MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                    ['@partecipanti'] = json.encode(partecipanti),
                    ['@id'] = group.id
                }, function() updateCachedGroups() end)
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        end
    end)
end)





--[[
    contacts:
        0:
            display: "stoprovando"
            icon: "https://u.trs.tn/tohqw.jpg"
            id: 1
            number: "5554444"
            selected: true
        1:
            display: "questoenuovo"
            id: 2
            number: "55529322"
            selected: true
    infoGroup:
        title: "Nessun titolo"
        image: null
]]

RegisterServerEvent("gcphone:whatsapp_creaNuovoGruppo")
AddEventHandler("gcphone:whatsapp_creaNuovoGruppo", function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local partecipanti = {}

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 1.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            -- print(ESX.DumpTable(partecipanti))
            -- print(ESX.DumpTable(data.selected))
            -- print("--------------------------------------------")

            for _, val in pairs(data.contacts) do
                if data.selected[tonumber(val.id) + 1] then
                    partecipanti[tonumber(val.id)] = {
                        display = val.display,
                        icon = val.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                        id = val.id,
                        number = val.number
                    }
                end
            end

            partecipanti = formatTableIndex(partecipanti)
            -- print(ESX.DumpTable(partecipanti))

            partecipanti["creator"] = {
                display = data.myInfo.display,
                number = data.myInfo.number,
                id = lastId,
                icon = '/html/static/img/app_whatsapp/defaultgroup.png'
            }

            MySQL.Async.insert("INSERT INTO phone_whatsapp_groups(icona, gruppo, partecipanti) VALUES(@icona, @gruppo, @partecipanti)", {
                ['@icona'] = data.groupImage or '/html/static/img/app_whatsapp/defaultgroup.png',
                ['@gruppo'] = data.groupTitle,
                ['@partecipanti'] = json.encode(partecipanti)
            }, function(id)
                TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups())
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        end
    end)
end)

ESX.RegisterServerCallback("gcphone:whatsapp_editGroup", function(source, cb, group)
    local xPlayer = ESX.GetPlayerFromId(source)

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 2.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)
            
            MySQL.Async.execute("UPDATE phone_whatsapp_groups SET gruppo = @gruppo, icona = @icona WHERE id = @id", {
                ['@gruppo'] = group.gruppo,
                ['@icona'] = group.icona,
                ['@id'] = group.id
            }, function(rowsChanged)
                if rowsChanged > 0 then cb(true) else cb(false) end
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
            cb(false)
        end
    end)
end)