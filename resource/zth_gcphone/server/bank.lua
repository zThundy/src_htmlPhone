RegisterServerEvent("gcPhone:sendMoneyToUser")
AddEventHandler("gcPhone:sendMoneyToUser", function(data)
    local iban = data.iban
    data.money = string.gsub(data.money, "$", "")
    local amount = tonumber(data.money)

    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    getUserFromIban(iban, function(user)
        if user ~= nil then
            local c_xPlayer = ESX.GetPlayerFromIdentifier(user.identifier)

            if c_xPlayer ~= nil and xPlayer ~= nil then
                if xPlayer.getAccount("bank").money >= amount then

                    xPlayer.showNotification("~g~Hai inviato "..amount.."$ all'iban "..iban)
                    c_xPlayer.showNotification("~g~Hai ricevuto un bonifico di "..amount.."$ dall'iban "..xPlayer.iban)

                    c_xPlayer.addAccountMoney("bank", amount)
                    xPlayer.removeAccountMoney("bank", amount)

                    TriggerClientEvent("gcPhone:updateBankAmount", xPlayer.source, xPlayer.getAccount("bank").money, xPlayer.iban)
                    TriggerClientEvent("gcPhone:updateBankAmount", c_xPlayer.source, c_xPlayer.getAccount("bank").money, c_xPlayer.iban)
                end
            else
                xPlayer.showNotification("~r~Iban non trovato o non valido")
            end
        end
    end)
end)


function getUserFromIban(iban, cb)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE iban = '"..iban.."'", {}, function(result)
        cb(result[1])
    end)
end


ESX.RegisterServerCallback("gcphone:bank_getBankInfo", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getAccount("bank").money, xPlayer.getIban())
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