local USERS_BLUETOOTH = {}

gcPhoneT.bluetooth_sendPicToUser = function(data)
    if not data.userid then return end
    if not data.link then return end
    local player = source
    TriggerClientEvent("esx:showNotification", player, translate("BLUETOOTH_PICTURE_SENT_OK"))
    TriggerClientEvent("gcphone:bluetooth_receivePic", data.userid, data.link)
end

gcPhoneT.bluetooth_changeEnabledState = function(state)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    if state then showXNotification(xPlayer, translate("BLUETOOTH_ON")) else showXNotification(xPlayer, translate("BLUETOOTH_OFF")) end
    USERS_BLUETOOTH[xPlayer.identifier] = state
end