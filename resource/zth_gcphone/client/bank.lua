RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
    ESX.TriggerServerCallback("gcphone:bank_getBankInfo", function(bank, iban)
        SendNUIMessage({event = 'updateBankbalance', soldi = PlayerData.bank, iban = PlayerData.iban})
    end)
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


RegisterNetEvent("gcPhone:updateBankAmount")
AddEventHandler("gcPhone:updateBankAmount", function(amount, iban)
    SendNUIMessage({event = 'updateBankbalance', soldi = amount, iban = iban})
end)

