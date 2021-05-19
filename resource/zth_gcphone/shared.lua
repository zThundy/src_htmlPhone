gcPhone = {}

function gcPhone.debug(message)
    if Config.PhoneDebug then
        print("^1[ZTH_Phone] ^0" .. message)
    end
end

Reti = {}

function Reti.Debug(msg)
    if Config.WifiDebug then
        print("^1[ZTH_WiFi] ^0" .. msg)
    end
end