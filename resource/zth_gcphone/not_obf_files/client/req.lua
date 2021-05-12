needAuth = true

RegisterNetEvent("gcphone:authClient")
AddEventHandler("gcphone:authClient", function(data)
    -- print(data)
    needAuth = SendNUIMessage({ event = "phoneChecks", req = data.req, key = data.authKey })
end)