ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local tunnel = module("modules/TunnelV2")
gcPhoneT = {}
tunnel.bindInterface("gcphone", "gcphone_server_t", gcPhoneT)

Chiamate = {}
CALL_INDEX = 10

local PLAYERS_PHONE_SIGNALS = {}
local PLAYERS_PHONE_WIFI = {}
ACTIVE_CALLS = {}
phone_loaded = false

GLOBAL_AIRPLANE = {}
CACHED_NUMBERS = {}
CACHED_NAMES = {}
CACHED_CONTACTS = {}
CACHED_MESSAGES = {}
CACHED_CALLS = {}
CACHED_TARIFFS = {}

AddEventHandler("playerDropped", function(reason)
    local player = source
    TriggerClientEvent("gcphone:animations_doCleanup", player)
    gcPhone.debug(translate("ANIMATIONS_CLEANUP_DEBUG_2"))
end)

MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_messages WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})
    MySQL.Async.execute("DELETE FROM phone_calls WHERE (DATEDIFF(CURRENT_DATE, time) > 15)", {})

    MySQL.Async.fetchAll("SELECT * FROM phone_sim", {}, function(numbers)
        for _, v in pairs(numbers) do
            CACHED_NUMBERS[tostring(v.phone_number)] = { identifier = v.identifier, inUse = false }
        end

        gcPhone.debug(translate("CACHING_STARTUP_5"))
        MySQL.Async.fetchAll("SELECT phone_number, identifier FROM users WHERE phone_number IS NOT NULL", {}, function(users)
            for _, v in pairs(users) do
                if CACHED_NUMBERS[tostring(v.phone_number)] and CACHED_NUMBERS[tostring(v.phone_number)].identifier == v.identifier then
                    CACHED_NUMBERS[tostring(v.phone_number)].inUse = true
                end
            end

            gcPhone.debug(translate("CACHING_STARTUP_1"))
            MySQL.Async.fetchAll("SELECT * FROM phone_users_contacts", {}, function(contacts)
                for id, contact in pairs(contacts) do
                    if not CACHED_CONTACTS[tostring(contact.identifier)] then CACHED_CONTACTS[tostring(contact.identifier)] = {} end
                    table.insert(CACHED_CONTACTS[tostring(contact.identifier)], contact)
                end

                gcPhone.debug(translate("CACHING_STARTUP_2"))
                MySQL.Async.fetchAll("SELECT * FROM phone_messages", {}, function(messages)
                    for id, message in pairs(messages) do
                        if not CACHED_MESSAGES[message.receiver] then CACHED_MESSAGES[message.receiver] = {} end
                        table.insert(CACHED_MESSAGES[message.receiver], message)
                    end

                    MySQL.Async.fetchAll("SELECT * FROM phone_calls", {}, function(calls)
                        for _, call in pairs(calls) do
                            if not CACHED_CALLS[call.owner] then CACHED_CALLS[call.owner] = {} end
                            table.insert(CACHED_CALLS[call.owner], call)
                        end

                        gcPhone.debug(translate("CACHING_STARTUP_3"))
                        for _, v in pairs(numbers) do
                            CACHED_TARIFFS[v.phone_number] = v
                        end

                        gcPhone.debug(translate("WIFI_LOAD_DEBUG_8"))
                        gcPhone.debug(translate("CACHING_STARTUP_4"))
                        phone_loaded = true
                    end)
                end)
            end)
        end)
    end)
end)

if Config.EnableRadioTowers then
    Citizen.CreateThreadNow(function()
        while true do
            Citizen.Wait(Config.TimeToSaveTariffs * 1000)
            gcPhone.debug(translate("DEBUG_STARTED_SAVING_OF_TARIFFS"))
            for _, v in pairs(CACHED_TARIFFS) do
                MySQL.Async.execute("UPDATE phone_sim SET minuti = @m, messaggi = @s, dati = @i WHERE id = @id", {
                    ['@m'] = v.minuti,
                    ['@s'] = v.messaggi,
                    ['@i'] = v.dati,
                    ['@id'] = v.id
                })
                Citizen.Wait(50)
            end
        end
    end)
