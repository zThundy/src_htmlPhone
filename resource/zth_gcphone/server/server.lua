ESX = nil
-- gcPhone = {}
segnaliTelefoniPlayers = {}
wifiConnectedPlayers = {}
playersInCall = {}
built_phones = false
phone_loaded = false

enableGlobalAirplane = {}

cachedNumbers = {}
cachedContacts = {}
cachedMessages = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_phone:getShILovePizzaaredObjILovePizzaect')
AddEventHandler('esx_phone:getShILovePizzaaredObjILovePizzaect', function(cb)
    cb(gcPhone)
end)


AddEventHandler("playerDropped", function(reason)
    local player = source
    TriggerClientEvent("gcphone:animations_doCleanup", player)

    gcPhone.debug("^1[ZTH_Phone] ^0User "..player.." dropping. Doing cleanup")
end)


MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_messages WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})
    MySQL.Async.execute("DELETE FROM twitter_tweets WHERE (DATEDIFF(CURRENT_DATE, time) > 20)", {})
    MySQL.Async.execute("DELETE FROM phone_calls WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})

    gcPhone.debug("^1[ZTH_Phone] ^0Caching members. Lag expected")

    MySQL.Async.fetchAll("SELECT phone_number, identifier FROM sim", {}, function(r)
        for _, v in pairs(r) do
            cachedNumbers[tostring(v.phone_number)] = {identifier = v.identifier, inUse = false}

            --[[
                da esx_cartesim aggiorno la sim in uso al
                login del plater, quindi non mi serve fare tutte ste query

                MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = v.identifier}, function(user)
                    if user ~= nil and user[1] ~= nil then
                        if user[1].phone_number == v.phone_number then
                            cachedNumbers[tostring(v.phone_number)].inUse = true
                        end
                    end
                end)
            ]]
        end

        phone_loaded = true
        gcPhone.debug("^1[ZTH_Phone] ^0Numbers cache loaded from sim database")
        gcPhone.debug("^1[ZTH_Phone] ^0Phone initialized")
    end)

    MySQL.Async.fetchAll("SELECT * FROM phone_users_contacts", {}, function(r)
        for _, v in pairs(r) do
            table.insert(cachedContacts[v.identifier], v) 
        end
    end)

    MySQL.Async.fetchAll("SELECT * FROM phone_messages", {}, function(r)
        for _, v in pairs(r) do
            table.insert(cachedMessages[v.receiver], v)
        end
    end)
end)


RegisterServerEvent('gcPhone:allUpdate')
AddEventHandler('gcPhone:allUpdate', function()
    -- creo il thread per evitare di fare il wait sul main
    -- thread
    Citizen.CreateThreadNow(function()
        while not phone_loaded do Citizen.Wait(100) end

        local player = source
        local identifier = gcPhone.getPlayerID(player)
        local num = gcPhone.getPhoneNumber(identifier)

        TriggerClientEvent("gcPhone:updatePhoneNumber", player, num)
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))

        local notReceivedMessages = getUnreceivedMessages(identifier)
        -- if notReceivedMessages > 0 then setMessagesReceived(num) end

        TriggerClientEvent("gcPhone:allMessage", player, getMessages(identifier), notReceivedMessages)

        sendHistoriqueCall(player, num)
    end)
end)


--==================================================================================================================
-------- Eventi e Funzioni del segnale radio e del WiFi
--==================================================================================================================

RegisterServerEvent("gcphone:updateAirplaneForUser")
AddEventHandler("gcphone:updateAirplaneForUser", function(bool)
    local player = source
    local identifier = gcPhone.getPlayerID(player)
    enableGlobalAirplane[identifier] = bool
end)


RegisterServerEvent('gcPhone:updateSegnaleTelefono')
AddEventHandler('gcPhone:updateSegnaleTelefono', function(potenza)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)
    local iSegnalePlayer = gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)

    if iSegnalePlayer == nil then
    	table.insert(segnaliTelefoniPlayers, {identifier = identifier, potenzaSegnale = potenza})
    else
		segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale = potenza
    end
end)


RegisterServerEvent('gcPhone:updateReteWifi')
AddEventHandler('gcPhone:updateReteWifi', function(connected, rete)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)
    local iSegnalePlayer = gcPhone.getPlayerSegnaleIndex(wifiConnectedPlayers, identifier)
    
    if iSegnalePlayer == nil then
    	table.insert(wifiConnectedPlayers, {identifier = identifier, connected = connected, rete = rete})
    else
		wifiConnectedPlayers[iSegnalePlayer].connected = connected
		wifiConnectedPlayers[iSegnalePlayer].rete = rete
    end
end)


function gcPhone.getAirplaneForUser(identifier)
    return enableGlobalAirplane[identifier]
end


function gcPhone.getPlayerSegnaleIndex(tabella, identifier)
	index = nil
	
    for i=1, #tabella do
        if tostring(tabella[i].identifier) == tostring(identifier) then
            -- print("index is", i, "for id", identifier)
			index = i
		end
	end
	
	return index
end


