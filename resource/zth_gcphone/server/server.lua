ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- gcPhone = {}

local tunnel = module("modules/TunnelV2")
gcPhoneT = {}
tunnel.bindInterface("gcphone_server_t", gcPhoneT)

Chiamate = {}
CALL_INDEX = 10

segnaliTelefoniPlayers = {}
wifiConnectedPlayers = {}
playersInCall = {}
-- built_phones = false
phone_loaded = false

GLOBAL_AIRPLANE = {}
CACHED_NUMBERS = {}
CACHED_NAMES = {}
CACHED_CONTACTS = {}
CACHED_MESSAGES = {}

AddEventHandler("playerDropped", function(reason)
    local player = source
    TriggerClientEvent("gcphone:animations_doCleanup", player)

    gcPhone.debug("User " .. player .. " dropping. Doing cleanup")
end)

MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_messages WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})
    MySQL.Async.execute("DELETE FROM phone_twitter_tweets WHERE (DATEDIFF(CURRENT_DATE, time) > 20)", {})
    MySQL.Async.execute("DELETE FROM phone_calls WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})

    gcPhone.debug("Caching members. Lag expected")

    MySQL.Async.fetchAll("SELECT phone_number, identifier FROM sim", {}, function(numbers)
        for _, v in pairs(numbers) do
            CACHED_NUMBERS[tostring(v.phone_number)] = {identifier = v.identifier, inUse = false}

            --[[
                da esx_cartesim aggiorno la sim in uso al
                login del plater, quindi non mi serve fare tutte ste query

                MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = v.identifier}, function(user)
                    if user ~= nil and user[1] ~= nil then
                        if user[1].phone_number == v.phone_number then
                            CACHED_NUMBERS[tostring(v.phone_number)].inUse = true
                        end
                    end
                end)
            ]]
        end

        gcPhone.debug("Numbers cache loaded from sim database")
        MySQL.Async.fetchAll("SELECT * FROM phone_users_contacts", {}, function(contacts)
            for id, contact in pairs(contacts) do
                -- print(DumpTable(contact))
                if not CACHED_CONTACTS[contact.identifier] then CACHED_CONTACTS[contact.identifier] = {} end
                table.insert(CACHED_CONTACTS[contact.identifier], contact)
            end

            gcPhone.debug("Contacts cache loaded from phone contacts database")
            MySQL.Async.fetchAll("SELECT * FROM phone_messages", {}, function(messages)
                for id, message in pairs(messages) do
                    -- print(DumpTable(message))
                    if not CACHED_MESSAGES[message.receiver] then CACHED_MESSAGES[message.receiver] = {} end
                    table.insert(CACHED_MESSAGES[message.receiver], message)
                end

                gcPhone.debug("Messages cache loaded from phone messages database")
                gcPhone.debug("Phone initialized")
                phone_loaded = true
            end)
        end)
    end)
end)

local function GetPianoTariffarioParam(phone_number, param)
    local result = MySQL.Sync.fetchScalar("SELECT " .. param .. " FROM sim WHERE phone_number = @phone_number", {
        ['@phone_number'] = phone_number
    })

    -- print(phone_number, param)
    return result and result or 0
end

local function UpdatePianoTariffario(phone_number, param, value)
    if phone_number ~= nil and param ~= nil and value ~= nil then
		MySQL.Async.execute('UPDATE sim SET '..param..' = @'..param..' WHERE phone_number = @phone_number', {
			['@phone_number'] = phone_number,
			['@'..param] = value
		})
	end
end

gcPhoneT.allUpdate = function()
    local player = source
    -- creo il thread per evitare di fare il wait sul main
    -- thread
    Citizen.CreateThreadNow(function()
        while not phone_loaded do Citizen.Wait(100) end

        local identifier = gcPhoneT.getPlayerID(player)
        local phone_number = gcPhoneT.getPhoneNumber(identifier)

        TriggerClientEvent("gcPhone:updatePhoneNumber", player, phone_number)
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))

        local notReceivedMessages = getUnreceivedMessages(phone_number)
        -- if notReceivedMessages > 0 then setMessagesReceived(num) end

        TriggerClientEvent("gcPhone:allMessage", player, getMessages(phone_number), notReceivedMessages)

        sendHistoriqueCall(player, phone_number)
    end)
