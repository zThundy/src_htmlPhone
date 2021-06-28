gcPhoneT.darkweb_fetchDarkmessages = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local messages = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_darkweb_messages ORDER BY id DESC LIMIT 130", {}, function(r)
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.01 * #r)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)

            for i = #r, 1, -1 do
                i = tonumber(i)
                messages[i] = r[i]

                if tostring(identifier) == tostring(r[i].author) then
                    messages[i].mine = 1
                else
                    messages[i].mine = 0
                end
            end

            TriggerClientEvent("gcphone:darkweb_sendMessages", player, messages)
        else
            TriggerClientEvent("gcphone:sendGenericNotification", player, {
                message = "APP_DARKWEB_ENOUGH_GIGA",
                title = "APP_DARKWEB_TITLE",
                icon = "user-secret",
                color = "#606060",
                appName = "DarkWeb"
            })
        end
    end)
end

gcPhoneT.darkweb_sendDarkMessage = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
	
	local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        
        MySQL.Async.insert("INSERT INTO phone_darkweb_messages(author, message) VALUES(@author, @message)", {
            ['@author'] = player,
            ['@message'] = data.message
        })
    else
        TriggerClientEvent("gcphone:sendGenericNotification", player, {
            message = "APP_DARKWEB_ENOUGH_GIGA",
            title = "APP_DARKWEB_TITLE",
            icon = "user-secret",
            color = "#606060",
            appName = "DarkWeb"
        })
    end
end