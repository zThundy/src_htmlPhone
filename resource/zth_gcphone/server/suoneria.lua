local sourceCoords = {}
local suonerieAttive = {}


-- questo evento viene chiamato da chi termina la suoneria, per qualsiasi motivo,
-- e pulisce tutte le table a tutti i client
RegisterServerEvent("gcphone:endSuoneriaForOthers")
AddEventHandler("gcphone:endSuoneriaForOthers", function(users)
    local sourceId = source
    suonerieAttive[sourceId] = nil
    sourceCoords[sourceId] = nil

    TriggerClientEvent("gcphone:endSuoneriaForSecondUser", -1, sourceId)
end)


-- questo evento aggiorna le coordinate dell'utente
-- che ha avviato la call ed è la sourceId
RegisterServerEvent("gcphone:updateMyCoordsForOthers")
AddEventHandler("gcphone:updateMyCoordsForOthers", function(coords, users)
    local sourceId = source
    sourceCoords[sourceId] = coords
    suonerieAttive[sourceId] = users
    
    -- già dovrebbe essere esclusa la source di chi avvia la chiamata
    -- visto che il getPlayersInArea non prende il giocatore che trigghera
    for index, user in pairs(suonerieAttive[sourceId]) do
        TriggerClientEvent("gcphone:startSuoneriaForSecondUser", user, sourceId, suonerieAttive[sourceId].sound, sourceCoords[sourceId])
    end
end)


-- questo evento avvia il loop che controlla la distanza dalla source
-- per tutti gli utenti vicini alla source
RegisterServerEvent("gcphone:startSuoneriaForOthers")
AddEventHandler("gcphone:startSuoneriaForOthers", function(users, sound, coords)
    local sourceId = source
    suonerieAttive[sourceId] = users
    suonerieAttive[sourceId].sound = sound
    sourceCoords[sourceId] = coords

    -- già dovrebbe essere esclusa la source di chi avvia la chiamata
    -- visto che il getPlayersInArea non prende il giocatore che trigghera
    for index, user in pairs(suonerieAttive[sourceId]) do
        TriggerClientEvent("gcphone:startSuoneriaForSecondUser", user, sourceId, suonerieAttive[sourceId].sound, sourceCoords[sourceId])
    end
end)