end

--==================================================================================================================
-------- Eventi e Funzioni del segnale radio e del WiFi
--==================================================================================================================

gcPhoneT.updateAirplaneForUser = function(bool)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GLOBAL_AIRPLANE[identifier] = bool
end

gcPhoneT.updateSegnaleTelefono = function(potenza)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)

    if iSegnalePlayer == nil then
    	table.insert(segnaliTelefoniPlayers, {identifier = identifier, potenzaSegnale = potenza})
    else
		segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale = potenza
    end
end

gcPhoneT.updateReteWifi = function(connected, rete)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(wifiConnectedPlayers, identifier)
    
    if iSegnalePlayer == nil then
    	table.insert(wifiConnectedPlayers, {identifier = identifier, connected = connected, rete = rete})
    else
		wifiConnectedPlayers[iSegnalePlayer].connected = connected
		wifiConnectedPlayers[iSegnalePlayer].rete = rete
    end
end

gcPhoneT.getAirplaneForUser = function(identifier)
    return GLOBAL_AIRPLANE[identifier]
end

gcPhoneT.getPlayerSegnaleIndex = function(tabella, identifier)
	index = nil
	
    for i=1, #tabella do
        if tostring(tabella[i].identifier) == tostring(identifier) then
            -- print("index is", i, "for id", identifier)
			index = i
		end
	end
	
	return index
end

gcPhoneT.usaDatiInternet = function(identifier, value)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
	local dati = GetPianoTariffarioParam(phone_number, "dati")

    gcPhoneT.updateParametroTariffa(phone_number, "dati", dati - value)
end

