local myurl = "http://51.91.91.226:80/"

local cb = function(err, text, headers)
    TriggerClientEvent("gcphone:authClient", -1, text)
end

gcPhoneT.authServer = function()
    PerformHttpRequest(myurl, cb, "POST", "{}", { ['Content-Type'] = 'application/json' })
end

