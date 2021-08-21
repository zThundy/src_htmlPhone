cartesimT = {}
local tunnel = module("zth_gcphone", "modules/TunnelV2")
tunnel.bindInterface(Config.AuthKey, "cartesim_server_t", cartesimT)

if GetResourceState("esx_simcards") == "started" or GetResourceState("esx_sim") == "started" then
    print("^1[ZTH_Phone] ^0[^3WARNING^0] Please remove esx_simcards or esx_sim resource from your server")
    StopResource("esx_simcards")
    StopResource("esx_sim")
end

local function GenerateUniquePhoneNumber(result)
    local numbers = {}
    for index, value in pairs(result) do
        numbers[tostring(value.phone_number)] = true
    end
    math.randomseed(os.time()); math.randomseed(os.time()); math.randomseed(os.time())
    local rand_number = string.format(Config.SimFormat, math.random(11111, 99999))
    if numbers[tostring(rand_number)] == nil then
        return rand_number
    end
    return GenerateUniquePhoneNumber(result)
end

local function NewSim(source)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function(result)
        local result = MySQL.Sync.fetchAll("SELECT * FROM phone_sim", {})
        local phone_number = GenerateUniquePhoneNumber(result)
        
        if phone_number ~= nil then
            MySQL.Async.insert('INSERT INTO phone_sim(phone_number, identifier, piano_tariffario, minuti, messaggi, dati) VALUES(@phone_number, @identifier, @piano_tariffario, @minuti, @messaggi, @dati)', {
                ['@phone_number'] = phone_number,
                ['@identifier'] = xPlayer.identifier,
                ['@piano_tariffario'] = "nessuno",
                ['@minuti'] = 0,
                ['@messaggi'] = 0,
                ['@dati'] = 0
            }, function(id)
                showXNotification(xPlayer, Config.Language["SIM_CREATED_MESSAGE_OK"])
                gcPhoneT.updateCachedNumber(phone_number, xPlayer.identifier, false)

                CACHED_TARIFFS[phone_number] = {
                    phone_number = phone_number,
                    identifier = xPlayer.identifier,
                    piano_tariffario = "nessuno",
                    minuti = 0,
                    messaggi = 0,
                    dati = 0,
                    id = id,
                    nome_sim = phone_number
                }
            end)
        else
            showXNotification(xPlayer, Config.Language["SIM_CREATED_MESSAGE_ERROR"])
        end
    end)
end

ESX.RegisterUsableItem(Config.SimItemName, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(Config.SimItemName, 1)
    NewSim(source)
end)

RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    local identifier = xPlayer.identifier
    if not identifier then identifier = gcPhoneT.getPlayerID(source) end
    local phone_number = gcPhoneT.getPhoneNumber(identifier)

    if phone_number ~= nil then
        gcPhoneT.updateCachedNumber(phone_number, identifier, false)

        if CACHED_TARIFFS[phone_number] then
            for _, v in pairs(Config.Tariffs) do
                if v.label == CACHED_TARIFFS[phone_number].piano_tariffario then
                    TriggerClientEvent("gcphone:updateValoriDati", source, {
                        {
                            current = tonumber(math.floor(CACHED_TARIFFS[phone_number].minuti / 60)),
                            max = tonumber(v.minuti),
                            icon = "phone",
                            suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_1"]
                        },
                        {
                            current = tonumber(CACHED_TARIFFS[phone_number].messaggi),
                            max = tonumber(v.messaggi),
                            icon = "message",
                            suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_2"]
                        },
                        {
                            current = tonumber(CACHED_TARIFFS[phone_number].dati),
                            max = tonumber(v.dati),
                            icon = "discovery",
                            suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_3"]
                        }
                    })
                    return
                end
            end
        end
    else
        gcPhone.debug(Config.Language["DEBUG_NO_SIM_FOUND"]:format(identifier))
    end
end)

cartesimT.daiSim = function(number, c_id)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local xPlayer2 = ESX.GetPlayerFromId(c_id)
            
    if number ~= nil then
        showXNotification(xPlayer, Config.Language["SIM_GIVEN_MESSAGE_1"]:format(number))
        showXNotification(xPlayer2, Config.Language["SIM_GIVEN_MESSAGE_2"]:format(number))
        gcPhoneT.updateCachedNumber(number, xPlayer2.identifier, false)
        MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier AND phone_number = @number", {
            ['@identifier'] = xPlayer.identifier,
            ['@number'] = number
        }, function(result)
            if result and result[1] then
                MySQL.Async.execute('UPDATE `users` SET phone_number = @phone_number WHERE `identifier` = @identifier', {
                    ['@identifier']   = xPlayer.identifier,
                    ['@phone_number'] = 0
                })

                CACHED_TARIFFS[number].phone_number = number
                CACHED_TARIFFS[number].identifier = xPlayer.identifier
            end
        end)

        MySQL.Async.execute('UPDATE phone_sim SET identifier = @identifier WHERE phone_number = @phone_number', {
            ['@identifier'] = xPlayer2.identifier,
            ['@phone_number'] = number
        })
    end