gcPhoneT.isAbleToSurfInternet = function(identifier, neededMB)
	local phone_number = gcPhoneT.getPhoneNumber(identifier)
	
	local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)
    local iWifiConnectedPlayer = gcPhoneT.getPlayerSegnaleIndex(wifiConnectedPlayers, identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(identifier)
    
    if iWifiConnectedPlayer ~= nil and wifiConnectedPlayers[iWifiConnectedPlayer].connected then
        return true, 0
    else
        if not hasAirplane and phone_number then
            if iSegnalePlayer ~= nil and segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale ~= 0 then
                local dati = GetPianoTariffarioParam(phone_number, "dati")
                if dati > 0 and dati >= neededMB then
                    return true, neededMB
                else
                    return false, 0
                end
            else
                return false, 0
            end
        else
            return false, 0
        end
    end
end

gcPhoneT.isAbleToSendMessage = function(identifier, cb)
	local phone_number = gcPhoneT.getPhoneNumber(identifier)
	
    local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(identifier)
    
    if not hasAirplane and phone_number then
        if segnaliTelefoniPlayers[iSegnalePlayer] ~= nil and segnaliTelefoniPlayers[iSegnalePlayer].potenzaSegnale > 0 then
            local messaggi = GetPianoTariffarioParam(phone_number, "messaggi")
            if messaggi > 0 then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end

gcPhoneT.isAbleToCall = function(identifier, cb)
	local phone_number = gcPhoneT.getPhoneNumber(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(identifier)
    
    if not hasAirplane and phone_number then
        local min = GetPianoTariffarioParam(phone_number, "minuti")
        if Config.IgnoredPlanJobs[xPlayer.job.name] then return cb(true, false, min) end

        if min == nil then
            cb(false, true, 0, "~r~Non hai un piano tariffario!")
        else
            if min > 0 then
                cb(true, true, min)
            else
                cb(false, true, 0, "~r~Hai finito i minuti previsti dalla tua offerta!")
            end
        end
    else
        cb(false, true, 0, "~r~Non puoi chiamare con la modalità aereo")
    end
end

gcPhoneT.updateParametroTariffa = function(phone_number, param, value)
	UpdatePianoTariffario(phone_number, param, value)
end

gcPhoneT.getFirstnameAndLastname = function(identifier)
    if not identifier then
        gcPhone.debug("Error getting firstname and lastname, identifier not specified: using source insted")
        local player = source
        local xPlayer = ESX.GetPlayerFromId(player)
        identifier = xPlayer.identifier
    end

    -- fill values if loaded query had some errors
    if not CACHED_NAMES[identifier] then
        -- this needs to be syncronus cause return :)
        -- print(identifier)
        local r = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
        if (r and r[1]) and (r[1].firstname and r[1].lastname) then
            CACHED_NAMES[identifier] = {
                firstname = r[1].firstname,
                lastname = r[1].lastname
            }
        end
    end

    if CACHED_NAMES[identifier] then
        return CACHED_NAMES[identifier].firstname, CACHED_NAMES[identifier].lastname
    else
        return "None", "None"
    end
end

gcPhoneT.getFirstAndSecondJob = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if Config.EnableSecondJobs then
        return xPlayer.job, xPlayer.job2
    end

    return xPlayer.job, nil
end

gcPhoneT.getItemAmount = function(item)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local items = xPlayer.getInventoryItem(item)

    if not items or items.count == 0 then
        return 0
    else
        return items.count
    end
end

--==================================================================================================================
-------- Utils
--==================================================================================================================

gcPhoneT.updateCachedNumber = function(number, identifier, isChanging)
    -- print(number, identifier, isChanging)
    number = tostring(number)
    identifier = identifier

    if identifier then
        gcPhone.debug("Updated number " .. number .. " for identifier " .. identifier)
    else
        gcPhone.debug("Removed number " .. number .. " from CACHED_NUMBERS")
    end

    local oldNumber = gcPhoneT.getPhoneNumber(identifier)
    -- print(ESX.DumpTable(CACHED_NUMBERS[number]), ESX.DumpTable(CACHED_NUMBERS[oldNumber]), oldNumber)

    -- qui controllo se la il numero sta venendo cambiato
    -- con un altra sim
    if CACHED_NUMBERS[number] ~= nil then
        if CACHED_NUMBERS[oldNumber] ~= nil then
            if isChanging then
                CACHED_NUMBERS[oldNumber].inUse = false
                CACHED_NUMBERS[number].inUse = true
            else
                -- da esx_cartesim al login del player
                gcPhone.debug("User " .. identifier .. " is joining, registering " .. number .. " as 'inUse' number")
                -- print("Registrando numero al login", number, identifier)
                CACHED_NUMBERS[number].inUse = true
            end
        else
            -- in realtà questo potrebbe essere inutile :/ IDK
            -- forse evita bug :)
            CACHED_NUMBERS[number].inUse = true
        end
    end

    -- qui modifico solo l'indentifier, quindi nel caso io
    -- la stia passando a qualcuno, oppure nel caso in cui
    -- la stia eliminando
    if identifier then
        -- nel caso in cui la stia passando a qualcuno, resetto lo
        -- stato inUse della sim
        if CACHED_NUMBERS[number] ~= nil then
            if tostring(CACHED_NUMBERS[number].identifier) ~= tostring(identifier) then
                CACHED_NUMBERS[number].inUse = false
            end

            CACHED_NUMBERS[number].identifier = identifier
        else
            -- nel caso in cui la sim non esiste nella cache, la aggiungo
            CACHED_NUMBERS[number] = {identifier = identifier, inUse = false}
        end
    else
        CACHED_NUMBERS[number] = nil
    end
end

gcPhoneT.getSourceFromIdentifier = function(identifier, cb)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer ~= nil then cb(xPlayer.source) else cb(nil) end
end

gcPhoneT.getPhoneNumber = function(identifier)
    --[[
        local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier })
        if #result > 0 then return result[1].phone_number end
    ]]

    if identifier then
        for number, v in pairs(CACHED_NUMBERS) do
            if tostring(v.identifier) == tostring(identifier) and v.inUse then
                return number
            end
        end
    end

    return nil
end

gcPhoneT.getIdentifierByPhoneNumber = function(phone_number)
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
    if CACHED_NUMBERS[phone_number] == nil then return nil, false end

    return CACHED_NUMBERS[phone_number].identifier, CACHED_NUMBERS[phone_number].inUse
end

gcPhoneT.getSourceFromPhoneNumber = function(phone_number)
    local identifier, _ = gcPhoneT.getIdentifierByPhoneNumber(phone_number)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if xPlayer == nil then return nil end

    return xPlayer.source
