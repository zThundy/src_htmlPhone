RegisterNUICallback("requestJobInfo", function(data, cb)
    TriggerServerEvent("gcphone:azienda_requestJobInfo")
    cb("ok")
end)

RegisterNUICallback("sendAziendaMessage", function(data, cb)
    -- data.azienda, data.number, data.message
    TriggerServerEvent("gcphone:azienda_sendAziendaMessage", data.azienda, data.number, data.message)
    cb("ok")
end)

RegisterNUICallback("aziendaEmployesAction", function(data, cb)
    -- data.azienda, data.number, data.message
    TriggerServerEvent("gcphone:azienda_employeAction", data.action, data.employe)
    cb("ok")
end)

RegisterNetEvent("gcphone:azienda_sendJobInfo")
AddEventHandler("gcphone:azienda_sendJobInfo", function(myJobInfo, myAziendaInfo)
    SendNUIMessage({ event = 'updateAziendaInfo', myJobInfo = myJobInfo, myAziendaInfo = myAziendaInfo })
end)

RegisterNetEvent("gcphone:azienda_retriveMessages")
AddEventHandler("gcphone:azienda_retriveMessages", function(messages)
    SendNUIMessage({ event = 'updateAziendaMessages', messages = messages })
end)

RegisterNetEvent("gcphone:azienda_updateEmployes")
AddEventHandler("gcphone:azienda_updateEmployes", function(employes)
    SendNUIMessage({ event = 'updateAziendaEmployes', employes = employes })
end)