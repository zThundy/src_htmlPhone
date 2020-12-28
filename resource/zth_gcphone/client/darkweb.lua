RegisterNUICallback("fetchDarkmessages", function(data, cb)
    TriggerServerEvent("gcphone:darkweb_fetchDarkmessages")
    cb("ok")
end)


RegisterNUICallback("sendDarkMessage", function(data, cb)
    TriggerServerEvent("gcphone:darkweb_sendDarkMessage", data.message)
    cb("ok")
end)


RegisterNetEvent("gcphone:darkweb_sendMessages")
AddEventHandler("gcphone:darkweb_sendMessages", function(messages)
    SendNUIMessage({ event = "sendDarkwebMessages", messages = messages })
end)