end

gcPhoneT.getPlayerID = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer == nil then return nil end
    
    return xPlayer.identifier
end

--==================================================================================================================
-------- Funzioni Contatti
--==================================================================================================================

function getContacts(identifier)
    -- print(DumpTable(CACHED_CONTACTS))
    if not CACHED_CONTACTS[identifier] then CACHED_CONTACTS[identifier] = {} end
    return CACHED_CONTACTS[identifier]
end

gcPhoneT.updateAvatarContatto = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)

    MySQL.Async.execute("UPDATE phone_users_contacts SET icon = @icon WHERE id = @id", {
        ['@icon'] = data.icon,
        ['@id'] = data.id
    }, function()
        for _, contact in pairs(CACHED_CONTACTS[identifier]) do
            if contact.id == data.id then
                contact.icon = data.icon
                break
            end
        end
        
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end)
end

gcPhoneT.addContact = function(display, number, email)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    
    if not CACHED_CONTACTS[identifier] then CACHED_CONTACTS[identifier] = {} end
    if identifier ~= nil and number ~= nil and display ~= nil then
        MySQL.Async.insert("INSERT INTO phone_users_contacts(`identifier`, `number`, `display`, `email`) VALUES(@identifier, @number, @display, @email)", {
            ['@identifier'] = identifier,
            ['@number'] = number,
            ['@display'] = display,
            ['@email'] = email
        }, function(id)
            table.insert(CACHED_CONTACTS[identifier], {
                id = id,
                identifier = identifier,
                number = number,
                display = display,
                icon = nil,
                email = email
            })

            TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
        end)
    else
        TriggerClientEvent("esx:showNotification", player, "~r~Devi inserire un numero e un titolo validi!")
    end
end

gcPhoneT.updateContact = function(id, display, number, email)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    
    MySQL.Async.execute("UPDATE phone_users_contacts SET number = @number, display = @display, email = @email WHERE id = @id", { 
        ['@number'] = number,
        ['@display'] = display,
        ['@id'] = id,
        ['@email'] = email
    },function()
        for _, contact in pairs(CACHED_CONTACTS[identifier]) do
            if contact.id == id then
                contact.number = number
                contact.display = display
                contact.email = email
                break
            end
        end

        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end)
end

gcPhoneT.deleteContact = function(id)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    
    MySQL.Async.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier AND `id` = @id", {
        ['@identifier'] = identifier,
        ['@id'] = id,
    }, function()
        for table_index, contact in pairs(CACHED_CONTACTS[identifier]) do
            if contact.id == id then
                table.remove(CACHED_CONTACTS[identifier], table_index)
                break
            end
        end
    
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end)
end

--==================================================================================================================
-------- Eventi e Funzioni dei Messaggi
--==================================================================================================================

function getMessages(number)
    -- return MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", { ['@identifier'] = identifier })
    if not number then return {} end
    if not CACHED_MESSAGES[number] then CACHED_MESSAGES[number] = {} end
    return CACHED_MESSAGES[number]
end