function gcPhone.usaDatiInternet(identifier, value)
    local phone_number = gcPhone.getPhoneNumber(identifier)
    
	ESX.GetPianoTariffarioParam(phone_number, "dati", function(dati)
        TriggerEvent("gcPhone:updateParametroTariffa", phone_number, "dati", dati - value)
    end)
end


function gcPhone.isAbleToSurfInternet(identifier, neededMB, cb)
	local phone_number = gcPhone.getPhoneNumber(identifier)
	
	local iSegnalePlayer = gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)
    local iWifiConnectedPlayer = gcPhone.getPlayerSegnaleIndex(wifiConnectedPlayers, identifier)
    local hasAirplane = gcPhone.getAirplaneForUser(identifier)
    
    if iWifiConnectedPlayer ~= nil and wifiConnectedPlayers[iWifiConnectedPlayer].connected then
    	cb(true, 0)
    else
        if not hasAirplane then
            if iSegnalePlayer ~= nil and segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale ~= 0 then
                ESX.GetPianoTariffarioParam(phone_number, "dati", function(dati)
                    if dati > 0 and dati >= neededMB then
                        cb(true, neededMB)
                    else
                        cb(false)
                    end
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end
end


function gcPhone.isAbleToSendMessage(identifier, cb)
	local phone_number = gcPhone.getPhoneNumber(identifier)
	
    local iSegnalePlayer = gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)
    local hasAirplane = gcPhone.getAirplaneForUser(identifier)
    
    if not hasAirplane then
        if segnaliTelefoniPlayers[iSegnalePlayer] ~= nil and segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale > 0 then
            ESX.GetPianoTariffarioParam(phone_number, "messaggi", function(messaggi)
                if messaggi > 0 then
                    cb(true)
                else
                    cb(false)
                end                    
            end)
        else
            cb(false)
        end
    else
        cb(false)
    end
end


function gcPhone.isAbleToCall(identifier, cb)
	local phone_number = gcPhone.getPhoneNumber(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local hasAirplane = gcPhone.getAirplaneForUser(identifier)
    
    if not hasAirplane then
        ESX.GetPianoTariffarioParam(phone_number, "minuti", function(min)
            if xPlayer.hasJob("police", 0).check or xPlayer.hasJob("ambulance", 0).check then return cb(true, false, min) end

            if min == nil then
                cb(false, true, 0, "~r~Non hai un piano tariffario!")
            else
                if min > 0 then
                    cb(true, true, min)
                else
                    cb(false, true, 0, "~r~Hai finito i minuti previsti dalla tua offerta!")
                end
            end
        end)
    else
        cb(false, true, 0, "~r~Non puoi chiamare con la modalità aereo")
    end
end


RegisterServerEvent('gcPhone:updateParametroTariffa')
AddEventHandler('gcPhone:updateParametroTariffa', function(phone_number, param, value)
	ESX.UpdatePianoTariffario(phone_number, param, value)
end)


--==================================================================================================================
-------- 
--==================================================================================================================


ESX.RegisterServerCallback('gcphone:getItemAmount', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventoryItem(item)

    if items == nil then
        cb(0)
    else
        cb(items.count)
    end
end)


ESX.RegisterServerCallback("gcphone:getNumberFromIdentifier", function(source, cb)
    local identifier = gcPhone.getPlayerID(source)
    local number = gcPhone.getPhoneNumber(identifier)

    cb(number)
end)


ESX.RegisterServerCallback("gcphone:getPianoTariffarioLabel", function(source, cb, phone_number, label)
    ESX.GetPianoTariffarioParam(phone_number, label, function(piano_tariffario)
        cb(piano_tariffario)
    end)
end)


--==================================================================================================================
-------- Utils
--==================================================================================================================

RegisterServerEvent("gcphone:updateCachedNumber")
AddEventHandler("gcphone:updateCachedNumber", function(number, identifier, isChanging)
    -- print(number, identifier, isChanging)
    number = tostring(number)
    identifier = tonumber(identifier)

    if identifier then
        gcPhone.debug("^1[ZTH_Phone] ^0Updated number "..number.." for identifier "..identifier)
    else
        gcPhone.debug("^1[ZTH_Phone] ^0Removed number "..number.." from cachedNumbers")
    end

    local oldNumber = gcPhone.getPhoneNumber(identifier)
    -- print(ESX.DumpTable(cachedNumbers[number]), ESX.DumpTable(cachedNumbers[oldNumber]), oldNumber)

    -- qui controllo se la il numero sta venendo cambiato
    -- con un altra sim
    if cachedNumbers[number] ~= nil then
        if cachedNumbers[oldNumber] ~= nil then
            if isChanging then
                cachedNumbers[oldNumber].inUse = false
                cachedNumbers[number].inUse = true
            else
                -- da esx_cartesim al login del player
                gcPhone.debug("^1[ZTH_Phone] ^0User "..identifier.." is joining, registering "..number.." as 'inUse' number")
                -- print("Registrando numero al login", number, identifier)
                cachedNumbers[number].inUse = true
            end
        else
            -- in realtà questo potrebbe essere inutile :/ IDK
            -- forse evita bug :)
            cachedNumbers[number].inUse = true
        end
    end

    -- qui modifico solo l'indentifier, quindi nel caso io
    -- la stia passando a qualcuno, oppure nel caso in cui
    -- la stia eliminando
    if identifier then
        -- nel caso in cui la stia passando a qualcuno, resetto lo
        -- stato inUse della sim
        if cachedNumbers[number] ~= nil then
            if tostring(cachedNumbers[number].identifier) ~= tostring(identifier) then
                cachedNumbers[number].inUse = false
            end

            cachedNumbers[number].identifier = identifier
        else
            -- nel caso in cui la sim non esiste nella cache, la aggiungo
            cachedNumbers[number] = {identifier = identifier, inUse = false}
        end
    else
        cachedNumbers[number] = nil
    end
end)


