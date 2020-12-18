RegisterNetEvent("gcphone:modem_chooseCredentials")
AddEventHandler("gcphone:modem_chooseCredentials", function()
    local label = GetResponseText()

    local password = GetResponseText()

    TriggerServerEvent("gcphone:modem_createModem", label, password, GetEntityCoords(GetPlayerPed(-1)))
end)