end

local function GetPianoTariffarioParam(phone_number, param)
    while not phone_loaded do Citizen.Wait(100) end
    local result = nil
    if CACHED_TARIFFS[phone_number] and CACHED_TARIFFS[phone_number][param] then
        result = CACHED_TARIFFS[phone_number][param]
    end
    return result and result or 0
end

local function UpdatePianoTariffario(phone_number, param, value)
    while not phone_loaded do Citizen.Wait(100) end
    if phone_number ~= nil and param ~= nil and value ~= nil then
        if CACHED_TARIFFS[phone_number] and CACHED_TARIFFS[phone_number][param] then
            CACHED_TARIFFS[phone_number][param] = value
        end
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
        TriggerClientEvent("gcPhone:allMessage", player, getMessages(phone_number), notReceivedMessages)
        SyncCallHistory(player, phone_number)
        -- qui aggiorno la nui e la tariffa quando metti la sim o quando entri nel server;
        -- messa per ultima così tutte le cache sono aggiornate a questo punto e siamo tutti felici
        gcPhoneT.requestOfferFromCache()
    end)
end

gcPhoneT.updateAirplaneForUser = function(bool)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GLOBAL_AIRPLANE[identifier] = bool
end

gcPhoneT.getAirplaneForUser = function(identifier)
    return GLOBAL_AIRPLANE[identifier]
end

-- maybe create asyncronus event and remove this function
gcPhoneT.updateSegnaleTelefono = function(potenza)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, identifier)
    if iSegnalePlayer == nil then
    	table.insert(PLAYERS_PHONE_SIGNALS, {identifier = identifier, potenzaSegnale = potenza})
    else
		PLAYERS_PHONE_SIGNALS[iSegnalePlayer].potenzaSegnale = potenza
    end
end

gcPhoneT.updateReteWifi = function(connected, rete)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_WIFI, identifier)
    if iSegnalePlayer == nil then
    	table.insert(PLAYERS_PHONE_WIFI, {identifier = identifier, connected = connected, rete = rete})
    else
		PLAYERS_PHONE_WIFI[iSegnalePlayer].connected = connected
		PLAYERS_PHONE_WIFI[iSegnalePlayer].rete = rete
    end
end

gcPhoneT.getPlayerSegnaleIndex = function(tb, identifier)
    for i = 1, #tb do if tostring(tb[i].identifier) == tostring(identifier) then return i end end
end

gcPhoneT.useInternetData = function(identifier, value)
    if Config.EnableRadioTowers then
        local phone_number = gcPhoneT.getPhoneNumber(identifier)
        local dati = GetPianoTariffarioParam(phone_number, "dati")
        gcPhoneT.updateParametroTariffa(phone_number, "dati", dati - value)
    end
end

gcPhoneT.isAbleToSurfInternet = function(identifier, neededMB)
	local phone_number = gcPhoneT.getPhoneNumber(identifier)
	local iSegnalePlayer = gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, identifier)
    local iWifiConnectedPlayer = gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_WIFI, identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(identifier)
    if Config.EnableRadioTowers then
        if iWifiConnectedPlayer ~= nil and PLAYERS_PHONE_WIFI[iWifiConnectedPlayer].connected then
            return true, 0
        else
            if not hasAirplane and phone_number then
                if iSegnalePlayer ~= nil and PLAYERS_PHONE_SIGNALS[iSegnalePlayer].potenzaSegnale ~= 0 then
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
    else
        return true, 0
    end
end