function gcPhone.getSourceFromIdentifier(identifier, cb)
    identifier = tonumber(identifier)

    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer ~= nil then cb(xPlayer.source) else cb(nil) end
end


function gcPhone.getPhoneNumber(identifier)
    --[[
        local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier })
        if #result > 0 then return result[1].phone_number end
    ]]

    if identifier then
        for number, v in pairs(cachedNumbers) do
            if tostring(v.identifier) == tostring(identifier) and v.inUse then
                return number
            end
        end
    end

    return nil
end


function gcPhone.getIdentifierByPhoneNumber(phone_number)
    --[[
        local result = MySQL.Sync.fetchAll("SELECT identifier FROM users WHERE phone_number = @phone_number", {['@phone_number'] = phone_number })
        local isInstalled = true
        if result[1] == nil then
            result = MySQL.Sync.fetchAll("SELECT identifier FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = phone_number})
            isInstalled = false
        end

        if result[1] ~= nil then return result[1].identifier, isInstalled end
    ]]

    phone_number = tostring(phone_number)
    if cachedNumbers[phone_number] == nil then return nil, false end

    return cachedNumbers[phone_number].identifier, cachedNumbers[phone_number].inUse
end


function gcPhone.getSourceFromPhoneNumber(phone_number)
    local identifier, _ = gcPhone.getIdentifierByPhoneNumber(phone_number)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer == nil then return nil end

    return xPlayer.source
end


function gcPhone.getPlayerID(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer == nil then return nil end
    
    return xPlayer.identifier
end


--==================================================================================================================
-------- Funzioni Contatti
--==================================================================================================================

-- function getContactsLastId()
--     local id = 0
--     for _, v in pairs(cachedContacts) do
--         for _, contact in pairs(v) do
--             if id < contact.id then
--                 id = contact.id
--             end
--         end
--     end
--     return id
-- end


function getContacts(identifier)
    -- local result = MySQL.Sync.fetchAll("SELECT * FROM phone_users_contacts WHERE phone_users_contacts.identifier = @identifier", { ['@identifier'] = identifier })
    -- return result
    return cachedContacts[identifier]
end


function addContact(source, identifier, number, display, email)
    if identifier ~= nil and number ~= nil and display ~= nil then
        -- notifyContactChange(source, identifier)
        MySQL.Async.insert("INSERT INTO phone_users_contacts(`identifier`, `number`, `display`, `email`) VALUES(@identifier, @number, @display, @email)", {
            ['@identifier'] = identifier,
            ['@number'] = number,
            ['@display'] = display,
            ['@email'] = email
        }, function(id)
            notifyContactChange(source, identifier)

            table.insert(cachedContacts[identifier], {
                identifier = identifier,
                number = number,
                display = display,
                email = email,
                id = id
            })
        end)
    else
        TriggerClientEvent("esx:showNotification", source, "~r~Devi inserire un numero e un nome validi!")
    end
end


function updateContact(source, identifier, id, number, display, email)
    for _, v in pairs(cachedContacts[identifier]) do
        if id == v.id then
            v.number = number
            v.display = display
            v.email = email
            break
        end
    end

    -- notifyContactChange(source, identifier)
    MySQL.Async.insert("UPDATE phone_users_contacts SET number = @number, display = @display, email = @email WHERE id = @id", { 
        ['@number'] = number,
        ['@display'] = display,
        ['@id'] = id,
        ['@email'] = email
    }, function()
        notifyContactChange(source, identifier)
    end)
end


function deleteContact(source, identifier, id)
    for k, v in pairs(cachedContacts[identifier]) do
        if v.id == id then
            table.remove(cachedContacts[identifier], k)
            break
        end
    end

    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier AND `id` = @id", {
        ['@identifier'] = identifier,
        ['@id'] = id,
    })
    notifyContactChange(source, identifier)
end


function deleteAllContacts(identifier)
    MySQL.Async.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier", { ['@identifier'] = identifier })
    cachedContacts[identifier] = nil
end


function notifyContactChange(source, identifier)
    local player = tonumber(source)

    if player ~= nil then 
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end
end


RegisterServerEvent('gcPhone:addContact')
AddEventHandler('gcPhone:addContact', function(display, phoneNumber, email)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    addContact(player, identifier, phoneNumber, display, email)
end)


