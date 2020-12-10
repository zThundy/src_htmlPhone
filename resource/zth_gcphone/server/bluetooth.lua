ESX.RegisterServerCallback("gcphone:bluetooth_getPlayersLabel", function(source, cb, players)
    local users = {}

    for _, player in pairs(players) do
        if player ~= source then
            table.insert(users, {
                name = GetPlayerName(player),
                id = player
            })
        end
    end

    cb(users)
end)

RegisterServerEvent("gcphone:bluetooth_sendPicToUser")
AddEventHandler("gcphone:bluetooth_sendPicToUser", function(data)
    TriggerClientEvent("gcphone:bluetooth_receivePic", data.id, data.link)
end)