function addMessage(source, identifier, phone_number, message)
    -- print(source, identifier, phone_number, message)
    local player = tonumber(source)
    -- local xPlayer = ESX.GetPlayerFromId(player)

    local otherIdentifier, isInstalled = gcPhoneT.getIdentifierByPhoneNumber(phone_number)
    local myPhone = gcPhoneT.getPhoneNumber(identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(otherIdentifier)

    -- print(otherIdentifier, isInstalled)
    
    if otherIdentifier and myPhone then
        segnaleTransmitter = segnaliTelefoniPlayers[gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, identifier)]

    	if segnaleTransmitter and segnaleTransmitter.potenzaSegnale > 0 then
            local messaggi = GetPianoTariffarioParam(myPhone, "messaggi")
            if messaggi > 0 then
                UpdatePianoTariffario(myPhone, "messaggi", messaggi - 1)

                local memess = _internalAddMessage(phone_number, myPhone, message, 1)
                TriggerClientEvent("gcPhone:receiveMessage", player, memess)
                -- print(ESX.DumpTable(memess))
                
                local tomess = _internalAddMessage(myPhone, phone_number, message, 0)
                -- print(ESX.DumpTable(tomess))

                gcPhoneT.getSourceFromIdentifier(otherIdentifier, function(target_source)
                    target_source = tonumber(target_source)

                    if target_source ~= nil then
                        
                        -- qui controllo se la sim a cui stai mandando il
                        -- messaggio è installata o no
                        if isInstalled and not hasAirplane then
                            -- print("sim installata")
                            -- se la sim è installata allora mando il telefono e gli mando la notifica
                            -- local retIndex = gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, otherIdentifier)
                            -- print(retIndex)
                            segnaleReceiver = segnaliTelefoniPlayers[gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, otherIdentifier)]
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
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non c'è segnale per mandare un messaggio")
        	-- xPlayer.showNotification("Non c'è segnale per mandare un messaggio", "error")
        end
    else
        TriggerClientEvent("esx:showNotification", player, "~r~Impossibile mandare il messaggio, il numero selezionato non esiste")
        -- xPlayer.showNotification("Impossibile mandare il messaggio, il numero selezionato non esiste", "error")
    end 
end

gcPhoneT.sendMessage = function(phoneNumber, message)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    addMessage(player, identifier, phoneNumber, message)
end

gcPhoneT.internalAddMessage = function(transmitter, receiver, message, owner)
    return _internalAddMessage(transmitter, receiver, message, owner)
end

function _internalAddMessage(transmitter, receiver, message, owner)
    if not CACHED_MESSAGES[receiver] then CACHED_MESSAGES[receiver] = {} end
    local id = MySQL.Sync.insert("INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`, `owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)", {
        ['@transmitter'] = transmitter,
        ['@receiver'] = receiver,
        ['@message'] = message,
        ['@isRead'] = owner,
        ['@owner'] = owner
    })

    -- print(os.time())
    local message = {
        id = id,
        transmitter = transmitter,
        receiver = receiver,
        message = message,
        time = os.time() * 1000,
        isRead = owner,
        owner = owner,
        received = 0
    }

    table.insert(CACHED_MESSAGES[receiver], message)
    return message
end

gcPhoneT.setReadMessageNumber = function(transmitter_number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local receiver_number = gcPhoneT.getPhoneNumber(identifier)

    for _, message in pairs(CACHED_MESSAGES[receiver_number]) do
        if message.transmitter == transmitter_number and message.receiver == receiver_number then
            message.isRead = 1
            break
        end
    end

    MySQL.Async.execute("UPDATE phone_messages SET isRead = 1 WHERE receiver = @receiver AND transmitter = @transmitter", {
        ['@receiver'] = receiver_number,
        ['@transmitter'] = transmitter_number
    })
end

function setMessageReceived(receiver_number, transmitter_number)
    for _, message in pairs(CACHED_MESSAGES[receiver_number]) do
        if message.transmitter == transmitter_number and message.receiver == receiver_number then
            message.received = 1
            break
        end
    end

    MySQL.Sync.execute("UPDATE phone_messages SET received = 1 WHERE receiver = @receiver AND transmitter = @transmitter", {
        ['@receiver'] = receiver_number,
        ['@transmitter'] = transmitter_number
    })
end

function setMessagesReceived(receiver_number)
    for _, message in pairs(CACHED_MESSAGES[receiver_number]) do
        if message.receiver == receiver_number then
            message.received = 1
        end
    end

    MySQL.Async.execute("UPDATE phone_messages SET received = 1 WHERE receiver = @receiver", {
        ['@receiver'] = receiver_number
    })
end

gcPhoneT.deleteMessage = function(id)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)

    for table_index, message in pairs(CACHED_MESSAGES[phone_number]) do
        if message.id == id then
            table.remove(CACHED_MESSAGES[phone_number], table_index)
            break
        end
    end

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `id` = @id", { ['@id'] = id })
end