RegisterServerEvent('gcPhone:updateContact')
AddEventHandler('gcPhone:updateContact', function(id, display, phoneNumber, email)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    updateContact(player, identifier, id, phoneNumber, display, email)
end)


RegisterServerEvent('gcPhone:deleteContact')
AddEventHandler('gcPhone:deleteContact', function(id)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    deleteContact(player, identifier, id)
end)


--==================================================================================================================
-------- Eventi e Funzioni dei Messaggi
--==================================================================================================================


function getMessages(identifier)
    local phone_number = gcPhone.getPhoneNumber(identifier)
    -- return MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", { ['@identifier'] = identifier })
    return cachedMessages[phone_number]
end


function addMessage(source, identifier, phone_number, message)
    -- print(source, identifier, phone_number, message)

    local player = tonumber(source)
    -- local xPlayer = ESX.GetPlayerFromId(player)

    local otherIdentifier, isInstalled = gcPhone.getIdentifierByPhoneNumber(phone_number)
    local myPhone = gcPhone.getPhoneNumber(identifier)
    local hasAirplane = gcPhone.getAirplaneForUser(otherIdentifier)

    -- print(otherIdentifier, isInstalled)
    
    if otherIdentifier ~= nil then
        segnaleTransmitter = segnaliTelefoniPlayers[gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)]

    	if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
            ESX.GetPianoTariffarioParam(myPhone, "messaggi", function(messaggi)
                if messaggi > 0 then

                    ESX.UpdatePianoTariffario(myPhone, "messaggi", messaggi - 1)

                    local memess = internalAddMessage(phone_number, myPhone, message, 1)
                    TriggerClientEvent("gcPhone:receiveMessage", player, memess)
                    -- print(ESX.DumpTable(memess))
                    
                    local tomess = internalAddMessage(myPhone, phone_number, message, 0)
                    -- print(ESX.DumpTable(tomess))

                    gcPhone.getSourceFromIdentifier(otherIdentifier, function(target_source)
                        target_source = tonumber(target_source)

                        if target_source ~= nil then
                            
                            -- qui controllo se la sim a cui stai mandando il
                            -- messaggio è installata o no
                            if isInstalled and not hasAirplane then
                                -- print("sim installata")
                                -- se la sim è installata allora mando il telefono e gli mando la notifica
                                -- local retIndex = gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, otherIdentifier)
                                -- print(retIndex)
                                segnaleReceiver = segnaliTelefoniPlayers[gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, otherIdentifier)]
                                -- print(ESX.DumpTable(segnaleReceiver), ESX.DumpTable(segnaliTelefoniPlayers))
                                if segnaleReceiver ~= nil and segnaleReceiver.potenzaSegnale > 0 then
                                    TriggerClientEvent("gcPhone:receiveMessage", target_source, tomess)
                                    setMessageReceived(phone_number, myPhone)
                                end
                            else
                                -- questo è l'evento che ti fa il bing quando invii il messaggio
                                -- lo ho tolto così non fa la notifica
                                -- TriggerClientEvent("gcPhone:receiveMessage", tonumber(target_source), tomess)
                                setMessageReceived(phone_number, myPhone)
                            end
                        end
                    end)
                else
                    TriggerClientEvent("esx:showNotification", player, "~r~Hai finito i messaggi previsti dal tuo piano tariffario")
                    -- xPlayer.showNotification("Hai finito i messaggi previsti dal tuo piano tariffario", "error")
                end
            end)
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non c'è segnale per mandare un messaggio")
        	-- xPlayer.showNotification("Non c'è segnale per mandare un messaggio", "error")
        end
    else
        TriggerClientEvent("esx:showNotification", player, "~r~Impossibile mandare il messaggio, il numero selezionato non esiste")
        -- xPlayer.showNotification("Impossibile mandare il messaggio, il numero selezionato non esiste", "error")
    end 
end


RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage', function(phoneNumber, message)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    addMessage(player, identifier, phoneNumber, message)
end)


function gcPhone.internalAddMessage(transmitter, receiver, message, owner)
    local id = MySQL.Sync.insert("INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`, `owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)", {
        ['@transmitter'] = transmitter,
        ['@receiver'] = receiver,
        ['@message'] = message,
        ['@isRead'] = owner,
        ['@owner'] = owner
    })

    cachedMessages[receiver] = {
        transmitter = transmitter,
        receiver = receiver,
        message = message,
        isRead = owner,
        owner = owner,
        id = id
    }

    for _, v in pairs(cachedMessages[receiver]) do
        if v.id == id then
            return v
        end
    end

    -- inutile che tanto un return lo avrà
    -- sempre
    -- return nil
end


function setReadMessageNumber(identifier, num)
    local phone_number = gcPhone.getPhoneNumber(identifier)

    for _, v in pairs(cachedMessages[receiver]) do
        if v.receiver == phone_number and v.transmitter == num then
            v.isRead = 1
        end
    end

    MySQL.Sync.execute("UPDATE phone_messages SET phone_messages.isRead = 1 WHERE phone_messages.receiver = @receiver AND phone_messages.transmitter = @transmitter", {
        ['@receiver'] = phone_number,
        ['@transmitter'] = num
    })