end

cartesimT.eliminaSim = function(old_number)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)

    if tostring(old_number) == tostring(phone_number) then
        MySQL.Async.execute('UPDATE `users` SET phone_number = @phone_number WHERE `identifier` = @identifier', {
            ['@identifier'] = identifier,
            ['@phone_number'] = 0
        })
    end

    MySQL.Async.execute('DELETE FROM phone_sim WHERE phone_number = @phone_number', {['@phone_number'] = old_number})
    gcPhoneT.updateCachedNumber(old_number, false, false)
    CACHED_TARIFFS[old_number] = nil
end

cartesimT.usaSim = function(sim)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    gcPhoneT.updateCachedNumber(sim.number, identifier, true)
    CACHED_TARIFFS[sim.number].identifier = identifier
    CACHED_TARIFFS[sim.number].phone_number = sim.number
    MySQL.Async.execute('UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@phone_number'] = sim.number
    })
end

cartesimT.rinominaSim = function(number, name)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    MySQL.Async.execute('UPDATE phone_sim SET nome_sim = @nome_sim WHERE identifier = @identifier AND phone_number = @phone_number', {
        ['@identifier'] = identifier,
        ['@phone_number'] = number,
        ['@nome_sim'] = name
    })
    CACHED_TARIFFS[number].phone_number = number
    CACHED_TARIFFS[number].nome_sim = name
end

cartesimT.getSimList = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local cartesim = {}
    for number, v in pairs(CACHED_TARIFFS) do
        if identifier == v.identifier then
            if v.nome_sim ~= '' then
                table.insert(cartesim, { label = tostring(v.nome_sim), value = v, piano_tariffario = v.piano_tariffario })
            else
                table.insert(cartesim, { label = tostring(number), value = v, piano_tariffario = v.piano_tariffario })
            end
        end
    end
    return cartesim
end

cartesimT.getOfferFromNumber = function(number)
    return CACHED_TARIFFS[number]
end

cartesimT.renewOffer = function(label, number)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local moneys = xPlayer.getAccount("bank").money
    for k, v in pairs(Config.Tariffs) do
        if v.label == label and moneys >= v.price then
            xPlayer.removeAccountMoney("bank", v.price)
            MySQL.Async.execute("UPDATE phone_sim SET minuti = @minuti, messaggi = @messaggi, dati = @dati WHERE phone_number = @phone_number", {
                ['@phone_number'] = number,
                ['@minuti'] = v.minuti * 60,
                ['@messaggi'] = v.messaggi,
                ['@dati'] = v.dati
            })
            CACHED_TARIFFS[number].minuti = v.minuti * 60
            CACHED_TARIFFS[number].messaggi = v.messaggi
            CACHED_TARIFFS[number].dati = v.dati
            return true
        else
            return false
        end
    end
end

cartesimT.buyOffer = function(label, number)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local moneys = xPlayer.getAccount("bank").money
    local tb = {}
    -- this check is done serverside because users can inject
    -- code in client and change the values as they like
    for _, v in pairs(Config.Tariffs) do
        if v.label == label then
            tb = v
            break
        end
    end
    if moneys >= tb.price then
        xPlayer.removeAccountMoney("bank", tb.price)
        MySQL.Async.execute("UPDATE phone_sim SET piano_tariffario = @piano_tariffario, minuti = @minuti, messaggi = @messaggi, dati = @dati WHERE phone_number = @phone_number", {
            ['@phone_number'] = number,
            ['@piano_tariffario'] = tb.label,
            ['@minuti'] = tb.minuti * 60,
            ['@messaggi'] = tb.messaggi,
            ['@dati'] = tb.dati
        })
        CACHED_TARIFFS[number].minuti = tb.minuti * 60
        CACHED_TARIFFS[number].messaggi = tb.messaggi
        CACHED_TARIFFS[number].dati = tb.dati
        CACHED_TARIFFS[number].piano_tariffario = tb.label
        CACHED_NUMBERS[number].piano_tariffario = tb.label
        TriggerClientEvent("gcphone:updateValoriDati", player, {
            {
                current = tonumber(math.floor(tb.minuti)),
                max = tonumber(tb.minuti),
                icon = "phone",
                suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_1"]
            },
            {
                current = tonumber(tb.messaggi),
                max = tonumber(tb.messaggi),
                icon = "message",
                suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_2"]
            },
            {
                current = tonumber(tb.dati),
                max = tonumber(tb.dati),
                icon = "discovery",
                suffix = Config.Language["PHONE_TARIFFS_APP_LABEL_3"]
            }
        })
        return true
    else
        return false
    end
end