RegisterNUICallback("requestJobInfo", function(data, cb)
    gcPhoneServerT.azienda_requestJobInfo()
    cb("ok")
end)

RegisterNUICallback("sendAziendaMessage", function(data, cb)
    -- data.azienda, data.number, data.message
    if data.message == '%pos%' then
        local myPos = GetEntityCoords(GetPlayerPed(-1))
        data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
    end

    gcPhoneServerT.azienda_sendAziendaMessage(data.azienda, data.number, data.message)
    cb("ok")
end)

RegisterNUICallback("aziendaEmployesAction", function(data, cb)
    -- data.azienda, data.number, data.message
    gcPhoneServerT.azienda_employeAction(data.action, data.employe)
    cb("ok")
end)

RegisterNUICallback("requestAziendaMessages", function(data, cb)
    gcPhoneServerT.azienda_requestAziendaMessages()
    cb("ok")
end)

RegisterNetEvent("gcphone:azienda_sendJobInfo")
AddEventHandler("gcphone:azienda_sendJobInfo", function(myJobInfo, myAziendaInfo)
    SendNUIMessage({ event = 'updateAziendaInfo', myJobInfo = myJobInfo, myAziendaInfo = myAziendaInfo })
end)

RegisterNetEvent("gcphone:azienda_retriveMessages")
AddEventHandler("gcphone:azienda_retriveMessages", function(messages)
    -- print(json.encode(messages))
    SendNUIMessage({ event = 'updateAziendaMessages', messages = messages })
end)

RegisterNetEvent("gcphone:azienda_updateEmployes")
AddEventHandler("gcphone:azienda_updateEmployes", function(employes)
    SendNUIMessage({ event = 'updateAziendaEmployes', employes = employes })
end)

RegisterNetEvent("gcphone:azienda_sendEmergencyCall")
AddEventHandler("gcphone:azienda_sendEmergencyCall", function(data)
    Citizen.CreateThreadNow(function()
        if not menuIsOpen then
            if not GLOBAL_AIRPLANE then
                ESX.ShowNotification(Config.Language["APP_AZIENDA_NEW_EMERGENCY_CALL"])
                if NOTIFICATIONS_ENABLED then
                    PlaySoundJS('msgnotify.ogg')
                    Citizen.Wait(3000)
                    StopSoundJS('msgnotify.ogg')
                end
            end
        else
            TriggerEvent("gcphone:sendGenericNotification", {
                message = data.message,
                title = Config.Language["APP_AZIENDA_NEW_EMERGENCY_CALL"],
                icon = "briefcase",
                color = "rgb(255, 180, 89)",
                appName = "Azienda",
                sound = "msgnotify.ogg"
            })
        end
    end)

    SendNUIMessage({ event = "receiveAziendaCall", calls = data })
end)