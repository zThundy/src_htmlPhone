local cachedGroups = {}

MySQL.ready(function()
    updateCachedGroups()
end)


function updateCachedGroups()
    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups", {}, function(r)
        for k, v in pairs(r) do
            cachedGroups[v.id] = v
        end
    end)
end


ESX.RegisterServerCallback("gcPhone:getMessaggiFromGroupId", function(source, cb, id)
    local messages = {}
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

        cb(messages)
    end)
end)


ESX.RegisterServerCallback("gcPhone:getPhoneNumber", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(gcPhone.getPhoneNumber(xPlayer.identifier))
end)


RegisterServerEvent("gcPhone:getAllGroups")
AddEventHandler("gcPhone:getAllGroups", function()
    local player = source

    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups", {}, function(r)
        for k, v in pairs(r) do
            cachedGroups[v.id] = v
        end

        TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, cachedGroups)
    end)
end)


RegisterServerEvent("gcphone:whatsapp_sendMessage")
AddEventHandler("gcphone:whatsapp_sendMessage", function(data)
    local player = source

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
end)


RegisterServerEvent("gcphone:whatsapp_leaveGroup")
AddEventHandler("gcphone:whatsapp_leaveGroup", function(group)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local number = gcPhone.getPhoneNumber(xPlayer.identifier)

    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function(r)
        local partecipanti = json.decode(r[1].partecipanti)
        for k, v in pairs(partecipanti) do
            if v.number == number then
                table.remove(partecipanti, k)
                break
            end
        end

        MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
            ['@partecipanti'] = json.encode(partecipanti),
            ['@id'] = group.id
        }, function()
            updateCachedGroups()
        end)
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
    local contatti = {}
    
    table.insert(contatti, {
        display = data.myInfo.display,
        id = data.myInfo.id,
        number = data.myInfo.number
    })

    -- print(json.encode(data.contacts))

    for k, v in pairs(data.contacts) do
        if v.selected then
            table.insert(contatti, {
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
        ['@partecipanti'] = json.encode(contatti)
    }, function(id)
        MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = id}, function(r)
            cachedGroups[id] = r[1]
            TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, cachedGroups)
        end)
    end)
end)