gcPhoneT.isAbleToCall = function(identifier, cb)
	local phone_number = gcPhoneT.getPhoneNumber(identifier)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(identifier)
    if not hasAirplane and phone_number then
        local min = GetPianoTariffarioParam(phone_number, "minuti")
        if Config.IgnoredPlanJobs[xPlayer.job.name] then return cb(true, false, min) end

        -- callback should be
        -- isAble, useMin, min, message
        if Config.EnableRadioTowers then
            if min == nil then
                cb(false, true, 0, translate("PHONE_TARIFFS_NO_TARIFF"))
            else
                if min > 0 then
                    cb(true, true, min)
                else
                    cb(false, true, 0, translate("PHONE_TARIFFS_NO_MINUTES"))
                end
            end
        else
            cb(true, false, 0)
        end
    else
        cb(false, true, 0, translate("PHONE_TARIFFS_AIRPLANEMODE_ERROR"))
    end
end

gcPhoneT.updateParametroTariffa = function(phone_number, param, value)
	UpdatePianoTariffario(phone_number, param, value)
end

gcPhoneT.getFirstnameAndLastname = function(identifier)
    if not identifier then
        gcPhone.debug(translate("FIRSTNAME_LASTNAME_ERROR"))
        local player = source
        local xPlayer = ESX.GetPlayerFromId(player)
        identifier = xPlayer.identifier
    end
    -- fill values if loaded query had some errors
    if not CACHED_NAMES[identifier] then
        -- this needs to be syncronus cause return :)
        MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier}, function(r)
            if (r and r[1]) and (r[1].firstname and r[1].lastname) then
                CACHED_NAMES[identifier] = {
                    firstname = r[1].firstname,
                    lastname = r[1].lastname
                }
            end
        end)
    end
    if CACHED_NAMES[identifier] then
        return CACHED_NAMES[identifier].firstname, CACHED_NAMES[identifier].lastname
    else
        return translate("EMPTY_FIELD_LABEL"), translate("EMPTY_FIELD_LABEL")
    end
end

gcPhoneT.getFirstAndSecondJob = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    if Config.EnableSecondJobs then return xPlayer.job, xPlayer.job2 end
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

gcPhoneT.updateCachedNumber = function(number, identifier, isChanging)
    number = tostring(number)

    -- check if the identifier is given to log it correctly
    if identifier then
        gcPhone.debug(translate("CACHE_NUMBERS_1"):format(number, identifier))
    else
        gcPhone.debug(translate("CACHE_NUMBERS_2"):format(number))
    end

    -- get the old number for this given isdentifier
    local oldNumber = gcPhoneT.getPhoneNumber(identifier)

    -- qui controllo se la il numero sta venendo cambiato
    -- con un altra sim
    if CACHED_NUMBERS[number] ~= nil then
        if CACHED_NUMBERS[oldNumber] ~= nil then
            if isChanging then
                CACHED_NUMBERS[oldNumber].inUse = false
                CACHED_NUMBERS[number].inUse = true
            else
                -- da esx_cartesim al login del player
                gcPhone.debug(translate("CACHE_NUMBERS_3"):format(identifier, number))
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
    return tostring(xPlayer.identifier)
end

function getContacts(identifier)
    if not CACHED_CONTACTS[tostring(identifier)] then CACHED_CONTACTS[tostring(identifier)] = {} end
    return CACHED_CONTACTS[tostring(identifier)]
end

gcPhoneT.updateAvatarContatto = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    MySQL.Async.execute("UPDATE phone_users_contacts SET icon = @icon WHERE id = @id", {
        ['@icon'] = data.icon,
        ['@id'] = data.id
    }, function()
        for _, contact in pairs(CACHED_CONTACTS[tostring(identifier)]) do
            if contact.id == data.id then
                contact.icon = data.icon
                break
            end
        end
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end)
end

