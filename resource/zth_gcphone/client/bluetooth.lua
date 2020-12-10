local bluetooth = false

RegisterNUICallback("requestBluetoothPlayers", function(data, cb)
    if not bluetooth then
        bluetooth = data.toggle
        TriggerServerEvent("gcphone:bluetooth_changeEnabledState", bluetooth)

        Citizen.CreateThread(function()
            local players = {}

            while bluetooth do
                Citizen.Wait(10000)
                players = {}

                local tempPlayers = ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), Config.BluetoothRange)
                for _, c_source in pairs(tempPlayers) do table.insert(players, GetPlayerServerId(c_source)) end

                ESX.TriggerServerCallback("gcphone:bluetooth_getPlayersLabel", function(users)
                    if #players > 0 then
                        SendNUIMessage({ event = "sendClosestPlayers", players = users })
                    end
                end, players)
            end

            bluetooth = false
            TriggerServerEvent("gcphone:bluetooth_changeEnabledState", bluetooth)
        end)
    end
end)

RegisterNUICallback("sendPicToUser", function(data, cb)
    TriggerServerEvent("gcphone:bluetooth_sendPicToUser", data)
    cb("ok")
end)

RegisterNetEvent("gcphone:bluetooth_receivePic")
AddEventHandler("gcphone:bluetooth_receivePic", function(link)
    if bluetooth then
        SendNUIMessage({ event = "addPicToGallery", link = link })
    else
        ESX.ShowNotification("~r~Impossibile ricevere l'immagine, bluetooth spento")
    end
end)