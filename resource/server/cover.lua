ESX.RegisterServerCallback("gcphone:cover_requestCovers", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM phone_user_covers WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
            local covers = {}

            for index, val in pairs(result) do
                table.insert(covers[val.cover], val.identifier)
            end

            cb(covers)
        end)
    end
end)

ESX.RegisterServerCallback("gcphone:cover_buyCover", function(source, cb, cover)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then
        local money = xPlayer.getAccount("bank").money

        if money >= Config.Covers[cover] then
            MySQL.Async.insert("INSERT INTO phone_user_covers(identifier, cover) VALUES(@identifier, @cover)", {
                ['@identifier'] = xPlayer.identifier,
                ['@cover'] = cover
            }, function(id)
                if id == 0 then cb(false) else cb(true) end
            end)
        end
    end
end)