gcPhoneT.addContact = function(display, number, email, icon)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    if icon == "" then icon = nil end
    if not CACHED_CONTACTS[tostring(identifier)] then CACHED_CONTACTS[tostring(identifier)] = {} end
    if identifier ~= nil and number ~= nil and display ~= nil then
        MySQL.Async.insert("INSERT INTO phone_users_contacts(`identifier`, `number`, `display`, `email`, `icon`) VALUES(@identifier, @number, @display, @email, @icon)", {
            ['@identifier'] = identifier,
            ['@number'] = number,
            ['@display'] = display,
            ['@email'] = email,
            ['@icon'] = icon
        }, function(id)
            table.insert(CACHED_CONTACTS[tostring(identifier)], {
                id = id,
                identifier = identifier,
                number = number,
                display = display,
                icon = icon,
                email = email
            })
            TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
        end)
    else
        TriggerClientEvent("esx:showNotification", player, translate("ADD_CONTACT_ERROR"))
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
        for _, contact in pairs(CACHED_CONTACTS[tostring(identifier)]) do
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
        for table_index, contact in pairs(CACHED_CONTACTS[tostring(identifier)]) do
            if contact.id == id then
                table.remove(CACHED_CONTACTS[tostring(identifier)], table_index)
                break
            end
        end
        TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
    end)
end

function getMessages(number)
    if not number then return {} end
    if not CACHED_MESSAGES[number] then CACHED_MESSAGES[number] = {} end
    return CACHED_MESSAGES[number]
end

function addMessage(source, identifier, phone_number, message)
    local player = tonumber(source)
    local otherIdentifier, isInstalled = gcPhoneT.getIdentifierByPhoneNumber(phone_number)
    local myPhone = gcPhoneT.getPhoneNumber(identifier)
    local hasAirplane = gcPhoneT.getAirplaneForUser(otherIdentifier)
    if otherIdentifier and myPhone then
        segnaleTransmitter = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, identifier)]
    	if segnaleTransmitter and segnaleTransmitter.potenzaSegnale > 0 then
            local messaggi = GetPianoTariffarioParam(myPhone, "messaggi")
            if messaggi > 0 then
                UpdatePianoTariffario(myPhone, "messaggi", messaggi - 1)
                _addMessage(phone_number, myPhone, message, 1, function(memess)
                    TriggerClientEvent("gcPhone:receiveMessage", player, memess, false)
                    _addMessage(myPhone, phone_number, message, 0, function(tomess)
                        gcPhoneT.getSourceFromIdentifier(otherIdentifier, function(target_source)
                            target_source = tonumber(target_source)
                            if target_source ~= nil then
                                -- qui controllo se la sim a cui stai mandando il
                                -- messaggio è installata o no
                                if isInstalled and not hasAirplane then
                                    -- print("sim installata")
                                    -- se la sim è installata allora mando il telefono e gli mando la notifica
                                    segnaleReceiver = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, otherIdentifier)]
                                    if segnaleReceiver ~= nil and segnaleReceiver.potenzaSegnale > 0 then
                                        TriggerClientEvent("gcPhone:receiveMessage", target_source, tomess, true)
                                        setMessageReceived(phone_number, myPhone)
                                    end
                                else
                                    -- questo è l'evento che ti fa il bing quando invii il messaggio
                                    -- lo ho tolto così non fa la notifica
                                    setMessageReceived(phone_number, myPhone)
                                end
                            end
                        end)
                    end)
                end)
            else
                TriggerClientEvent("esx:showNotification", player, translate("ADD_MESSAGE_ERROR_1"))
            end
        else
            TriggerClientEvent("esx:showNotification", player, translate("ADD_MESSAGE_ERROR_2"))
        end
    else
        TriggerClientEvent("esx:showNotification", player, translate("ADD_MESSAGE_ERROR_3"))
    end 
end

gcPhoneT.sendMessage = function(phoneNumber, message)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    addMessage(player, identifier, phoneNumber, message)
end

function _addMessage(transmitter, receiver, message, owner, cb)
    if not CACHED_MESSAGES[receiver] then CACHED_MESSAGES[receiver] = {} end
    MySQL.Async.insert("INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`, `owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)", {
        ['@transmitter'] = transmitter,
        ['@receiver'] = receiver,
        ['@message'] = message,
        ['@isRead'] = owner,
        ['@owner'] = owner
    }, function(id)
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
        cb(message)
    end)
end

