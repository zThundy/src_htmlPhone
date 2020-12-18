-- da implementare sistema cache per non sovraccaricare di richieste il databse
local covers = {}

ESX.RegisterServerCallback("gcphone:cover_requestCovers", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if covers[xPlayer.identifier] == nil then covers[xPlayer.identifier] = {} end

    if xPlayer ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM phone_user_covers WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
            covers[xPlayer.identifier] = {}

            -- lo ho fatto hardcoded in vue
            -- covers[xPlayer.identifier][Config.BaseCover.label] = {label = Config.BaseCover.label, value = "base.png"}
            for index, val in pairs(result) do
                local name = string.gsub(val.cover, ".png", "")
                local cfg = Config.Covers[name]

                covers[xPlayer.identifier][cfg.label] = {label = cfg.label, value = val.cover}
            end

            cb(covers[xPlayer.identifier])
        end)
    end
end)


ESX.RegisterServerCallback("gcphone:cover_buyCover", function(source, cb, cover)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then
        local points = exports["vip_points"]:getPoints(source)

        if points >= Config.Covers[cover].price then

            MySQL.Async.insert("INSERT INTO phone_user_covers(identifier, cover) VALUES(@identifier, @cover)", {
                ['@identifier'] = xPlayer.identifier,
                ['@cover'] = cover..".png"
            }, function(id)
                if id == 0 then
                    cb(false)
                else
                    exports["vip_points"]:removePoints(source, Config.Covers[cover].price)
                    cb(true)
                end
            end)
        else
            cb(false)
        end
    end
end)