end


function setMessageReceived(phone_number, num)
    for _, v in pairs(cachedMessages[receiver]) do
        if v.receiver == phone_number and v.transmitter == num then
            v.received = 1
        end
    end

    MySQL.Sync.execute("UPDATE phone_messages SET phone_messages.received = 1 WHERE phone_messages.receiver = @receiver AND phone_messages.transmitter = @transmitter", {
        ['@receiver'] = phone_number,
        ['@transmitter'] = num
    })
end


function setMessagesReceived(phone_number)
    for _, v in pairs(cachedMessages[receiver]) do
        if v.receiver == phone_number then
            v.received = 1
        end
    end

    MySQL.Sync.execute("UPDATE phone_messages SET phone_messages.received = 1 WHERE phone_messages.receiver = @receiver", {
        ['@receiver'] = phone_number
    })
end


RegisterServerEvent('gcPhone:setReadMessageNumber')
AddEventHandler('gcPhone:setReadMessageNumber', function(num)
    local identifier = gcPhone.getPlayerID(source)

    setReadMessageNumber(identifier, num)
end)


RegisterServerEvent('gcPhone:deleteMessage')
AddEventHandler('gcPhone:deleteMessage', function(msgId)
    for phone_number, tb in pairs(cachedMessages) do
        for k, v in pairs(tb) do
            if v.id == msgId then
                table.remove(cachedMessages[phone_number], k)
                break
            end
        end
    end

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `id` = @id", { ['@id'] = msgId })
end)


RegisterServerEvent('gcPhone:deleteMessageNumber')
AddEventHandler('gcPhone:deleteMessageNumber', function(number)
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)
    local phone_number = gcPhone.getPhoneNumber(identifier)

    for k, v in pairs(cachedMessages[phone_number]) do
        if v.receiver == phone_number and v.transmitter == number then
            table.remove(cachedMessages[phone_number], k)
            break
        end
    end

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `receiver` = @receiver and `transmitter` = @transmitter", { 
        ['@receiver'] = phone_number, 
        ['@transmitter'] = number 
    })
end)


function gcPhone.deleteReceivedMessages(identifier)
    local phone_number = gcPhone.getPhoneNumber(identifier)
    cachedMessages[phone_number] = nil

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `receiver` = @receiver", { ['@receiver'] = phone_number })
end


RegisterServerEvent('gcPhone:deleteAllMessage')
AddEventHandler('gcPhone:deleteAllMessage', function()
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    gcPhone.deleteReceivedMessages(identifier)
end)


RegisterServerEvent('gcPhone:deleteALL')
AddEventHandler('gcPhone:deleteALL', function()
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)

    gcPhone.deleteReceivedMessages(identifier)
    deleteAllContacts(identifier)
    appelsDeleteAllHistorique(identifier)

    TriggerClientEvent("gcPhone:contactList", player, {})
    TriggerClientEvent("gcPhone:allMessage", player, {})
    TriggerClientEvent("appelsDeleteAllHistorique", player, {})
end)


--==================================================================================================================
-------- Eventi e Funzioni delle chiamate
--==================================================================================================================

Chiamate = {}
local PhoneFixeInfo = {}
local lastIndexCall = 10


function getHistoriqueCall(num)
    local result = MySQL.Sync.fetchAll("SELECT * FROM phone_calls WHERE phone_calls.owner = @num ORDER BY time DESC LIMIT 120", { ['@num'] = num })
    return result
end


function sendHistoriqueCall(src, num) 
    local histo = getHistoriqueCall(num)
    TriggerClientEvent('gcPhone:historiqueCall', src, histo)
end


function salvaChiamata(appelInfo)
    if appelInfo.extraData == nil or appelInfo.extraData.useNumber == nil then
        MySQL.Async.insert("INSERT INTO phone_calls (`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['@owner'] = appelInfo.transmitter_num,
            ['@num'] = appelInfo.receiver_num,
            ['@incoming'] = 1,
            ['@accepts'] = appelInfo.is_accepts
        }, function()
            sendHistoriqueCall(appelInfo.transmitter_src, appelInfo.transmitter_num)
        end)
    end

    if appelInfo.is_valid == true then
        local num = appelInfo.transmitter_num
        if appelInfo.hidden == true then
            num = "555#####"
        end

        MySQL.Async.insert("INSERT INTO phone_calls(`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['@owner'] = appelInfo.receiver_num,
            ['@num'] = num,
            ['@incoming'] = 0,
            ['@accepts'] = appelInfo.is_accepts
        }, function()
            if appelInfo.receiver_src ~= nil then
                sendHistoriqueCall(appelInfo.receiver_src, appelInfo.receiver_num)
            end
        end)
    end
end


RegisterServerEvent('gcPhone:getHistoriqueCall')
AddEventHandler('gcPhone:getHistoriqueCall', function()
    local player = tonumber(source)
    local identifier = gcPhone.getPlayerID(player)
    local num = gcPhone.getPhoneNumber(identifier)

    sendHistoriqueCall(player, num)
end)


