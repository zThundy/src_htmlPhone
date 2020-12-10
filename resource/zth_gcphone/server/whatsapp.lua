local cachedGroups = {}

MySQL.ready(function()
    updateCachedGroups()
end)


function updateCachedGroups()
    local query = false
    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups", {}, function(r)
        for k, v in pairs(r) do
            cachedGroups[v.id] = v
        end

        query = true
    end)

    while not query do Citizen.Wait(1000) end

    return cachedGroups
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
                TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
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
                    local group = cachedGroups[data.id]

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
            TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
        end
    end)
end)


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

    gcPhone.isAbleToSurfInternet(xPlayer.identifier, 1, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)
            
            MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = data.gruppo.id}, function(result)
                local partecipanti = json.decode(result[1].partecipanti)

                for _, val in pairs(data.contacts) do
                    if val.selected then
                        table.insert(partecipanti, {
                            display = val.display,
                            icon = val.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                            id = val.id,
                            number = val.number
                        })
                    end
                end

                gcPhone.isAbleToSurfInternet(xPlayer.identifier, #partecipanti * 0.2, function(isAble, mbToRemove)
                    if isAble then
                        gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

                        MySQL.Async.execute("UPDATE FROM phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                            ['@id'] = data.gruppo.id,
                            ['@partecipanti'] = json.encode(partecipanti)
                        }, function(rowsChanged)
                            if rowsChanged > 0 then TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups()) end
                        end)
                    else
                        TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
                    end
                end)
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
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
                local partecipanti = json.decode(r[1].partecipanti)
                for k, v in pairs(partecipanti) do
                    if v.number == number then
                        table.remove(partecipanti, k)
                        -- print("rimosso", v.number)
                        break
                    end
                end

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
            TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
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
    
            table.insert(partecipanti, {
                display = data.myInfo.display,
                id = data.myInfo.id,
                number = data.myInfo.number
            })

            -- print(json.encode(data.contacts))

            for k, v in pairs(data.contacts) do
                if v.selected then
                    table.insert(partecipanti, {
                        display = v.display,
                        icon = v.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                        id = v.id,
                        number = v.number
                    })
                end
            end

            MySQL.Async.insert("INSERT INTO phone_whatsapp_groups(icona, gruppo, partecipanti) VALUES(@icona, @gruppo, @partecipanti)", {
                ['@icona'] = data.groupImage or '/html/static/img/app_whatsapp/defaultgroup.png',
                ['@gruppo'] = data.groupTitle,
                ['@partecipanti'] = json.encode(partecipanti)
            }, function(id)
                TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups())
            end)
        else
            TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
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
            TriggerClientEvent("gcphone:whatsapp_showError", "Errore", "Non hai abbastanza giga per farlo!")
            cb(false)
        end
    end)
end)