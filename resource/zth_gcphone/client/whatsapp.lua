-- notifiche

--[[
    RegisterNetEvent("gcPhone:whatsapp_showError")
    AddEventHandler("gcPhone:whatsapp_showError", function(title, message)
        SendNUIMessage({ event = 'whatsapp_showError', message = message, title = title, volume = volume })
    end)

    RegisterNetEvent("gcPhone:whatsapp_showSuccess")
    AddEventHandler("gcPhone:whatsapp_showSuccess", function(title, message)
        SendNUIMessage({ event = 'whatsapp_showSuccess', message = message, title = title, volume = volume })
    end)
]]

-- eventi e funzioni per funzionamento

RegisterNetEvent("gcphone:whatsapp_updateGruppi")
AddEventHandler("gcphone:whatsapp_updateGruppi", function(groups, number)
    -- SendNUIMessage({ event = "whatsappClearGroups" })

    local groupsToSend = {}
    for group_id, group in pairs(groups) do
        local index = 1
        group.partecipanti = json.decode(group.partecipanti)

        group.partecipantiString = ""
        for _, contact in pairs(group.partecipanti) do
            -- se il numero che loopa è il tuo, allora sostituisce il display
            -- con "Tu"
            if contact.number == number then contact.display = Config.Language["WHATSAPP_YOU_LABEL"] end
            -- mi loopo i contatti e mi creo la stringa da mandare al NUI
            if index == 1 then
                group.partecipantiString = contact.display
            else
                group.partecipantiString = group.partecipantiString..", "..contact.display
            end

            index = index + 1
        end

        if string.len(group.partecipantiString) > 50 then
            group.partecipantiString = string.sub(group.partecipantiString, 50)
            group.partecipantiString = group.partecipantiString.."..."
        end

        for _, contact in pairs(group.partecipanti) do
            if contact.number == number then
                table.insert(groupsToSend, group)
            end
        end
    end

    SendNUIMessage({ event = "whatsappReceiveGroups", groups = groupsToSend })
end)

RegisterNetEvent("gcphone:whatsapp_sendNotificationToMembers")
AddEventHandler("gcphone:whatsapp_sendNotificationToMembers", function(sender, label, message, id)
    -- print("sto per inviare notifica a telefono", sender, label, message, id)
    SendNUIMessage({ event = "whatsappShowMessageNotification", info = { sender = sender, label = label, message = message, id = id } })
end)

RegisterNUICallback("abbandonaGruppo", function(data, cb)
    -- print(data)
    -- print(data.gruppo)
    gcPhoneServerT.whatsapp_leaveGroup(data.gruppo)
    cb("ok")
end)

RegisterNUICallback("requestWhatsappeMessages", function(data, cb)
    ESX.TriggerServerCallback("gcPhone:getMessaggiFromGroupId", function(messages)
        if messages then
            SendNUIMessage({event = "whatsappReceiveMessages", messages = messages })
        end
    end, data.id)
    cb("ok")
end)

RegisterNUICallback("requestAllGroupsInfo", function(data, cb)
    -- print("requestAllGroupsInfo")
    gcPhoneServerT.getAllGroups()
    cb("ok")
end)

RegisterNUICallback("sendMessageInGroup", function(data, cb)
    if data.messaggio == '%pos%' then
        local myPos = GetEntityCoords(PlayerPedId())
        data.messaggio = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    end
    -- print(data)
    -- print(data.messaggio, data.id, data.phoneNumber)
    -- print("ho ricevuto il messaggio da NUI ed è", data.messaggio, data.phoneNumber)
    gcPhoneServerT.whatsapp_sendMessage(data)
    cb("ok")
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
        icon: null
]]

RegisterNUICallback("inviaValoriPost", function(data, cb)
    gcPhoneServerT.whatsapp_creaNuovoGruppo(data)
    cb("ok")
end)

RegisterNUICallback("updateGroup", function(data, cb)
    ESX.TriggerServerCallback("gcphone:whatsapp_editGroup", function(ok)
        if ok then
            ESX.ShowNotification(Config.Language["WHATSAPP_GROUP_UPDATED_OK"])
        else
            ESX.ShowNotification(Config.Language["WHATSAPP_GROUP_UPDATED_ERROR"])
        end
    end, data)
    cb("ok")
end)

RegisterNUICallback("addGroupMembers", function(data, cb)
    -- print(data.contacts)
    -- print(data.gruppo.id)
    gcPhoneServerT.whatsapp_addGroupMembers(data)
    cb("ok")
end)