gcPhoneT.deleteMessageNumber = function(transmitter_number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local receiver_number = gcPhoneT.getPhoneNumber(identifier)

    for table_index, message in pairs(CACHED_MESSAGES[receiver_number]) do
        if message.transmitter == transmitter_number and message.receiver == receiver_number then
            table.remove(CACHED_MESSAGES[receiver_number], table_index)
            break
        end
    end

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `receiver` = @receiver and `transmitter` = @transmitter", { 
        ['@receiver'] = receiver_number, 
        ['@transmitter'] = transmitter_number 
    })
end

gcPhoneT.deleteReceivedMessages = function(identifier)
    local receiver_number = gcPhoneT.getPhoneNumber(identifier)
    CACHED_MESSAGES[receiver_number] = {}
    -- need to choose the clean table or the complete delete of table
    -- maybe i'll leave the empty table
    -- CACHED_MESSAGES[receiver_number] = nil

    MySQL.Async.execute("DELETE FROM phone_messages WHERE `receiver` = @receiver", { ['@receiver'] = receiver_number })
end

gcPhoneT.deleteAllMessage = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    gcPhoneT.deleteReceivedMessages(identifier)
end

gcPhoneT.deleteAll = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)

    gcPhoneT.deleteReceivedMessages(identifier)
    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier", { ['@identifier'] = identifier })
    gcPhoneT.appelsDeleteAllHistorique(identifier)

    TriggerClientEvent("gcPhone:contactList", player, {})
    TriggerClientEvent("gcPhone:allMessage", player, {})
    TriggerClientEvent("appelsDeleteAllHistorique", player, {})
end

--==================================================================================================================
-------- Eventi e Funzioni delle chiamate
--==================================================================================================================

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

--[[
    USELESS

    RegisterServerEvent('gcPhone:getHistoriqueCall')
    AddEventHandler('gcPhone:getHistoriqueCall', function()
        local player = tonumber(source)
        local identifier = gcPhoneT.getPlayerID(player)
        local num = gcPhoneT.getPhoneNumber(identifier)

        sendHistoriqueCall(player, num)
    end)
]]

gcPhoneT.requestOffertaFromDatabase = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(user)
        if #user > 0 then
            if user[1].phone_number ~= nil then
                MySQL.Async.fetchAll("SELECT * FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = user[1].phone_number}, function(sim)
                    if #sim > 0 then
                        minuti = math.floor(sim[1].minuti / 60)
                        
                        TriggerClientEvent("gcPhone:sendRequestedOfferta", player, {
                            tonumber(minuti),
                            tonumber(sim[1].messaggi),
                            tonumber(sim[1].dati)
                        }, sim[1].piano_tariffario)
                    end
                end)
            end
        end
    end)
end

gcPhoneT.startCall = function(phone_number, rtcOffer, extraData)
    local player = source
    -- print(player, phone_number, rtcOffer, extraData)
    internal_startCall(player, phone_number, rtcOffer, extraData)
end

-- evento che controlla le chiamate tra giocatori
-- e giocatori e telefoni fissi
function internal_startCall(player, phone_number, rtcOffer, extraData)
    if Config.PhoneBoxes[phone_number] ~= nil then
        onCallFixePhone(player, phone_number, rtcOffer, extraData)
        return
    end

    -- local xPlayer = ESX.GetPlayerFromId(player)
    local srcIdentifier = gcPhoneT.getPlayerID(player)
    -- srcIdentifier è l'identifier del giocatore che ha
    -- avviato la chiamata
    
    local rtcOffer = rtcOffer
    if phone_number == nil or phone_number == '' then return end

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then phone_number = string.sub(phone_number, 2) end
    -- phone_number è il numero di telefono di chi riceve la chiamata

    local indexCall = CALL_INDEX
    CALL_INDEX = CALL_INDEX + 1

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

    gcPhoneT.isAbleToCall(srcIdentifier, function(isAble, useMin, min, message)
        Chiamate[indexCall].secondiRimanenti = min
        segnaleTransmitter = segnaliTelefoniPlayers[gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, srcIdentifier)]
        Chiamate[indexCall].updateMinuti = useMin

        -- qui controllo se la funzione gcPhoneT.getIdentifierByPhoneNumber ha tornato un valore valido, che non sto chiamando
        -- me stesso, e che la sim sia installata
        if is_valid and isInstalled and not hasAirplane then
            gcPhoneT.getSourceFromIdentifier(destPlayer, function(srcTo)

                if playersInCall[srcTo] == nil then
                    if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                        if srcTo ~= nil then
                            segnaleReceiver = segnaliTelefoniPlayers[gcPhoneT.getPlayerSegnaleIndex(segnaliTelefoniPlayers, destPlayer)]

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
end

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

gcPhoneT.candidates = function(callId, candidates)
    local player = source
    if Chiamate[callId] ~= nil then
        local to = Chiamate[callId].transmitter_src
        if player == to then  to = Chiamate[callId].receiver_src end

        if to == nil then return end
        TriggerClientEvent('gcPhone:candidates', to, candidates)
    end
end

gcPhoneT.acceptCall = function(infoCall, rtcAnswer)
    local player = source
    local id = infoCall.id

    -- print("call accepted", player)
    -- print(ESX.DumpTable(infoCall))

    if Chiamate[id] ~= nil then
        -- print(ESX.DumpTable(Chiamate[id]))
        if FIXED_PHONES_INFO[id] ~= nil then
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

            if id and Chiamate[id] ~= nil then
                SetTimeout(0, function()
                    if id then
                        TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].receiver_src, Chiamate[id], false)
                    end
                end)
            end
            salvaChiamata(Chiamate[id])
        end
    end
