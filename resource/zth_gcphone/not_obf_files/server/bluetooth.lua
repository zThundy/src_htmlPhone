local USERS_BLUETOOTH = {}

gcPhoneT.bluetooth_sendPicToUser = function(data)
    local player = source
    TriggerClientEvent("esx:showNotification", player, "~g~Immagine inviata con successo")
    TriggerClientEvent("gcphone:bluetooth_receivePic", data.userid, data.link)
end

gcPhoneT.bluetooth_changeEnabledState = function(state)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if state then xPlayer.showNotification("~g~Bluetooth acceso") else xPlayer.showNotification("~r~Bluetooth spento") end
    USERS_BLUETOOTH[xPlayer.identifier] = state
end