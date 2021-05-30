RegisterNUICallback("requestBourseProfile", function(data, cb)
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    SendNUIMessage({ event = "receiveMyCrypto", crypto = gcPhoneServerT.getMyCrypto() })
    cb("ok")
end)

RegisterNUICallback("requestBourseCrypto", function(data, cb)
    SendNUIMessage({ event = "receiveBourseCrypto", crypto = gcPhoneServerT.requestCryptoValues() })
    cb("ok")
end)

RegisterNUICallback("buyCrypto", function(data, cb)
    local ok = gcPhoneServerT.buyCrypto(data)
    if ok then
        ESX.ShowNotification("~g~Hai comprato " .. data.amount .. "x " .. data.crypto.name .. " per " .. data.crypto.currentMarket .. " l'uno")
    else
        ESX.ShowNotification("~r~La trasnazione non è avvenuta con successo")
    end
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    SendNUIMessage({ event = "receiveMyCrypto", crypto = gcPhoneServerT.getMyCrypto() })
    cb("ok")
end)

RegisterNUICallback("sellCrypto", function(data, cb)
    local ok = gcPhoneServerT.sellCrypto(data)
    if ok then
        ESX.ShowNotification("~g~Hai venduto " .. data.amount .. "x " .. data.crypto.name .. " per " .. data.price .. " l'uno")
    else
        ESX.ShowNotification("~r~La trasnazione non è avvenuta con successo")
    end
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    SendNUIMessage({ event = "receiveMyCrypto", crypto = gcPhoneServerT.getMyCrypto() })
    cb("ok")
end)

RegisterNetEvent("testfluc")
AddEventHandler("testfluc", function()
    SendNUIMessage({ event = "receiveBourseCrypto", crypto = gcPhoneServerT.requestCryptoValues() })
end)