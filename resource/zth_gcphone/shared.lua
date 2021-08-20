gcPhone = {}
Reti = {}

function gcPhone.debug(message)
    if Config.PhoneDebug then
        print("^1[ZTH_Phone] ^0" .. message)
    end
end

function Reti.Debug(msg)
    if Config.WifiDebug then
        print("^1[ZTH_WiFi] ^0" .. msg)
    end
end

-- if the file is registered server side
if IsDuplicityVersion() then
    function showXNotification(t, message)
        if t and t.showNotification then
            t.showNotification(message)
        else
            gcPhone.debug(Config.Language["NO_XPLAYER_NOTIFICATION"])
        end
    end
end