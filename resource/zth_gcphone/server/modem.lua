RegisterServerEvent("gcphone:modem_createModem")
AddEventHandler("gcphone:modem_createModem", function(label, password, coords)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    MySQL.Async.insert("INSERT INTO home_wifi_nets(steam_id, label, password, x, y, z) VALUES(@steam_id, @label, @password, @x, @y, @z)", {
        ['@steam_id'] = xPlayer.identifier,
        ['@label'] = label,
        ['@password'] = password,
        ['@x'] = coords.x,
        ['@y'] = coords.y,
        ['@z'] = coords.z
   }, function() xPlayer.showNotification("~g~Modem installato con successo!") end)
end)