gcPhoneT.setReadMessageNumber = function(transmitter_number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local receiver_number = gcPhoneT.getPhoneNumber(identifier)
    if not receiver_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
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
    MySQL.Async.execute("UPDATE phone_messages SET received = 1 WHERE receiver = @receiver AND transmitter = @transmitter", {
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
    if not phone_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
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
    if not receiver_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
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
    if not receiver_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
    CACHED_MESSAGES[receiver_number] = {}
    -- need to choose the clean table or the complete delete of table
    -- maybe i'll leave the empty table
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
    gcPhoneT.deleteAllPhoneHistory(identifier)
    TriggerClientEvent("gcPhone:contactList", player, {})
    TriggerClientEvent("gcPhone:allMessage", player, {})
    TriggerClientEvent("deleteAllPhoneHistory", player, {})
end

function GetCallsHistory(num)
    if CACHED_CALLS[num] then
        table.sort(CACHED_CALLS[num], function(a, b)
            -- this is really bad, but table sort is worse
            if not a then a = {} end
            if not b then b = {} end
            -- ok...
            if not a.time then a.time = os.time() * 1000 end
            if not b.time then b.time = os.time() * 1000 end
            -- ok x2...
            if a and b then return a.time > b.time end
        end)
        return CACHED_CALLS[num]
    end
    return false
end

function SyncCallHistory(player, num)
    local histo = GetCallsHistory(num)
    if histo then
        TriggerClientEvent('gcPhone:historyCalls', player, histo)
    end
end

function SavePhoneCall(callData)
    if not callData.extraData or not callData.extraData.useNumber and (callData and callData.transmitter_num and callData.receiver_num) then
        MySQL.Async.insert("INSERT INTO phone_calls (`owner`, `num`, `incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['@owner'] = callData.transmitter_num,
            ['@num'] = callData.receiver_num,
            ['@incoming'] = 1,
            ['@accepts'] = callData.is_accepts
        }, function(id)
            if not CACHED_CALLS[callData.transmitter_num] then CACHED_CALLS[callData.transmitter_num] = {} end
            table.insert(CACHED_CALLS[callData.transmitter_num], {
                owner = callData.transmitter_num,
                num = callData.receiver_num,
                incoming = true,
                accepts = callData.is_accepts,
                id = id,
                time = os.time() * 1000
            })
            SyncCallHistory(callData.transmitter_src, callData.transmitter_num)
        end)
    end
    if callData.is_valid then
        local num = callData.transmitter_num
        if callData.hidden then num = Config.HiddenNumberFormat end
        MySQL.Async.insert("INSERT INTO phone_calls(`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['@owner'] = callData.receiver_num,
            ['@num'] = num,
            ['@incoming'] = 0,
            ['@accepts'] = callData.is_accepts
        }, function(id)
            if callData.receiver_src ~= nil then
                if not CACHED_CALLS[callData.receiver_num] then CACHED_CALLS[callData.receiver_num] = {} end
                table.insert(CACHED_CALLS[callData.receiver_num], {
                    owner = callData.transmitter_num,
                    num = num,
                    incoming = false,
                    accepts = callData.is_accepts,
                    id = id,
                    time = os.time() * 1000
                })
                SyncCallHistory(callData.receiver_src, callData.receiver_num)
            end
        end)
    end
end

gcPhoneT.deletePhoneHistory = function(number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    if not phone_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
    MySQL.Async.execute("DELETE FROM phone_calls WHERE `owner` = @owner AND `num` = @num", {
        ['@owner'] = phone_number,
        ['@num'] = number
    }, function()
        for id, v in pairs(CACHED_CALLS[phone_number]) do
            if v.num == number then
                CACHED_CALLS[phone_number][id] = nil
            end
        end
    end)
end

gcPhoneT.deleteAllPhoneHistory = function(identifier)
    local player = source
    if player then identifier = gcPhoneT.getPlayerID(player) end
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    if not phone_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
    MySQL.Async.execute("DELETE FROM phone_calls WHERE `owner` = @owner", { ['@owner'] = phone_number }, function()
        CACHED_CALLS[phone_number] = {}
    end)
end

gcPhoneT.requestOfferFromCache = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    if not phone_number then return gcPhone.debug(translate("DEBUG_PHONENUMBER_NIL")) end
    if CACHED_TARIFFS[phone_number] then
        local sim = CACHED_TARIFFS[phone_number]
        TriggerClientEvent("gcPhone:sendRequestedOfferta", player, { tonumber(math.floor(sim.minuti / 60)), tonumber(sim.messaggi), tonumber(sim.dati) }, sim.piano_tariffario)
    else
        TriggerClientEvent("gcPhone:sendRequestedOfferta", player, { 0, 0, 0 }, "nessuno")
    end
end

gcPhoneT.startCall = function(phone_number, rtcOffer, extraData)
    local player = source
    if Config.PhoneBoxes[phone_number] ~= nil then
        CallStaticPhone(player, phone_number, rtcOffer, extraData)
        return
    end

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
    if not srcPhone then return TriggerClientEvent("esx:showNotification", player, translate("STARTCALL_NO_SIM_INSTALLED")) end
    -- srcPhone è il numero di telefono di chi ha avviato la chiamata
    
    -- qui mi prendo tutte le informazioni del giocatore a cui sto chiamanto
    -- (infatti phone_number è il numero che ricevo dal telefono)
    local destPlayer, isInstalled = gcPhoneT.getIdentifierByPhoneNumber(phone_number)
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
        if isAble then
            Chiamate[CALL_INDEX].secondiRimanenti = min
            segnaleTransmitter = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, srcIdentifier)]
            Chiamate[CALL_INDEX].updateMinuti = useMin

            -- qui controllo se la funzione gcPhoneT.getIdentifierByPhoneNumber ha tornato un valore valido, che non sto chiamando
            -- me stesso, e che la sim sia installata
            if is_valid and isInstalled then
                gcPhoneT.getSourceFromIdentifier(destPlayer, function(srcTo)
                    if ACTIVE_CALLS[srcTo] == nil then
                        if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                            if srcTo ~= nil then
                                segnaleReceiver = PLAYERS_PHONE_SIGNALS[gcPhoneT.getPlayerSegnaleIndex(PLAYERS_PHONE_SIGNALS, destPlayer)]
                                if segnaleReceiver ~= nil and segnaleReceiver.potenzaSegnale > 0 then
                                    Chiamate[CALL_INDEX].receiver_src = srcTo
                                    TriggerEvent('gcPhone:addCall', Chiamate[CALL_INDEX])
                                    TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[CALL_INDEX], true)
                                    TriggerClientEvent('gcPhone:waitingCall', srcTo, Chiamate[CALL_INDEX], false)
                                else
                                    PlaySegreteria(player, Chiamate[CALL_INDEX])
                                end
                            else
                                PlaySegreteria(player, Chiamate[CALL_INDEX])
                            end
                        else
                            PlayNoSignal(player, Chiamate[CALL_INDEX])
                            TriggerClientEvent("esx:showNotification", player, translate("STARTCALL_MESSAGE_ERROR_1"))
                        end
                    else
                        PlayNoSignal(player, Chiamate[CALL_INDEX])
                        TriggerClientEvent("esx:showNotification", player, translate("STARTCALL_MESSAGE_ERROR_2"))
                    end
                end)
            else
                if segnaleTransmitter ~= nil and segnaleTransmitter.potenzaSegnale > 0 then
                    if Chiamate[CALL_INDEX].receiver_num == '190' then
                        TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[CALL_INDEX], true)
                    else 
                        PlaySegreteria(player, Chiamate[CALL_INDEX])
                    end
                else
                    Chiamate[CALL_INDEX].noSignal = true
                    PlayNoSignal(player, Chiamate[CALL_INDEX])
                    TriggerClientEvent("esx:showNotification", player, translate("STARTCALL_MESSAGE_ERROR_3"))
                end
            end
        else
            TriggerClientEvent("esx:showNotification", player, "~r~"..message)
        end

        CALL_INDEX = CALL_INDEX + 1
    end)
