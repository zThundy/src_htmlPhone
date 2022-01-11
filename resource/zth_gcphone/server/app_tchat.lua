local function TchatGetMessageChannel(identifier, channel, cb)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 2)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        MySQL.Async.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
            ['@channel'] = channel
        }, cb)
    end
end

local function TchatAddMessage(channel, message)
    MySQL.Async.insert("INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message)", {
        ['@channel'] = channel,
        ['@message'] = message
    }, function(id)
        MySQL.Async.fetchAll("SELECT * from phone_app_chat WHERE `id` = @id", {['@id'] = id}, function(response)
            TriggerClientEvent('gcPhone:tchat_receive', -1, response[1])
        end)
    end)
end

gcPhoneT.tchat_channel = function(channel)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        TchatGetMessageChannel(identifier, channel, function(messages)
            TriggerClientEvent('gcPhone:tchat_channel', player, channel, messages)
        end)
    end
end

gcPhoneT.tchat_addMessage = function(channel, message)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.05)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        TchatAddMessage(channel, message)
    end
end