local PlayerData = nil
Citizen.CreateThread(function()
    Citizen.Wait(200)

    PlayerData = ESX.GetPlayerData()

    SendNUIMessage({event = 'updateBankbalance', soldi = PlayerData.bank, iban = PlayerData.iban})
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
    SendNUIMessage({event = 'updateBankbalance', soldi = PlayerData.bank, iban = PlayerData.iban})
end)

RegisterNUICallback("sendMoneyToIban", function(data, cb)
    TriggerServerEvent("gcPhone:sendMoneyToUser", data)
    cb("ok")
end)

RegisterNetEvent("gcPhone:updateBankAmount")
AddEventHandler("gcPhone:updateBankAmount", function(amount, iban)
    SendNUIMessage({event = 'updateBankbalance', soldi = amount, iban = iban})
end)