end

function PlaySegreteria(player, infoCall)
    infoCall.updateMinuti = false
    TriggerEvent('gcPhone:addCall', infoCall)
    TriggerClientEvent('gcPhone:waitingCall', player, infoCall, true)
    TriggerClientEvent('gcPhone:phoneVoiceMail', player, infoCall, true)
end

function PlayNoSignal(player, infoCall)
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
    if infoCall and infoCall.id and Chiamate[infoCall.id] then
        local id = infoCall.id
        if FIXED_PHONES_INFO[id] ~= nil then
            onAcceptStaticPhone(player, infoCall, rtcAnswer)
            return
        end
        ACTIVE_CALLS[Chiamate[id].transmitter_src] = true
        Chiamate[id].receiver_src = infoCall.receiver_src or Chiamate[id].receiver_src
        if Chiamate[id].receiver_src then ACTIVE_CALLS[Chiamate[id].receiver_src] = true end
        Chiamate[id].startCall_time = os.time()
        if Chiamate[id].transmitter_src and Chiamate[id].receiver_src then
            Chiamate[id].is_accepts = true
            Chiamate[id].rtcAnswer = rtcAnswer
            TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].transmitter_src, Chiamate[id], true)
            SetTimeout(1, function()
                TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].receiver_src, Chiamate[id], false)
            end)
            SavePhoneCall(Chiamate[id])
        end
    end
