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
            gcPhone.debug(translate("NO_XPLAYER_NOTIFICATION"))
        end
    end
end


if type(Config.Language) ~= "table" then
    print("^1[ZTH_Phone] ^0Config.Language is not defined, please check your config.lang.lua file!")
    if not Config.Language[Config.ChosenLanguage] then
        print("^1[ZTH_Phone] ^0Choosen language does not exists! Please fix the config.lang.lua!")
    end
end


function translate(m, s)
    if Config.Language[Config.ChosenLanguage] and Config.Language[Config.ChosenLanguage][m] and Config.Language[Config.ChosenLanguage][m][s] then return Config.Language[Config.ChosenLanguage][m][s] end
    for k, _ in pairs(Config.Language[Config.ChosenLanguage]) do if Config.Language[Config.ChosenLanguage][k][m] then return Config.Language[Config.ChosenLanguage][k][m] end end
    return ""
end

function getAllScopes(s)
    local tb = {}
    for k, _ in pairs(Config.Language) do
        tb[k] = Config.Language[k][s]
    end
    return tb
end

function getScope(s)
    if Config.Language[Config.ChosenLanguage][s] then return Config.Language[Config.ChosenLanguage][s] end
    return {}
end