local IBANS = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT identifier, iban FROM users", {}, function(r)
        for _, v in pairs(r) do
            if v.iban then
                IBANS[v.identifier] = v.iban
            end
        end
    end)
end)

RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    if not IBANS[xPlayer.identifier] then
        local new_iban = GenerateIBAN(Config.IbanStringLength)
        IBANS[xPlayer.identifier] = new_iban

        MySQL.Async.execute("UPDATE users SET iban = @iban WHERE identifier = @identifier", {
            ['@iban'] = new_iban,
            ['@identifier'] = xPlayer.identifier
        })
    end
end)

gcPhoneT.sendMoneyToUser = function(data)
    local player = source
    local iban = data.iban
    local xPlayer = ESX.GetPlayerFromId(player)

    if iban:find("INSERISCI") or iban:find("IBAN") or iban:find("DESTINATARIO") then
        xPlayer.showNotification("~r~Iban non trovato o non valido")
        return
    end

    local user_identifier = getUserFromIban(iban)
    if user_identifier ~= nil then
        if type(tonumber(data.money)) == "number" then
            data.money = string.gsub(data.money, "$", "")
            local amount = tonumber(data.money)
            local c_xPlayer = ESX.GetPlayerFromIdentifier(user_identifier)

            if c_xPlayer ~= nil and xPlayer ~= nil then
                if xPlayer.getAccount("bank").money >= amount then
                    local user_iban = getUsersIban(xPlayer.identifier)

                    xPlayer.showNotification("~g~Hai inviato "..amount.."$ all'iban "..iban)
                    c_xPlayer.showNotification("~g~Hai ricevuto un bonifico di "..amount.."$ dall'iban "..user_iban)

                    c_xPlayer.addAccountMoney("bank", amount)
                    xPlayer.removeAccountMoney("bank", amount)

                    TriggerClientEvent("gcPhone:updateBankAmount", xPlayer.source, xPlayer.getAccount("bank").money, user_iban)
                    TriggerClientEvent("gcPhone:updateBankAmount", c_xPlayer.source, c_xPlayer.getAccount("bank").money, c_user_iban)

                    updateBankMovements(xPlayer.source, xPlayer.identifier, amount, "negative", c_user_iban, user_iban)
                    updateBankMovements(c_xPlayer.source, c_xPlayer.identifier, amount, "positive", user_iban, c_user_iban)
                end
            else
                MySQL.Async.fetchAll("SELECT * FROM user_accounts WHERE identifier = @identifier AND name = @name", {
                    ['@identifier'] = user_identifier,
                    ['@name'] = "bank"
                }, function(result)
                    if result ~= nil and result[1] ~= nil then
                        MySQL.Async.execute("UPDATE user_accounts SET money = @money WHERE identifier = @identifier AND name = @name", {
                            ['@money'] = amount + result[1].money,
                            ['@identifier'] = user_identifier,
                            ['@name'] = "bank"
                        }, function()
                            xPlayer.showNotification("~g~Trasferimento completato con successo")
                        end)
                    else
                        xPlayer.showNotification("~r~Iban non trovato o non valido")
                    end
                end) 
            end
        else
            xPlayer.showNotification("~r~Il valore inserito non è un numero")
        end
    else
        xPlayer.showNotification("~r~Iban non trovato o non valido")
    end
end

function updateBankMovements(source, identifier, amount, type, iban, iban_from)
    MySQL.Async.insert("INSERT INTO phone_bank_movements(amount, `type`, `to`, `from`) VALUES(@amount, @type, @to, @from)", {
        ['@amount'] = amount,
        ['@type'] = type,
        ['@to'] = iban,
        ['@from'] = iban_from
    }, function(id)
        if id > 0 then
            -- MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from OR `to` = @to ORDER BY id DESC", {
            MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from ORDER BY id DESC", {
                ['@from'] = iban,
                ['@to'] = iban
            }, function(result)
                TriggerClientEvent("gcphone:bank_sendBankMovements", source, result)
            end)
        end
    end)
end

ESX.RegisterServerCallback("gcphone:bank_getBankInfo", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local user_iban = getUsersIban(xPlayer.identifier)

    -- MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from OR `to` = @to ORDER BY id DESC", {
    MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from ORDER BY id DESC", {
        ['@from'] = user_iban,
        ['@to'] = user_iban
    }, function(result)
        TriggerClientEvent("gcphone:bank_sendBankMovements", source, result)
    end)

    cb(xPlayer.getAccount("bank").money, user_iban)
end)

ESX.RegisterServerCallback("gcphone:bank_requestMyFatture", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM billing WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
        cb(result)
    end)
end)

function getUsersIban(identifier)
    return IBANS[identifier]
    -- return MySQL.Sync.fetchScalar("SELECT iban FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
end

function getUserFromIban(iban, cb)
    for identifier, ibn in pairs(IBANS) do
        if ibn == iban then
            return identifier
        end
    end

    return nil

    -- MySQL.Async.fetchAll("SELECT identifier FROM users WHERE iban = '"..iban.."'", {}, function(result)
    --     if result == nil or result[1] == nil then cb(nil) else cb(result[1]) end
    -- end)
end

local function GenerateString(length)
    local charset = {}

    for i = 48, 57 do table.insert(charset, string.char(i)) end	-- Numeri
    for i = 65, 90 do table.insert(charset, string.char(i)) end	-- Lettere maiuscole

    math.randomseed(os.time())

    if length > 0 then
        return GenerateString(length - 1) .. charset[math.random(1, #charset)]
    else
        return ""
    end
end

function GenerateIBAN(length)
    local ibn = ''
    local check

    repeat
        check = true
        ibn = GenerateString(length)

        for identifier, iban in ipairs(IBANS) do
            if iban == ibn and iban ~= nil then
                check = false
                break
            end
        end
    until check 

    return ibn
end



--[[
    -- da aggiungere sull'es_extended per compatibilità

    ESX.GenerateIBAN = function()
        local function GenerateString(length)
            local charset = {}
        
            for i = 48, 57 do table.insert(charset, string.char(i)) end	-- Numeri
            for i = 65, 90 do table.insert(charset, string.char(i)) end	-- Lettere maiuscole

            math.randomseed(os.time())
        
            if length > 0 then
            return GenerateString(length - 1) .. charset[math.random(1, #charset)]
            else
            return ""
            end
        end
        
        local ibn = ''
        local ibnLenght = 7

        --ibn = string.random(ibnLenght - 1) .. charset[math.random(1, #charset)]

        local ibans = MySQL.Sync.fetchAll('SELECT iban FROM users', {})

        local check

        repeat
            check = true

            ibn = GenerateString(ibnLenght)

            for index, t in ipairs(ibans) do
                if t.iban == ibn and t.iban ~= nil then
                    check = false
                    break
                end
            end

        until check 

        return ibn
    end

    -- da fare anche la compatibilità con l'xplayer
]]