function TchatGetMessageChannel (channel, cb)

	gcPhone.isAbleToSurfInternet(identifier, 2, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)

    		MySQL.Async.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
        		['@channel'] = channel
			}, cb)
    	end
    end)
end

function TchatAddMessage(channel, message)
	local Query = "INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message);"
	local Query2 = 'SELECT * from phone_app_chat WHERE `id` = @id;'
	local Parameters = {
		['@channel'] = channel,
		['@message'] = message
	}
	
	MySQL.Async.insert(Query, Parameters, function(id)
		MySQL.Async.fetchAll(Query2, { ['@id'] = id }, function(reponse)
			TriggerClientEvent('gcPhone:tchat_receive', -1, reponse[1])
		end)
	end)
end


RegisterServerEvent('gcPhone:tchat_channel')
AddEventHandler('gcPhone:tchat_channel', function(channel)
	local player = tonumber(source)
	local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)
			
			TchatGetMessageChannel(channel, function (messages)
    			TriggerClientEvent('gcPhone:tchat_channel', player, channel, messages)
  			end)
  		end
  	end)
  	
end)

RegisterServerEvent('gcPhone:tchat_addMessage')
AddEventHandler('gcPhone:tchat_addMessage', function(channel, message)
	local player = tonumber(source)
	local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.05, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)

			TchatAddMessage(channel, message)
  		end
	end)
end)

RegisterServerEvent('gcPhone:custom_tchat_addMessage')
AddEventHandler('gcPhone:custom_tchat_addMessage', function(channel, message)
	TchatAddMessage(channel, message)
end)