function TchatGetMessageChannel(identifier, channel, cb)
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
	MySQL.Async.insert("INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message)", {
		['@channel'] = channel,
		['@message'] = message
	}, function(id)
		MySQL.Async.fetchAll("SELECT * from phone_app_chat WHERE `id` = @id", {['@id'] = id}, function(reponse)
			TriggerClientEvent('gcPhone:tchat_receive', -1, reponse[1])
		end)
	end)
end


RegisterServerEvent('gcPhone:tchat_channel')
AddEventHandler('gcPhone:tchat_channel', function(channel)
	local player = source
	local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)
			
			TchatGetMessageChannel(identifier, channel, function(messages)
    			TriggerClientEvent('gcPhone:tchat_channel', player, channel, messages)
  			end)
  		end
  	end)
  	
end)

RegisterServerEvent('gcPhone:tchat_addMessage')
AddEventHandler('gcPhone:tchat_addMessage', function(channel, message)
	local player = source
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
	local player = source
	local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.05, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)

			TchatAddMessage(channel, message)
  		end
	end)
end)