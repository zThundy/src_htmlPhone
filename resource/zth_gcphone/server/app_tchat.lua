function TchatGetMessageChannel(identifier, channel, cb)
	local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(identifier, 2)
	if isAble then
		gcPhone.usaDatiInternet(identifier, mbToRemove)

		MySQL.Sync.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
			['@channel'] = channel
		}, cb)
	end
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

gcPhoneT.tchat_channel = function(channel)
	local identifier = gcPhone.getPlayerID(source)
	
	local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(identifier, 0.5)
	if isAble then
		gcPhone.usaDatiInternet(identifier, mbToRemove)
		
		TchatGetMessageChannel(identifier, channel, function(messages)
			TriggerClientEvent('gcPhone:tchat_channel', source, channel, messages)
		end)
	end
end

gcPhoneT.tchat_addMessage = function(channel, message)
	local identifier = gcPhone.getPlayerID(source)
	
	local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(identifier, 0.05)
	if isAble then
		gcPhone.usaDatiInternet(identifier, mbToRemove)

		TchatAddMessage(channel, message)
	end
end