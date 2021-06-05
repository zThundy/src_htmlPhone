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
        ESX.ShowNotification(Config.Language["BOURSE_CRYPTO_BOUGHT_OK"]:format(data.amount, data.crypto.name, data.crypto.currentMarket))
    else
        ESX.ShowNotification(Config.Language["BOURSE_CRYPTO_BOUGHT_ERROR"])
    end
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    SendNUIMessage({ event = "receiveMyCrypto", crypto = gcPhoneServerT.getMyCrypto() })
    cb("ok")
end)

RegisterNUICallback("sellCrypto", function(data, cb)
    local ok = gcPhoneServerT.sellCrypto(data)
    if ok then
        ESX.ShowNotification(Config.Language["BOURSE_CRYPTO_SELL_OK"]:format(data.amount, data.crypto.name, data.price))
    else
        ESX.ShowNotification(Config.Language["BOURSE_CRYPTO_SELL_ERROR"])
    end
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    SendNUIMessage({ event = "receiveMyCrypto", crypto = gcPhoneServerT.getMyCrypto() })
    cb("ok")
end)

-- RegisterNetEvent("testfluc")
-- AddEventHandler("testfluc", function()
--     SendNUIMessage({ event = "receiveBourseCrypto", crypto = gcPhoneServerT.requestCryptoValues() })
-- end)