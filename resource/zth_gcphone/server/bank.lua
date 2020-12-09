RegisterServerEvent("gcPhone:sendMoneyToUser")
AddEventHandler("gcPhone:sendMoneyToUser", function(data)
    local iban = data.iban
    local amount = tonumber(data.money)

    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    getUserFromIban(iban, function(user)
        if user ~= nil then
            local c_xPlayer = ESX.GetPlayerFromIdentifier(user.identifier)

            if c_xPlayer ~= nil and xPlayer ~= nil then
                if xPlayer.getBank() >= amount then

                    xPlayer.showNotification("Hai inviato "..amount.."$ all'iban "..iban, "success")
                    c_xPlayer.showNotification("Hai ricevuto un bonifico di "..amount.."$ dall'iban "..xPlayer.iban, "success")

                    c_xPlayer.addBank(amount)
                    xPlayer.removeBank(amount)

                    TriggerClientEvent("gcPhone:updateBankAmount", xPlayer.source, xPlayer.getBank(), xPlayer.iban)
                    TriggerClientEvent("gcPhone:updateBankAmount", c_xPlayer.source, c_xPlayer.getBank(), c_xPlayer.iban)
                end
            else
                xPlayer.showNotification("Iban non trovato o non valido", "error")
            end
        end
    end)
end)

function getUserFromIban(iban, cb)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE iban = '"..iban.."'", {}, function(result)
        cb(result[1])
    end)
end