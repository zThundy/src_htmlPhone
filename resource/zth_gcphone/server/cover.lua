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

gcPhoneT.cover_buyCover = function(cover)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    if CACHED_COVERS[xPlayer.identifier] == nil then CACHED_COVERS[xPlayer.identifier] = {} end
    if xPlayer ~= nil then
        if xPlayer.getAccount("bank").money >= Config.Covers[cover].price then
            -- this is just a one time insert syncronus query so who cares?
            local id = MySQL.Sync.insert("INSERT INTO phone_user_covers(identifier, cover) VALUES(@identifier, @cover)", {
                ['@identifier'] = xPlayer.identifier,
                ['@cover'] = cover..".png"
            })
            if id == 0 then
                return false
            else
                if Config.Covers[cover].price ~= 0 then
                    xPlayer.removeAccountMoney("bank", Config.Covers[cover].price)
                end
                local cfg = Config.Covers[cover]
                CACHED_COVERS[xPlayer.identifier][cfg.label] = { label = cfg.label, value = cover .. ".png" }
                return true
            end
        else
            return false
        end
    end
end