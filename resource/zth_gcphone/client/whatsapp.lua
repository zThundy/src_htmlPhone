-- notifiche

RegisterNetEvent("gcPhone:whatsapp_showError")
AddEventHandler("gcPhone:whatsapp_showError", function(title, message) SendNUIMessage({event = 'whatsapp_showError', message = message, title = title}) end)

RegisterNetEvent("gcPhone:whatsapp_showSuccess")
AddEventHandler("gcPhone:whatsapp_showSuccess", function(title, message) SendNUIMessage({event = 'whatsapp_showSuccess', message = message, title = title}) end)

-- eventi e funzioni per funzionamento


RegisterNetEvent("gcphone:whatsapp_updateGruppi")
AddEventHandler("gcphone:whatsapp_updateGruppi", function(groups)
    SendNUIMessage({ event = "whatsappClearGroups" })

    ESX.TriggerServerCallback("gcPhone:getPhoneNumber", function(number)

        for group_id, group in pairs(groups) do
            group.partecipanti = json.decode(group.partecipanti)

            group.partecipantiString = ""
            for index, contact in pairs(group.partecipanti) do
                -- se il numero che loopa è il tuo, allora sostituisce il display
                -- con "Tu"
                if contact.number == number then contact.display = "Tu" end
                -- mi loopo i contatti e mi creo la stringa da mandare al NUI
                if index == 1 then
                    group.partecipantiString = contact.display
                else
                    group.partecipantiString = group.partecipantiString..", "..contact.display
                end
            end

            if string.len(group.partecipantiString) > 50 then
                group.partecipantiString = string.sub(group.partecipantiString, 50)
                group.partecipantiString = group.partecipantiString.."..."
            end

            for index, contact in pairs(group.partecipanti) do

                -- if contact.number == myPhoneNumber then
                if contact.number == number then
                    -- print(group.id, group.gruppo, group.icona, "inviato al NUI")
                    SendNUIMessage({ event = "whatsappReceiveGroups", group = group })
                end
            end
        end

    end)
end)


RegisterNetEvent("gcphone:whatsapp_sendNotificationToMembers")
AddEventHandler("gcphone:whatsapp_sendNotificationToMembers", function(sender, label, message, id)
    -- print("sto per inviare notifica a telefono", sender, label, message, id)
    SendNUIMessage({ event = "whatsappShowMessageNotification", info = { sender = sender, label = label, message = message, id = id } })
end)


RegisterNUICallback("abbandonaGruppo", function(data, cb)
    -- print(data)
    -- print(data.gruppo)
    TriggerServerEvent("gcphone:whatsapp_leaveGroup", data.gruppo)
    cb("ok")
end)

RegisterNUICallback("requestWhatsappeMessages", function(data, cb)
    -- print("requesting whatsapp messages", data.id)

    ESX.TriggerServerCallback("gcPhone:getMessaggiFromGroupId", function(messages)
        -- for k, v in pairs(messages) do print(k, v) for j, m in pairs(v) do print(j, m, m.message, m.sender, m.id) end end
        -- print(json.encode(messages))
        if messages then
            SendNUIMessage({event = "whatsappReceiveMessages", messages = messages })
        end
    end, data.id)
end)

RegisterNUICallback("requestAllGroupsInfo", function(data, cb)
    -- print("requestAllGroupsInfo")
    TriggerServerEvent("gcPhone:getAllGroups")
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
    TriggerServerEvent("gcphone:whatsapp_sendMessage", data)
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
    TriggerServerEvent("gcphone:whatsapp_creaNuovoGruppo", data)
    cb("ok")
end)


RegisterNUICallback("updateGroup", function(data, cb)
    ESX.TriggerServerCallback("gcphone:whatsapp_editGroup", function(ok)
        if ok then
            ESX.ShowNotification("~g~Gruppo aggiornato con successo")
        else
            ESX.ShowNotification("~r~Impossibile aggiornare il gruppo")
        end
    end, data)
    cb("ok")
end)

RegisterNUICallback("sendAudioNotification", function(data, cb)
    if isConnected then
        if enableGlobalNotification then
            PlaySoundJS('msgnotify.ogg')
            Citizen.Wait(3000)
            StopSoundJS('msgnotify.ogg')
        end
    end
    cb("ok")
end)

RegisterNUICallback("addGroupMembers", function(data, cb)
    print(data.contacts)
    print(data.gruppo.id)
    TriggerServerEvent("gcphone:whatsapp_addGroupMembers", data)
    cb("ok")
end)