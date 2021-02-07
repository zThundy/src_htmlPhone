RegisterServerEvent("gcPhone:sendMoneyToUser")
AddEventHandler("gcPhone:sendMoneyToUser", function(data)
    local iban = data.iban

    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if iban:find("INSERISCI") or iban:find("IBAN") or iban:find("DESTINATARIO") then
        xPlayer.showNotification("~r~Iban non trovato o non valido")
        return
    end

    getUserFromIban(iban, function(user)
        if user ~= nil then
            if type(tonumber(data.money)) == "number" then
                data.money = string.gsub(data.money, "$", "")
                local amount = tonumber(data.money)
                local c_xPlayer = ESX.GetPlayerFromIdentifier(user.identifier)

                if c_xPlayer ~= nil and xPlayer ~= nil then
                    if xPlayer.getAccount("bank").money >= amount then

                        xPlayer.showNotification("~g~Hai inviato "..amount.."$ all'iban "..iban)
                        c_xPlayer.showNotification("~g~Hai ricevuto un bonifico di "..amount.."$ dall'iban "..xPlayer.iban)

                        c_xPlayer.addAccountMoney("bank", amount)
                        xPlayer.removeAccountMoney("bank", amount)

                        TriggerClientEvent("gcPhone:updateBankAmount", xPlayer.source, xPlayer.getAccount("bank").money, xPlayer.iban)
                        TriggerClientEvent("gcPhone:updateBankAmount", c_xPlayer.source, c_xPlayer.getAccount("bank").money, c_xPlayer.iban)

                        updateBankMovements(xPlayer.source, xPlayer.identifier, amount, "negative", c_xPlayer.iban, xPlayer.iban)
                        updateBankMovements(c_xPlayer.source, c_xPlayer.identifier, amount, "positive", xPlayer.iban, c_xPlayer.iban)
                    end
                else
                    MySQL.Async.fetchAll("SELECT * FROM user_accounts WHERE identifier = @identifier AND name = @name", {
                        ['@identifier'] = user.identifier,
                        ['@name'] = "bank"
                    }, function(result)
                        if result ~= nil and result[1] ~= nil then
                            MySQL.Async.execute("UPDATE user_accounts SET money = @money WHERE identifier = @identifier AND name = @name", {
                                ['@money'] = amount + result[1].money,
                                ['@identifier'] = user.identifier,
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
    end)
end)


function getUserFromIban(iban, cb)
    MySQL.Async.fetchAll("SELECT identifier FROM users WHERE iban = '"..iban.."'", {}, function(result)
        if result == nil or result[1] == nil then cb(nil) else cb(result[1]) end
    end)
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

    -- MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from OR `to` = @to ORDER BY id DESC", {
    MySQL.Async.fetchAll("SELECT * FROM phone_bank_movements WHERE `from` = @from ORDER BY id DESC", {
        ['@from'] = xPlayer.iban,
        ['@to'] = xPlayer.iban
    }, function(result)
        TriggerClientEvent("gcphone:bank_sendBankMovements", source, result)
    end)

    cb(xPlayer.getAccount("bank").money, xPlayer.iban)
end)


ESX.RegisterServerCallback("gcphone:bank_requestMyFatture", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT * FROM billing WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
        cb(result)
    end)
end)


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