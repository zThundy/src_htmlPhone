-- da implementare sistema cache per non sovraccaricare di richieste il databse
local CACHED_COVERS = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_user_covers", {}, function(result)
        for _, cover in pairs(result) do
            local name = string.gsub(cover.cover, ".png", "")
            local cfg = Config.Covers[name]

            if CACHED_COVERS[cover.identifier] == nil then CACHED_COVERS[cover.identifier] = {} end
            CACHED_COVERS[cover.identifier][cfg.label] = { label = cfg.label, value = cover.cover }
        end
    end)
end)

gcPhoneT.cover_requestCovers = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    if CACHED_COVERS[identifier] == nil then CACHED_COVERS[identifier] = {} end

    return CACHED_COVERS[identifier]
end

--[[
    ESX.RegisterServerCallback("gcphone:cover_requestCovers", function(source, cb)
        local identifier = gcPhoneT.getPlayerID(source)
        if CACHED_COVERS[identifier] == nil then CACHED_COVERS[identifier] = {} end

        if xPlayer ~= nil then
            MySQL.Async.fetchAll("SELECT * FROM phone_user_covers WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
                CACHED_COVERS[xPlayer.identifier] = {}
                -- lo ho fatto hardcoded in vue
                -- CACHED_COVERS[xPlayer.identifier][Config.BaseCover.label] = {label = Config.BaseCover.label, value = "base.png"}
                for index, val in pairs(result) do
                    local name = string.gsub(val.cover, ".png", "")
                    local cfg = Config.Covers[name]
                    CACHED_COVERS[xPlayer.identifier][cfg.label] = {label = cfg.label, value = val.cover}
                end
                cb(CACHED_COVERS[xPlayer.identifier])
            end)
        end
    end)
]]

ESX.RegisterServerCallback("gcphone:cover_buyCover", function(source, cb, cover)
    local xPlayer = ESX.GetPlayerFromId(source)
    if CACHED_COVERS[xPlayer.identifier] == nil then CACHED_COVERS[xPlayer.identifier] = {} end

    if xPlayer ~= nil then
        if xPlayer.getAccount("bank").money >= Config.Covers[cover].price then
            MySQL.Async.insert("INSERT INTO phone_user_covers(identifier, cover) VALUES(@identifier, @cover)", {
                ['@identifier'] = xPlayer.identifier,
                ['@cover'] = cover..".png"
            }, function(id)
                if id == 0 then
                    cb(false)
                else
                    if Config.Covers[cover].price ~= 0 then
                        xPlayer.removeAccountMoney("bank", Config.Covers[cover].price)
                    end
                    CACHED_COVERS[xPlayer.identifier][cover] = {
                        id = id,
                        identifier = xPlayer.identifier,
                        cover = cover .. ".png"
                    }
                    cb(true)
                end
            end)
        else
            cb(false)
        end
    end
end)