RegisterServerEvent("gcPhone:requestOffertaFromDatabase")
AddEventHandler("gcPhone:requestOffertaFromDatabase", function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(user)
        if #user > 0 then
            if user[1].phone_number ~= nil then
                MySQL.Async.fetchAll("SELECT * FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = user[1].phone_number}, function(sim)
                    if #sim > 0 then
                        minuti = math.floor(sim[1].minuti / 60)
                        
                        TriggerClientEvent("gcPhone:sendRequestedOfferta", xPlayer.source, {
                            tonumber(minuti),
                            tonumber(sim[1].messaggi),
                            tonumber(sim[1].dati)
                        }, sim[1].piano_tariffario)
                    end
                end)
            end
        end
    end)

    TriggerClientEvent('gcPhone:getBourse', player, getInfoBorsa())
end)


RegisterServerEvent('gcPhone:startCall')
AddEventHandler('gcPhone:startCall', function(phone_number, rtcOffer, extraData)
    local player = source
    TriggerEvent('gcPhone:internal_startCall', player, phone_number, rtcOffer, extraData)
end)


RegisterServerEvent('gcPhone:register_FixePhone')
AddEventHandler('gcPhone:register_FixePhone', function(phone_number, coords)
	Config.TelefoniFissi[phone_number] = {name = "TEST"..phone_number, coords = {x = coords.x, y = coords.y, z = coords.z}}
	TriggerClientEvent('gcPhone:register_FixePhone', -1, phone_number, Config.TelefoniFissi[phone_number])
end)



-- evento che controlla le chiamate tra giocatori
-- e giocatori e telefoni fissi
RegisterServerEvent('gcPhone:internal_startCall')
AddEventHandler('gcPhone:internal_startCall', function(player, phone_number, rtcOffer, extraData)
    if Config.TelefoniFissi[phone_number] ~= nil then
        onCallFixePhone(player, phone_number, rtcOffer, extraData)
        return
    end

    -- local xPlayer = ESX.GetPlayerFromId(player)
    local srcIdentifier = gcPhone.getPlayerID(player)
    -- srcIdentifier è l'identifier del giocatore che ha
    -- avviato la chiamata
    
    local rtcOffer = rtcOffer
    if phone_number == nil or phone_number == '' then return end

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then phone_number = string.sub(phone_number, 2) end
    -- phone_number è il numero di telefono di chi riceve la chiamata

    local indexCall = lastIndexCall
    lastIndexCall = lastIndexCall + 1

    local srcPhone = ''
    if extraData ~= nil and extraData.useNumber ~= nil then
        srcPhone = extraData.useNumber
    else
        srcPhone = gcPhone.getPhoneNumber(srcIdentifier)
    end
    -- srcPhone è il numero di telefono di chi ha avviato la chiamata
    
    -- qui mi prendo tutte le informazioni del giocatore a cui sto chiamanto
    -- (infatti phone_number è il numero che ricevo dal telefono)
    local destPlayer, isInstalled = gcPhone.getIdentifierByPhoneNumber(phone_number)
    local hasAirplane = gcPhone.getAirplaneForUser(destPlayer)
    local is_valid = destPlayer ~= nil and destPlayer ~= srcIdentifier

    Chiamate[indexCall] = {
        id = indexCall,
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

    gcPhone.isAbleToCall(srcIdentifier, function(isAble, useMin, min, message)
        Chiamate[indexCall].secondiRimanenti = min
        segnaleTransmitter = segnaliTelefoniPlayers[gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, srcIdentifier)]
        Chiamate[indexCall].updateMinuti = useMin

        -- qui controllo se la funzione gcPhone.getIdentifierByPhoneNumber ha tornato un valore valido, che non sto chiamando
        -- me stesso, e che la sim sia installata
        if is_valid and isInstalled and not hasAirplane then
            gcPhone.getSourceFromIdentifier(destPlayer, function(srcTo)

                if playersInCall[srcTo] == nil then

                    if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then

                        if srcTo ~= nil then
                            segnaleReceiver = segnaliTelefoniPlayers[gcPhone.getPlayerSegnaleIndex(segnaliTelefoniPlayers, destPlayer)]

                            if segnaleReceiver ~= nil and segnaleReceiver.potenzaSegnale > 0 then
                                
                                if isAble then

                                    Chiamate[indexCall].receiver_src = srcTo
                                    TriggerEvent('gcPhone:addCall', Chiamate[indexCall])
                                    TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[indexCall], true)
                                    TriggerClientEvent('gcPhone:waitingCall', srcTo, Chiamate[indexCall], false)
                                else
                                    TriggerClientEvent("esx:showNotification", player, "~r~"..message)
                                    -- xPlayer.showNotification("~r~"..message)
                                end
                            else
                                playUnreachable(player, Chiamate[indexCall])
                            end
                        else
                            playUnreachable(player, Chiamate[indexCall])
                        end
                    else
                        playNoSignal(player, Chiamate[indexCall])
                        TriggerClientEvent("esx:showNotification", player, "~r~Non c'è segnale per effettuare una telefonata")
                        -- xPlayer.showNotification("~r~Non c'è segnale per effettuare una telefonata")
                    end
                else
                    playNoSignal(player, Chiamate[indexCall])
                    TriggerClientEvent("esx:showNotification", player, "~r~Il telefono è occupato")
                    -- xPlayer.showNotification("~r~Il telefono è occupato")
                end
            end)
        else
            if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                playUnreachable(player, Chiamate[indexCall])
            else
                playNoSignal(player, Chiamate[indexCall])
                TriggerClientEvent("esx:showNotification", player, "~r~Non c'è segnale per effettuare una telefonata")
                -- xPlayer.showNotification("~r~Non c'è segnale per effettuare una telefonata")
            end
        end
    end)
