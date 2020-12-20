RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
    ESX.TriggerServerCallback("gcphone:bank_getBankInfo", function(bank, iban)
        SendNUIMessage({event = 'updateBankbalance', soldi = bank, iban = iban})
    end)
end)


RegisterNetEvent("gcphone:bank_sendBankMovements")
AddEventHandler("gcphone:bank_sendBankMovements", function(movements)
    SendNUIMessage({ event = "updateBankMovements", movements = movements })
end)


RegisterNUICallback("sendMoneyToIban", function(data, cb)
    TriggerServerEvent("gcPhone:sendMoneyToUser", data)
    cb("ok")
end)


RegisterNUICallback("requestBankInfo", function(data, cb)
    ESX.TriggerServerCallback("gcphone:bank_getBankInfo", function(bank, iban)
        SendNUIMessage({event = 'updateBankbalance', soldi = bank, iban = iban})
    end)
    cb("ok")
end)


RegisterNUICallback("requestFatture", function(data, cb)
    ESX.TriggerServerCallback("gcphone:bank_requestMyFatture", function(fatture)
        cb(fatture)
    end)
end)


RegisterNUICallback("pagaFattura", function(data, cb)
    TriggerServerEvent("gcphone:bank_pagaFattura", data)
    cb("ok")
end)


RegisterNetEvent("gcPhone:updateBankAmount")
AddEventHandler("gcPhone:updateBankAmount", function(amount, iban)
    SendNUIMessage({event = 'updateBankbalance', soldi = amount, iban = iban})
end)

