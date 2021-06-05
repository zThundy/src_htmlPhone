local USERS_BLUETOOTH = {}

gcPhoneT.bluetooth_sendPicToUser = function(data)
    local player = source
    TriggerClientEvent("esx:showNotification", player, Config.Language["BLUETOOTH_PICTURE_SENT_OK"])
    TriggerClientEvent("gcphone:bluetooth_receivePic", data.userid, data.link)
end

gcPhoneT.bluetooth_changeEnabledState = function(state)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if state then xPlayer.showNotification(Config.Language["BLUETOOTH_ON"]) else xPlayer.showNotification(Config.Language["BLUETOOTH_OFF"]) end
    USERS_BLUETOOTH[xPlayer.identifier] = state
end