end)


function playUnreachable(player, infoCall)
    infoCall.updateMinuti = false

    TriggerEvent('gcPhone:addCall', infoCall)
    TriggerClientEvent('gcPhone:waitingCall', player, infoCall, true)
    TriggerClientEvent('gcPhone:phoneUnreachable', player, infoCall, true)
end


function playNoSignal(player, infoCall)
    infoCall.updateMinuti = false

    TriggerEvent('gcPhone:addCall', infoCall)
    TriggerClientEvent('gcPhone:waitingCall', player, infoCall, true)
    TriggerClientEvent('gcPhone:phoneNoSignal', player, infoCall, true)
end


RegisterServerEvent('gcPhone:candidates')
AddEventHandler('gcPhone:candidates', function(callId, candidates)
    if Chiamate[callId] ~= nil then
        local player = source

        local to = Chiamate[callId].transmitter_src
        if player == to then  to = Chiamate[callId].receiver_src end

        if to == nil then return end
        TriggerClientEvent('gcPhone:candidates', to, candidates)
    end
end)


RegisterServerEvent('gcPhone:acceptCall')
AddEventHandler('gcPhone:acceptCall', function(infoCall, rtcAnswer)
    local player = source
    local id = infoCall.id

    if Chiamate[id] ~= nil then
        if PhoneFixeInfo[id] ~= nil then
            onAcceptFixePhone(player, infoCall, rtcAnswer)
            return
        end

        playersInCall[Chiamate[id].transmitter_src] = true
        playersInCall[Chiamate[id].receiver_src] = true

        Chiamate[id].receiver_src = infoCall.receiver_src or Chiamate[id].receiver_src

        if Chiamate[id].transmitter_src ~= nil and Chiamate[id].receiver_src ~= nil then

            Chiamate[id].is_accepts = true
            Chiamate[id].rtcAnswer = rtcAnswer
            TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].transmitter_src, Chiamate[id], true)

            if Chiamate[id] ~= nil then
                SetTimeout(0, function() TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].receiver_src, Chiamate[id], false) end)
            end
            salvaChiamata(Chiamate[id])
        end
    end
end)


RegisterServerEvent('gcPhone:ignoreCall')
AddEventHandler('gcPhone:ignoreCall', function(infoCall)
    local id = infoCall.id
end)


-- evento che toglie i minuti a chi ha
-- fatto la telefonata
RegisterServerEvent('gcPhone:rejectCall')
AddEventHandler('gcPhone:rejectCall', function(infoCall)
    local player = source
    local id = infoCall.id
    if Chiamate[id] ~= nil then

        playersInCall[Chiamate[id].transmitter_src] = nil
        if Chiamate[id].receiver_src ~= nil then
            playersInCall[Chiamate[id].receiver_src] = nil
        end

        if PhoneFixeInfo[id] ~= nil then
            onRejectFixePhone(player, infoCall)
            return
        end

        if Chiamate[id].transmitter_src ~= nil then
            TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].transmitter_src, Chiamate[id])
        end

        if Chiamate[id].receiver_src ~= nil then
            TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].receiver_src)
        end

        if Chiamate[id].is_accepts == false then 
            salvaChiamata(Chiamate[id])
        end

        -- TriggerEvent('gcPhone:removeCall', Chiamate)
        Chiamate[id] = nil
    end
end)


RegisterServerEvent('gcPhone:appelsDeleteHistorique')
AddEventHandler('gcPhone:appelsDeleteHistorique', function(numero)
    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local num = gcPhone.getPhoneNumber(identifier)

    MySQL.Sync.execute("DELETE FROM phone_calls WHERE `owner` = @owner AND `num` = @num", {
        ['@owner'] = num,
        ['@num'] = numero
    })
end)


function appelsDeleteAllHistorique(identifier)
    local num = gcPhone.getPhoneNumber(identifier)

    MySQL.Sync.execute("DELETE FROM phone_calls WHERE `owner` = @owner", { ['@owner'] = num })
end


RegisterServerEvent('gcPhone:appelsDeleteAllHistorique')
AddEventHandler('gcPhone:appelsDeleteAllHistorique', function()
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    appelsDeleteAllHistorique(identifier)
end)


--==================================================================================================================
-------- Funzioni e Eventi chiamati al load della risorsa e al caricamento di un player
--==================================================================================================================


