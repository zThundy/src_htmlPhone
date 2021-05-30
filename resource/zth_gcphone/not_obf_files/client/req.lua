needAuth = true

RegisterNetEvent("gcphone:authClient")
AddEventHandler("gcphone:authClient", function(data)
    -- print(data)
    SendNUIMessage({ event = "phoneChecks", req = data.req, key = data.authKey })
end)

RegisterNUICallback("PhoneNeedAuth", function(data, cb)
    needAuth = data
    cb("ok")
end)