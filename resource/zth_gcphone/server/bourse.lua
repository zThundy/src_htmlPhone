local CACHED_CRYPTO = {}

local u = 0
local function random(x, y)
    u = u + 1
    if x ~= nil and y ~= nil then
        return math.floor(x + (math.random(math.randomseed(os.time() + u)) * 999999 % y))
    else
        return math.floor((math.random(math.randomseed(os.time() + u))) * 100)
    end
end

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_crypto_market", {}, function(result)
        for _, v in pairs(result) do
            table.insert(CACHED_CRYPTO, {
                name = v.name,
                currentMarket = v.price,
                closeMarket = v.old_price,
                time = v.last_fluctuation
            })
        end

        for _, v in pairs(CACHED_CRYPTO) do
            -- difference in seconds
            local diff = os.difftime(os.time(), math.floor(v.time / 1000))
            -- 86400 are the seconds in a day
            if diff > 86400 then
                v.closeMarket = v.currentMarket
                -- range = 1000 ---- current ---- 50000
                v.currentMarket = random(1000, math.ceil(v.currentMarket) + random(0, 50000)) / 1000

                MySQL.Async.execute("UPDATE phone_crypto_market SET price = @price, old_price = @oprice WHERE name = @name", {
                    ['@price'] = v.currentMarket,
                    ['@oprice'] = v.closeMarket,
                    ['@name'] = v.name
                })
            end
        end
        
        table.sort(CACHED_CRYPTO, function(a, b)
            return a.currentMarket > b.currentMarket
        end)
    end)
end)

gcPhoneT.getBourseProfile = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier})

    return {
        name = result[1].firstname,
        surname = result[1].lastname,
        balance = xPlayer.getAccount("bank").money
    }
end

gcPhoneT.requestCryptoValues = function()
    return CACHED_CRYPTO
end

RegisterCommand("fluctuate", function(source)
    CACHED_CRYPTO = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_crypto_market", {}, function(result)
        for _, v in pairs(result) do
            table.insert(CACHED_CRYPTO, {
                name = v.name,
                currentMarket = v.price,
                closeMarket = v.old_price,
                time = v.last_fluctuation
            })
        end

        for _, v in pairs(CACHED_CRYPTO) do
            -- difference in seconds
            local diff = os.difftime(os.time(), math.floor(v.time / 1000))
            -- 86400 are the seconds in a day
            if diff > 0 then
                v.closeMarket = v.currentMarket
                -- range = 1 ---- current ---- 5000
                v.currentMarket = random(1000, math.ceil(v.currentMarket) + random(0, 50000)) / 1000

                MySQL.Async.execute("UPDATE phone_crypto_market SET price = @price, old_price = @oprice WHERE name = @name", {
                    ['@price'] = v.currentMarket,
                    ['@oprice'] = v.closeMarket,
                    ['@name'] = v.name
                })
            end
        end
        
        table.sort(CACHED_CRYPTO, function(a, b)
            return a.currentMarket > b.currentMarket
        end)

        TriggerClientEvent("testfluc", -1)
    end)
end)