function buildPhones()
    for telefono, info_telefono in pairs(Config.TelefoniFissi) do
        TriggerClientEvent("esx:spawnObjectAtCoords", -1, info_telefono.coords, "prop_cs_phone_01", false)
    end
    built_phones = true
end


RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    local player = tonumber(source)

    if not built_phones then buildPhones() end

    local identifier = gcPhone.getPlayerID(player)
    local phone_number = gcPhone.getPhoneNumber(identifier)

    TriggerClientEvent("gcPhone:updatePhoneNumber", player, phone_number)
    TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))

   	local notReceivedMessages = getUnreceivedMessages(identifier)
    if notReceivedMessages > 0 then setMessagesReceived(phone_number) end

    TriggerClientEvent("gcPhone:allMessage", player, getMessages(identifier), notReceivedMessages)
end)


RegisterServerEvent("gcPhone:updateAvatarContatto")
AddEventHandler("gcPhone:updateAvatarContatto", function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    MySQL.Async.execute("UPDATE phone_users_contacts SET icon = '"..data.icon.."' WHERE id = '"..data.id.."'")
    SetTimeout(2000, function()
        TriggerClientEvent("gcPhone:contactList", player, getContacts(xPlayer.identifier))
    end)
end)


function getUnreceivedMessages(identifier)
    local messages = getMessages(identifier)
    local notReceivedMessages = 0

    for k, message in pairs(messages) do
    	if not message.owner then
    		if message.received == 0 then notReceivedMessages = notReceivedMessages + 1 end
    	end
    end

    return notReceivedMessages
end

--====================================================================================
--  App bourse
--====================================================================================
--[[
    local result = {
        {
            libelle = 'Google',
            price = 125.2,
            difference =  -12.1
        },
        {
            libelle = 'Microsoft',
            price = 132.2,
            difference = 3.1
        },
        {
            libelle = 'Amazon',
            price = 120,
            difference = 0
        }
    }
]]

function getInfoBorsa()
    local tavola = {}

    table.insert(tavola, {
        libelle = "Google",
        price = 200,
        difference = -10
    })
    
    return tavola
end


--====================================================================================
--  Telefoni Fissi
--====================================================================================


function onCallFixePhone(player, phone_number, rtcOffer, extraData)
    local indexCall = lastIndexCall
    lastIndexCall = lastIndexCall + 1

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then
        phone_number = string.sub(phone_number, 2)
    end
    
	local identifier = gcPhone.getPlayerID(player)

    local srcPhone = ''
    if extraData ~= nil and extraData.useNumber ~= nil then
        srcPhone = extraData.useNumber
    else
        srcPhone = gcPhone.getPhoneNumber(identifier)
    end

    local canCall = not isNumberInCall(phone_number)

    if canCall then
        Chiamate[indexCall] = {
            id = indexCall,
            transmitter_src = player,
            transmitter_num = srcPhone,
            receiver_src = nil,
            receiver_num = phone_number,
            is_valid = false,
            is_accepts = false,
            hidden = hidden,
            rtcOffer = rtcOffer,
            extraData = extraData,
            coords = Config.TelefoniFissi[phone_number].coords
        }
        
        PhoneFixeInfo[indexCall] = Chiamate[indexCall]

        TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, PhoneFixeInfo)
        TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[indexCall], true)
    else
        TriggerClientEvent("esx:showNotification", player, "~r~Il telefono è occupato")
        -- xPlayer.showNotification("Il telefono è occupato", "error")
    end
end


function isNumberInCall(phone_number)
    for k, infoCall in pairs(Chiamate) do
        if infoCall.receiver_num == phone_number then return true end
    end

    return false
end


function onAcceptFixePhone(player, infoCall, rtcAnswer)
    local id = infoCall.id
    if Chiamate[id] ~= nil then

        Chiamate[id].receiver_src = player

        playersInCall[Chiamate[id].transmitter_src] = true
        playersInCall[Chiamate[id].receiver_src] = true

        if Chiamate[id].transmitter_src ~= nil and Chiamate[id].receiver_src ~= nil then
            Chiamate[id].is_accepts = true
            Chiamate[id].forceSaveAfter = true
            Chiamate[id].rtcAnswer = rtcAnswer
            PhoneFixeInfo[id] = nil
            TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, PhoneFixeInfo)

            TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].transmitter_src, Chiamate[id], true)

            if Chiamate[id] ~= nil then
                SetTimeout(0, function() TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].receiver_src, Chiamate[id], false) end)
            end

            salvaChiamata(Chiamate[id])
        end
    end
end


function onRejectFixePhone(player, infoCall, rtcAnswer)
    local id = infoCall.id
    PhoneFixeInfo[id] = nil
    TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, PhoneFixeInfo)

    TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].transmitter_src, "TEST")
    if Chiamate[id].is_accepts == false then salvaChiamata(Chiamate[id]) end

    Chiamate[id] = nil 
end


--[[
    Citizen.CreateThread(function()
        while ESX == nil do Citizen.Wait(100) end
        
        while true do
            Citizen.Wait(5000)

            print(ESX.DumpTable(cachedNumbers))
        end
    end)
]]