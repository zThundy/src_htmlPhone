local CACHED_YELLOWS = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_yellow_posts", {}, function(yellows)
        CACHED_YELLOWS = yellows
    end)
end)

gcPhoneT.createYellowPost = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    data.identifier = identifier
    data.date = os.time()
    MySQL.Async.insert("INSERT INTO phone_yellow_pages(identifier, number, description) VALUES(@identifier, @number, @description)", {
        ['@identifier'] = identifier,
        ['@number'] = data.author,
        ['@description'] = data.message
    })
    table.insert(CACHED_YELLOWS, data)
    TriggerClientEvent("gcphone:yellow_receivePosts", CACHED_YELLOWS)
end

gcPhoneT.getYellowPosts = function()
    return CACHED_YELLOWS
end