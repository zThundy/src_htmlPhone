gcPhoneT.acceptVideoCall = function(infoCall, rtcAnswer)
    local player = source
    local id = infoCall.id

    if Chiamate[id] ~= nil then
        ACTIVE_CALLS[Chiamate[id].transmitter_src] = true
        ACTIVE_CALLS[Chiamate[id].receiver_src] = true
        Chiamate[id].receiver_src = infoCall.receiver_src or Chiamate[id].receiver_src

        if Chiamate[id].transmitter_src ~= nil and Chiamate[id].receiver_src ~= nil then
            Chiamate[id].is_accepts = true
            Chiamate[id].rtcAnswer = rtcAnswer
            TriggerClientEvent('gcPhone:acceptVideoCall', Chiamate[id].transmitter_src, Chiamate[id], true)

            if id and Chiamate[id] ~= nil then
                SetTimeout(0, function()
                    if id then
                        TriggerClientEvent('gcPhone:acceptVideoCall', Chiamate[id].receiver_src, Chiamate[id], false)
                    end
                end)
            end

            -- to be changed to send data to another app
            SavePhoneCall(Chiamate[id])
        end
    end
end

gcPhoneT.startVideoCall = function(phone_number, rtcOffer, extraData)
    local player = source
    local srcIdentifier = gcPhoneT.getPlayerID(player)
    -- srcIdentifier è l'identifier del giocatore che ha
    -- avviato la chiamata
    
    local rtcOffer = rtcOffer
    if phone_number == nil or phone_number == '' then return end

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden then phone_number = string.sub(phone_number, 2) end
    -- phone_number è il numero di telefono di chi riceve la chiamata

    local srcPhone = ''
    if extraData ~= nil and extraData.useNumber ~= nil then
        srcPhone = extraData.useNumber
    else
        srcPhone = gcPhoneT.getPhoneNumber(srcIdentifier)
    end
    -- srcPhone è il numero di telefono di chi ha avviato la chiamata
    
    -- qui mi prendo tutte le informazioni del giocatore a cui sto chiamanto
    -- (infatti phone_number è il numero che ricevo dal telefono)
    local destPlayer, isInstalled = gcPhoneT.getIdentifierByPhoneNumber(phone_number)
    local hasAirplane = gcPhoneT.getAirplaneForUser(destPlayer)
    local is_valid = destPlayer ~= nil and destPlayer ~= srcIdentifier

    Chiamate[CALL_INDEX] = {
        id = CALL_INDEX,
        transmitter_src = player,
        transmitter_num = srcPhone,
        receiver_src = nil,
        receiver_num = phone_number,
        is_valid = destPlayer ~= nil,
        is_accepts = false,
        hidden = hidden,
        rtcOffer = rtcOffer,
        extraData = extraData,
        secondiRimanenti = 0,
        updateMinuti = true
    }

    gcPhoneT.isAbleToCall(srcIdentifier, function(isAble, useMin, min, message)
        Chiamate[CALL_INDEX].secondiRimanenti = min
        segnaleTransmitter = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, srcIdentifier)]
        Chiamate[CALL_INDEX].updateMinuti = useMin

        -- qui controllo se la funzione gcPhoneT.getIdentifierByPhoneNumber ha tornato un valore valido, che non sto chiamando
        -- me stesso, e che la sim sia installata
        if is_valid and isInstalled and not hasAirplane then
            gcPhoneT.getSourceFromIdentifier(destPlayer, function(srcTo)
                if ACTIVE_CALLS[srcTo] == nil then
                    if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                        if srcTo ~= nil then
                            segnaleReceiver = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, destPlayer)]
                            if segnaleReceiver ~= nil and segnaleReceiver.potenzaSegnale > 0 then
                                if isAble then
                                    Chiamate[CALL_INDEX].receiver_src = srcTo
                                    TriggerEvent('gcPhone:addCall', Chiamate[CALL_INDEX])
                                    TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[CALL_INDEX], true)
                                    TriggerClientEvent('gcPhone:waitingCall', srcTo, Chiamate[CALL_INDEX], false)
                                else
                                    TriggerClientEvent("esx:showNotification", player, "~r~"..message)
                                    -- xPlayer.showNotification("~r~"..message)
                                end
                            else
                                PlayUnreachable(player, Chiamate[CALL_INDEX])
                            end
                        else
                            PlayUnreachable(player, Chiamate[CALL_INDEX])
                        end
                    else
                        PlayNoSignal(player, Chiamate[CALL_INDEX])
                        TriggerClientEvent("esx:showNotification", player, Config.Language["STARTCALL_MESSAGE_ERROR_1"])
                    end
                else
                    PlayNoSignal(player, Chiamate[CALL_INDEX])
                    TriggerClientEvent("esx:showNotification", player, Config.Language["STARTCALL_MESSAGE_ERROR_2"])
                end
            end)
        else
            if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                PlayUnreachable(player, Chiamate[CALL_INDEX])
            else
                PlayNoSignal(player, Chiamate[CALL_INDEX])
                TriggerClientEvent("esx:showNotification", player, Config.Language["STARTCALL_MESSAGE_ERROR_3"])
                -- xPlayer.showNotification("~r~Non c'è segnale per effettuare una telefonata")
            end
        end

        CALL_INDEX = CALL_INDEX + 1
    end)
end

gcPhoneT.videoCandidates = function(callId, candidates)
    local player = source
    if Chiamate[callId] ~= nil then
        local to = Chiamate[callId].transmitter_src
        if player == to then  to = Chiamate[callId].receiver_src end

        if to == nil then return end
        TriggerClientEvent('gcPhone:candidates', to, candidates)
    end
end