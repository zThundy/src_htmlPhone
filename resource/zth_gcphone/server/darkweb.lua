gcPhoneT.darkweb_fetchDarkmessages = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local messages = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_darkweb_messages ORDER BY id DESC LIMIT 130", {}, function(r)
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.01 * #r)
        if isAble then
            gcPhoneT.usaDatiInternet(identifier, mbToRemove)

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
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter inviare un messaggio o non c'è linea")
        end
    end)
end

gcPhoneT.darkweb_sendDarkMessage = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
	
	local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.usaDatiInternet(identifier, mbToRemove)
        
        MySQL.Async.insert("INSERT INTO phone_darkweb_messages(author, message) VALUES(@author, @message)", {
            ['@author'] = identifier,
            ['@message'] = data.message
        })
    else
        TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter inviare un messaggio o non c'è linea")
    end
end