end

gcPhoneT.ignoreCall = function(infoCall)
    if infoCall.transmitter_src ~= nil then TriggerClientEvent('gcPhone:rejectCall', infoCall.transmitter_src, infoCall, true) end
end

gcPhoneT.rejectCall = function(infoCall)
    local player = source
    if infoCall and infoCall.id and Chiamate[infoCall.id] ~= nil then
        local id = infoCall.id
        Chiamate[id].endCall_time = os.time()
        Chiamate[id].forcedCallDrop = infoCall.forcedCallDrop
        ACTIVE_CALLS[Chiamate[id].transmitter_src] = nil
        if Chiamate[id].receiver_src ~= nil then  ACTIVE_CALLS[Chiamate[id].receiver_src] = nil end
        if FIXED_PHONES_INFO[id] ~= nil then
            onRejectFixePhone(player, infoCall)
            return
        end
        if Chiamate[id].transmitter_src ~= nil then
            TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].transmitter_src, Chiamate[id], Chiamate[id].transmitter_src ~= player and Chiamate[id].is_accepts)
        end
        if Chiamate[id].receiver_src ~= nil then
            TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].receiver_src, Chiamate[id], Chiamate[id].receiver_src ~= player and Chiamate[id].is_accepts)
        end
        if not Chiamate[id].is_accepts then SavePhoneCall(Chiamate[id]) end
        Chiamate[id] = nil
    end
end

RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    local player = tonumber(source)
    local identifier = xPlayer.identifier
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    TriggerClientEvent("gcPhone:updatePhoneNumber", player, phone_number)
    TriggerClientEvent("gcPhone:contactList", player, getContacts(identifier))
   	local notReceivedMessages = getUnreceivedMessages(phone_number)
    if notReceivedMessages > 0 then setMessagesReceived(phone_number) end
    TriggerClientEvent("gcPhone:allMessage", player, getMessages(phone_number), notReceivedMessages)
    MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier}, function(r)
        if (r and r[1]) and (r[1].firstname and r[1].lastname) then
            CACHED_NAMES[identifier] = {
                firstname = r[1].firstname,
                lastname = r[1].lastname
            }
        end
    end)
end)

function getUnreceivedMessages(phone_number)
    local messages = getMessages(phone_number)
    local notReceivedMessages = 0
    for k, message in pairs(messages) do
    	if not message.owner then
    		if message.received == 0 then notReceivedMessages = notReceivedMessages + 1 end
    	end
    end
    return notReceivedMessages
end