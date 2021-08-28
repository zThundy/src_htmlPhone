local bluetooth = false

RegisterNUICallback("getClosestPlayers", function(data, cb)
    print("getClosestPlayers")
    local players = {}
    local tempPlayers = ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), Config.BluetoothRange + 0.1)
    for _, c_source in pairs(tempPlayers) do
        table.insert(players, {
            userid = GetPlayerServerId(c_source),
            name = GetPlayerName(c_source)
        })
    end
    table.insert(players, {
        userid = 2,
        name = "test"
    })
    print(DumpTable(players))
    cb(players)
    print("callback done")
end)

RegisterNUICallback("sendPicToUser", function(data, cb)
    gcPhoneServerT.bluetooth_sendPicToUser(data)
    cb("ok")
end)

RegisterNUICallback("updateBluetooth", function(data, cb)
    bluetooth = data
    cb("ok")
end)

RegisterNetEvent("gcphone:bluetooth_receivePic")
AddEventHandler("gcphone:bluetooth_receivePic", function(link)
    if bluetooth then
        SendNUIMessage({ event = "addPicToGallery", link = link })
    else
        ESX.ShowNotification(Config.Language["BLUETOOTH_CANNOT_GET_IMAGE"])
    end
end)