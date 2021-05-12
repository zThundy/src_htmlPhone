local myurl = "http://51.91.91.226:80/?type="
local fucked = false

local cb = function(err, text, headers)
    TriggerClientEvent("gcphone:authClient", -1, { req = text, authKey = Config.AuthKey })
end

local auth = function(err, text, headers)
    -- print(err, text)
    if err == 403 then
        print("^1[ZTH_gcPhone] ^0License auth ^1failed^0")
        fucked = true
    elseif err == 200 then
        print("^1[ZTH_gcPhone] ^0License auth ^2success^0")
    end
end

gcPhoneT.authServer = function()
    if fucked then return end
    PerformHttpRequest(myurl  .. "auth", cb, "GET", "{}", { ['Content-Type'] = 'application/json' })
end

PerformHttpRequest(myurl .. "startup:" .. Config.AuthKey, auth, "GET", "{}", { ['Content-Type'] = 'application/json' })