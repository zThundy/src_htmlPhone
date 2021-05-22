RegisterNUICallback("requestBourseProfile", function(data, cb)
    SendNUIMessage({ event = "receiveBourseProfile", profile = gcPhoneServerT.getBourseProfile() })
    cb("ok")
end)

RegisterNUICallback("requestBourseCrypto", function(data, cb)
    SendNUIMessage({ event = "receiveBourseCrypto", crypto = gcPhoneServerT.requestCryptoValues() })
    cb("ok")
end)

RegisterNUICallback("buyCrytpo", function(data, cb)
    print(json.encode(data))
    cb("ok")
end)

RegisterNetEvent("testfluc")
AddEventHandler("testfluc", function()
    SendNUIMessage({ event = "receiveBourseCrypto", crypto = gcPhoneServerT.requestCryptoValues() })
end)