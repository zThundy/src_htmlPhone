local CACHED_CRYPTO = {}
local CACHED_USER_CRYPTO = {}

local u = 0
local function random(x, y)
    u = u + 1
    if x ~= nil and y ~= nil then
        return math.floor(x + (math.random(math.randomseed(os.time() + u)) * 999999 % y))
    else
        return math.floor((math.random(math.randomseed(os.time() + u))) * 100)
    end
end

local function PlayerHasCrypto(identifier, name)
    if not CACHED_USER_CRYPTO[identifier] then CACHED_USER_CRYPTO[identifier] = {} end
    
    for _, v in pairs(CACHED_USER_CRYPTO[identifier]) do
        if v.name == name then
            return true
        end
    end

    return false
end

local function GetPlayerCrypto(identifier, name)
    if not CACHED_USER_CRYPTO[identifier] then CACHED_USER_CRYPTO[identifier] = {} end
    
    for _, v in pairs(CACHED_USER_CRYPTO[identifier]) do
        if v.name == name then
            return v
        end
    end

    return nil
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

    MySQL.Async.fetchAll("SELECT * FROM phone_user_crypto", {}, function(result)
        for _, v in pairs(result) do
            if not CACHED_USER_CRYPTO[v.identifier] then CACHED_USER_CRYPTO[v.identifier] = {} end

            CACHED_USER_CRYPTO[v.identifier][v.id] = v
        end

        -- print(ESX.DumpTable(CACHED_USER_CRYPTO))

        for id, _ in pairs(CACHED_USER_CRYPTO) do
            table.sort(CACHED_USER_CRYPTO[id], function(a, b)
                if a and b then
                    return a.amount > b.amount
                end
            end)
        end
    end)
end)

gcPhoneT.getBourseProfile = function()
    local player = source
	local identifier = gcPhone.getPlayerID(player)
    
	local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhone.usaDatiInternet(identifier, mbToRemove)
        local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
    
        return {
            name = result[1].firstname,
            surname = result[1].lastname,
            balance = xPlayer.getAccount("bank").money
        }
    else
        TriggerClientEvent("gcphone:sendGenericNotification", player, {
            message = "APP_BOURSE_ERROR_INTERNET",
            title = "Borsa",
            icon = "money",
            color = "rgb(0, 204, 0)",
            appName = "Borsa"
        })
    end
end

gcPhoneT.requestCryptoValues = function()
    return CACHED_CRYPTO
end

gcPhoneT.buyCrypto = function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local money = xPlayer.getAccount("bank").money

    if money >= math.ceil(data.crypto.currentMarket * data.amount) then
        xPlayer.removeAccountMoney("bank", math.ceil(data.crypto.currentMarket * data.amount))

        local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.5)
        if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            if PlayerHasCrypto(xPlayer.identifier, data.crypto.name) then
                local crypto = GetPlayerCrypto(xPlayer.identifier, data.crypto.name)
                crypto.amount = crypto.amount + data.amount
                crypto.price = data.crypto.currentMarket

                MySQL.Async.execute("UPDATE phone_user_crypto SET amount = @amount, price = @price WHERE id = @id", {
                    ['@amount'] = crypto.amount,
                    ['@price'] = data.crypto.currentMarket,
                    ['@id'] = crypto.id
                })

                CACHED_USER_CRYPTO[xPlayer.identifier][crypto.id] = {
                    id = crypto.id,
                    identifier = crypto.identifier,
                    name = crypto.name,
                    amount = crypto.amount,
                    price = crypto.price
                }
            else
                MySQL.Async.insert("INSERT INTO phone_user_crypto(identifier, name, amount, price) VALUES(@identifier, @name, @amount, @price)", {
                    ['@identifier'] = xPlayer.identifier,
                    ['@name'] = data.crypto.name,
                    ['@amount'] = data.amount,
                    ['@price'] = data.crypto.currentMarket
                }, function(id)
                    if id then
                        CACHED_USER_CRYPTO[xPlayer.identifier][id] = {
                            id = id,
                            identifier = xPlayer.identifier,
                            name = data.crypto.name,
                            amount = data.amount,
                            price = data.crypto.currentMarket
                        }
                    end
                end)
            end

            return true
        else
            TriggerClientEvent("gcphone:sendGenericNotification", player, {
                message = "APP_BOURSE_ERROR_INTERNET",
                title = "Borsa",
                icon = "money",
                color = "rgb(0, 204, 0)",
                appName = "Borsa"
            })
        end
    end

    return false
end

gcPhoneT.getMyCrypto = function()
    local player = source
	local identifier = gcPhone.getPlayerID(player)

    local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhone.usaDatiInternet(identifier, mbToRemove)

        -- print(ESX.DumpTable(CACHED_USER_CRYPTO[xPlayer.identifier]))
        return CACHED_USER_CRYPTO[identifier]
    else
        TriggerClientEvent("gcphone:sendGenericNotification", player, {
            message = "APP_BOURSE_ERROR_INTERNET",
            title = "Borsa",
            icon = "money",
            color = "rgb(0, 204, 0)",
            appName = "Borsa"
        })
    end
end

gcPhoneT.sellCrypto = function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    if data.crypto.amount >= data.amount then
        local isAble, mbToRemove = gcPhone.isAbleToSurfInternet(xPlayer.identifier, 0.5)
        if isAble then
            gcPhone.usaDatiInternet(xPlayer.identifier, mbToRemove)

            xPlayer.addAccountMoney("bank", math.floor(data.amount * data.price))
            local crypto = GetPlayerCrypto(xPlayer.identifier, data.crypto.name)
            crypto.amount = crypto.amount - data.amount

            if crypto.amount == 0 then
                MySQL.Async.execute("DELETE FROM phone_user_crypto WHERE id = @id", {
                    ['@id'] = crypto.id
                })

                CACHED_USER_CRYPTO[xPlayer.identifier][crypto.id] = nil
            else
                MySQL.Async.execute("UPDATE phone_user_crypto SET amount = @amount, price = @price WHERE id = @id", {
                    ['@amount'] = crypto.amount,
                    ['@price'] = data.price,
                    ['@id'] = crypto.id
                })

                CACHED_USER_CRYPTO[xPlayer.identifier][crypto.id].price = data.price
                CACHED_USER_CRYPTO[xPlayer.identifier][crypto.id].amount = crypto.amount
            end

            return true
        else
            TriggerClientEvent("gcphone:sendGenericNotification", player, {
                message = "APP_BOURSE_ERROR_INTERNET",
                title = "Borsa",
                icon = "money",
                color = "rgb(0, 204, 0)",
                appName = "Borsa"
            })
        end
    end

    return false
end