RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    ESX.TriggerServerCallback("gcphone:bank_getBankInfo", function(bank, iban)
        SendNUIMessage({ event = 'updateBankbalance', soldi = bank, iban = iban })
    end)
end)

RegisterNetEvent("gcphone:bank_sendBankMovements")
AddEventHandler("gcphone:bank_sendBankMovements", function(movements)
    SendNUIMessage({ event = "updateBankMovements", movements = movements })
end)

RegisterNUICallback("sendMoneyToIban", function(data, cb)
    -- TriggerEvent('gcphone:sendMoneyToIban', data.iban, data.money)
    gcPhoneServerT.sendMoneyToUser(data)
    cb("ok")
end)

RegisterNUICallback("requestBankInfo", function(data, cb)
    ESX.TriggerServerCallback("gcphone:bank_getBankInfo", function(bank, iban)
        SendNUIMessage({ event = 'updateBankbalance', soldi = bank, iban = iban })
    end)
    cb("ok")
end)

RegisterNUICallback("requestFatture", function(data, cb)
    -- ESX.TriggerServerCallback("gcphone:bank_requestMyFatture", function(fatture)
    --     cb(fatture)
    -- end)
    
    ESX.TriggerServerCallback("esx_billing:getBills", function(fatture)
        -- print(ESX.DumpTable(fatture))
        -- cb(fatture)
        SendNUIMessage({ event = "receivePlayerFatture", fatture = fatture })
    end)
    cb("ok")
end)

RegisterNUICallback("pagaFattura", function(data, cb)
    ESX.TriggerServerCallback("esx_billing:payBill", function(ok)
        if ok then
            -- print("^1[ZTH_Phone] ^0Bill payed")
            ESX.TriggerServerCallback("esx_billing:getBills", function(fatture) SendNUIMessage({ event = "receivePlayerFatture", fatture = fatture }) end)
        end
    end, data.id)
    
    cb("ok")
end)

RegisterNetEvent("gcPhone:updateBankAmount")
AddEventHandler("gcPhone:updateBankAmount", function(amount, iban)
    SendNUIMessage({ event = 'updateBankbalance', soldi = amount, iban = iban })
end)