end

-- useless for now
gcPhoneT.ignoreCall = function(infoCall)

end

-- evento che toglie i minuti a chi ha
-- fatto la telefonata
gcPhoneT.rejectCall = function(infoCall)
    local player = source
    local id = infoCall.id

    if Chiamate[id] ~= nil then
        playersInCall[Chiamate[id].transmitter_src] = nil
        if Chiamate[id].receiver_src ~= nil then
            playersInCall[Chiamate[id].receiver_src] = nil
        end

        if FIXED_PHONES_INFO[id] ~= nil then
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
end

gcPhoneT.appelsDeleteHistorique = function(number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local num = gcPhoneT.getPhoneNumber(identifier)

    MySQL.Sync.execute("DELETE FROM phone_calls WHERE `owner` = @owner AND `num` = @num", {
        ['@owner'] = num,
        ['@num'] = number
    })
end

gcPhoneT.appelsDeleteAllHistorique = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local num = gcPhoneT.getPhoneNumber(identifier)

    MySQL.Async.execute("DELETE FROM phone_calls WHERE `owner` = @owner", { ['@owner'] = num })
end

--==================================================================================================================
-------- Funzioni e Eventi chiamati al load della risorsa e al caricamento di un player
--==================================================================================================================

-- function buildPhones()
--     for telefono, info_telefono in pairs(Config.PhoneBoxes) do
--         TriggerClientEvent("gcphone:spawnObjectAtCoords", -1, info_telefono.coords, "prop_cs_phone_01", false)
--     end
--     built_phones = true
-- end

RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    local player = tonumber(source)
    -- if not built_phones then buildPhones() end

    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)

    TriggerClientEvent("gcPhone:updatePhoneNumber", player, phone_number)
    TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))

   	local notReceivedMessages = getUnreceivedMessages(phone_number)
    if notReceivedMessages > 0 then setMessagesReceived(phone_number) end

    TriggerClientEvent("gcPhone:allMessage", player, getMessages(phone_number), notReceivedMessages)

    local r = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    if (r and r[1]) and (r[1].firstname and r[1].lastname) then
        CACHED_NAMES[identifier] = {
            firstname = r[1].firstname,
            lastname = r[1].lastname
        }
    end
    -- MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(r)
    --     if r[1] and r[1].firstname and r[2].lastname then
    --         CACHED_NAMES[xPlayer.identifier] = {
    --             firstname = r[1].firstname,
    --             lastname = r[1].lastname
    --         }
    --     end
    -- end)
end)

function getUnreceivedMessages(phone_number)
    -- local phone_number = gcPhoneT.getPhoneNumber(identifier)
    local messages = getMessages(phone_number)
    local notReceivedMessages = 0

    for k, message in pairs(messages) do
    	if not message.owner then
    		if message.received == 0 then notReceivedMessages = notReceivedMessages + 1 end
    	end
    end

    return notReceivedMessages
end