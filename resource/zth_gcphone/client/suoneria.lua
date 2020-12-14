local sourceCoords = {}

RegisterNUICallback("endSuoneriaForOthers", function(data, cb)
    TriggerServerEvent("gcphone:endSuoneriaForOthers", ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), Config.MaxSunoeriaDistance))
    cb("ok")
end)


RegisterNUICallback("startSuoneriaForOthers", function(data, cb)
    local sound = data.sound
    TriggerServerEvent("gcphone:startSuoneriaForOthers", ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), Config.MaxSunoeriaDistance), sound, GetEntityCoords(GetPlayerPed(-1)))
    StartCheckCoords()
    cb("ok")
end)


-- questo loop invia le coordinate di chi ha la suoneria attiva
-- al server, dando la possibilità agli altri client di richiederle
function StartCheckCoords()
    Citizen.CreateThread(function()
        while inCall do
            Citizen.Wait(2500)
            
            TriggerServerEvent("gcphone:updateMyCoordsForOthers", GetEntityCoords(GetPlayerPed(-1)), ESX.Game.GetPlayersInArea(GetEntityCoords(GetPlayerPed(-1)), Config.MaxSunoeriaDistance))
        end
    end)
end


-- questo evento viene chiamato dal server a tutti gli utenti vicini alla source della
-- suoneria. In più controlla se esci dal raggio o se rientri
-- questo evento inoltre aggionra anche le coordinate della source in modo da non appesantire il server
-- con 2000 richieste al secondo
RegisterNetEvent("gcphone:startSuoneriaForSecondUser")
AddEventHandler("gcphone:startSuoneriaForSecondUser", function(sourceId, sound, coords)

    -- questo controllo passa la prima volta (quando il client non ha nessuno registrato)
    -- con la suoneria attiva nelle vicinanze
    if sourceCoords[sourceId] == nil then
        sourceCoords[sourceId] = coords

        PlaySoundJS(sound)

        Citizen.CreateThread(function()
            local distance = nil

            while sourceCoords[sourceId] ~= nil do
                distance = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), sourceCoords[sourceId], true)
                SetSoundVolumeJS(sound, 1.0 - (distance / 10))

                Citizen.Wait(500)
            end
        end)
    else
        -- il resto delle volte finisce qui e aggiorna le coordinate
        -- finquando lo "host" non setta di nuovo le coordinate a nil
        sourceCoords[sourceId] = coords
    end
end)


-- questo nel caso il giocatore risponda alla chiamata, o qualsiasi evento che
-- termina la suoneria, chiude i loop di tutti gli utenti a prescindere che siano vivini o lontani
RegisterNetEvent("gcphone:endSuoneriaForSecondUser")
AddEventHandler("gcphone:endSuoneriaForSecondUser", function(sourceId) if sourceCoords[sourceId] ~= nil then sourceCoords[sourceId] = nil end end)