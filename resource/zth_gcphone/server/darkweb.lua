RegisterServerEvent("gcphone:darkweb_fetchDarkmessages")
AddEventHandler("gcphone:darkweb_fetchDarkmessages", function()
    print("hieloooo server")
    
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    local messages = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_darkweb_messages ORDER BY id ASC LIMIT 130", {}, function(r)
        gcPhone.isAbleToSurfInternet(identifier, 0.01 * #r, function(isAble, mbToRemove)
            if isAble then
                gcPhone.usaDatiInternet(identifier, mbToRemove)

                for _, v in pairs(r) do
                    v.id = tonumber(v.id)

                    messages[v.id] = v

                    if tostring(identifier) == tostring(v.author) then
                        messages[v.id].mine = 1
                    else
                        messages[v.id].mine = 0
                    end
                end

                TriggerClientEvent("gcphone:darkweb_sendMessages", player, messages)
            else
                TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter inviare un messaggio o non c'è linea")
            end
        end)
    end)
end)


RegisterServerEvent("gcphone:darkweb_sendDarkMessage")
AddEventHandler("gcphone:darkweb_sendDarkMessage", function(data)
    local player = source
    local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)
            
            MySQL.Async.insert("INSERT INTO phone_darkweb_messages(author, message) VALUES(@author, @message)", {
                ['@author'] = identifier,
                ['@message'] = data.message
            })
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter inviare un messaggio o non c'è linea")
        end
    end)
end)