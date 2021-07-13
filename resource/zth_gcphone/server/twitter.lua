local CACHED_TWEETS = {}
local CACHED_LIKES = {}
local CACHED_ACCOUNTS = {}

MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_twitter_tweets WHERE (DATEDIFF(CURRENT_DATE, time) > 20)", {})

    MySQL.Async.fetchAll("SELECT * FROM phone_twitter_tweets", {}, function(tweets)
        CACHED_TWEETS = tweets
        MySQL.Async.fetchAll("SELECT * FROM phone_twitter_accounts", {}, function(accounts)
            for _, account in pairs(accounts) do
                for _, tweet in pairs(CACHED_TWEETS) do
                    if tweet.authorId == account.id then
                        tweet.authorIcon = account.avatar_url
                        tweet.author = account.username
                    end
                end
                account.author = account.username
                account.authorIcon = account.avatar_url
                table.insert(CACHED_ACCOUNTS, account)
            end
            gcPhone.debug(Config.Language["CACHE_TWITTER_1"])
        end)
    end)

    MySQL.Async.fetchAll("SELECT * FROM phone_twitter_likes", {}, function(likes)
        for _, like in pairs(likes) do
            if not CACHED_LIKES[like.tweetId] then CACHED_LIKES[like.tweetId] = {} end
            table.insert(CACHED_LIKES[like.tweetId], like)
        end
        gcPhone.debug(Config.Language["CACHE_TWITTER_2"])
    end)
end)

local function TwitterShowError(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
        message = message,
        title = title,
        icon = "twitter",
        color = "rgb(80, 160, 230)",
        appName = "Twitter"
    })
end

local function TwitterShowSuccess(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
        message = message,
        title = title,
        icon = "twitter",
        color = "rgb(80, 160, 230)",
        appName = "Twitter"
    })
end

local function TwitterGetTweets(accountId)
    table.sort(CACHED_TWEETS, function(a, b) return a.id > b.id end)
    if not accountId then
        return CACHED_TWEETS
    else
        local tweets = {}
        local tweet = {}
        for _, info in pairs(CACHED_TWEETS) do
            if info.has_like then info.has_like = nil end
            tweet = info
            if CACHED_LIKES[tweet.id] then
                for _, like in pairs(CACHED_LIKES[tweet.id]) do
                    if like and like.authorId == accountId then
                        tweet.has_like = tweet.id
                    end
                end
            end
            table.insert(tweets, tweet)
        end
        table.sort(tweets, function(a, b) return a.id > b.id end)
        return tweets
    end
end

local function TwitterGetFavotireTweets(accountId)
    if not accountId then
        local fav_tweets = DuplicateTable(CACHED_TWEETS)
        if not fav_tweets then fav_tweets = {} end
        table.sort(fav_tweets, function(a, b) return a.likes > b.likes end)
        return fav_tweets
    else
        local fav_tweets = {}
        local tweet = {}
        for _, info in pairs(CACHED_TWEETS) do
            if info.has_like then info.has_like = nil end
            tweet = info
            if CACHED_LIKES[tweet.id] then
                for _, like in pairs(CACHED_LIKES[tweet.id]) do
                    if like and like.authorId == accountId then
                        tweet.has_like = tweet.id
                    end
                end
            end
            table.insert(fav_tweets, tweet)
        end
        table.sort(fav_tweets, function(a, b) return a.likes > b.likes end)
        return fav_tweets
    end
end

local function GetTwiterUserAccount(username, password)
    for _, account in pairs(CACHED_ACCOUNTS) do
        if account.username == username and account.password == password then
            return account
        end
    end
    return false
end

local function TwitterPostTweet(username, password, message, player, realUser)
    local identifier = gcPhoneT.getPlayerID(player)
    if not message then
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_MESSAGE_NEEDED')
        return
    end
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetTwiterUserAccount(username, password)
        if user == nil then
            if player ~= nil then
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
            end
            return
        end
        if user == false then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
            return
        end
        MySQL.Async.insert("INSERT INTO phone_twitter_tweets (`authorId`, `message`, `realUser`) VALUES(@authorId, @message, @realUser);", {
            ['@authorId'] = user.id,
            ['@message'] = message,
            ['@realUser'] = realUser
        }, function (id)
            local tweet = {
                likes = 0,
                realUser = realUser,
                message = message,
                id = id,
                authorIcon = user.authorIcon,
                author = user.author,
                time = os.time() * 1000,
                authorId = user.id
            }
            table.insert(CACHED_TWEETS, tweet)
            TriggerClientEvent('gcPhone:twitter_newTweets', -1, tweet)
        end)
    else
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
    end
end

local function HasLikedTweet(authorId, tweetId)
    if CACHED_LIKES[tweetId] then
        for _, like in pairs(CACHED_LIKES[tweetId]) do
            if like.authorId == authorId then
                return true
            end
        end
    end
    return false
end

local function TwitterToogleLike(username, password, tweetId, player)
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.02)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetTwiterUserAccount(username, password)
        if user == nil then
            if player ~= nil then
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
            end
            return
        end
        if user == false then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
            return
        end
        for _, tweet in pairs(CACHED_TWEETS) do
            if tweet.id == tweetId then
                if HasLikedTweet(user.id, tweetId) then
                    for id, like in pairs(CACHED_LIKES[tweetId]) do
                        if user.id == like.authorId and tweetId == like.tweetId then
                            MySQL.Async.execute('DELETE FROM phone_twitter_likes WHERE id = @id', {
                                ['@id'] = like.id,
                            }, function()
                                CACHED_LIKES[tweetId][id] = nil
                                if #CACHED_LIKES[tweetId] == 0 then CACHED_LIKES[tweetId] = nil end
                                tweet.likes = tweet.likes - 1
                                MySQL.Async.execute('UPDATE `phone_twitter_tweets` SET `likes` = likes - 1 WHERE id = @id', {
                                    ['@id'] = tweet.id
                                }, function()
                                    TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes)
                                    TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, false)
                                end)
                            end)
                            return
                        end
                    end
                else
                    if CACHED_LIKES[tweetId] == nil then CACHED_LIKES[tweetId] = {} end
                    MySQL.Async.insert('INSERT INTO phone_twitter_likes(`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
                        ['authorId'] = user.id,
                        ['tweetId'] = tweetId
                    }, function(id)
                        table.insert(CACHED_LIKES[tweetId], {
                            id = id,
                            authorId = user.id,
                            tweetId = tweetId
                        })
                        tweet.likes = tweet.likes + 1
                        MySQL.Async.execute('UPDATE `phone_twitter_tweets` SET `likes` = likes + 1 WHERE id = @id', {
                            ['@id'] = tweet.id
                        }, function()
                            TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes)
                            TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, true)
                        end)    
                    end)
                end
            end
        end
    else
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
    end
end

local function TwitterCreateAccount(username, password, avatarUrl, cb)
    MySQL.Async.insert('INSERT IGNORE INTO phone_twitter_accounts (`username`, `password`, `avatar_url`) VALUES(@username, @password, @avatarUrl)', {
        ['username'] = username,
        ['password'] = password,
        ['avatarUrl'] = avatarUrl
    }, cb)
end

gcPhoneT.twitter_login = function(username, password)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetTwiterUserAccount(username, password)
        if user == false then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
            return
        end
        if user == nil then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
        else
            TwitterShowSuccess(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_SUCCESS')
            TriggerClientEvent('gcPhone:twitter_setAccount', player, username, password, user.authorIcon)
        end
    else
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.twitter_changePassword = function(username, password, newPassword)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetTwiterUserAccount(username, password)
        if user == false then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
            return
        end
        if user == nil then
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_ERROR')
        else
            MySQL.Async.execute("UPDATE `phone_twitter_accounts` SET `password`= @newPassword WHERE phone_twitter_accounts.username = @username AND phone_twitter_accounts.password = @password", {
                ['@username'] = username,
                ['@password'] = password,
                ['@newPassword'] = newPassword
            }, function (result)
                if result == 1 then
                    for _, account in pairs(CACHED_ACCOUNTS) do
                        if account.username == username and account.password == password then
                            account.password = newPassword
                            break
                        end
                    end
                    TriggerClientEvent('gcPhone:twitter_setAccount', player, username, newPassword, user.authorIcon)
                    TwitterShowSuccess(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_SUCCESS')
                else
                    TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_ERROR')
                end
            end)
        end
    else
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.twitter_createAccount = function(username, password, avatarUrl)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        TwitterCreateAccount(username, password, avatarUrl, function(id)
            if id ~= 0 then
                table.insert(CACHED_ACCOUNTS, {
                    username = username,
                    password = password,
                    avatar_url = avatarUrl,
                    author = username,
                    authorIcon = avatarUrl,
                    id = id
                })
                TriggerClientEvent('gcPhone:twitter_setAccount', player, username, password, avatarUrl)
                TwitterShowSuccess(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_ACCOUNT_CREATE_SUCCESS')
            else
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_ACCOUNT_CREATE_ERROR')
            end
        end)
    else
        TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.twitter_getTweets = function(username, password)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            local user = GetTwiterUserAccount(username, password)
            if user == false then
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
                return
            end
            local accountId = user and user.id
            local tweets = TwitterGetTweets(accountId)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent('gcPhone:twitter_getTweets', player, tweets)
            else
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
            end
        else
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
        end
    else
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            local tweets = TwitterGetTweets(false)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent('gcPhone:twitter_getTweets', player, tweets)
            else
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
            end
        else
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
        end
    end
end

gcPhoneT.twitter_getFavoriteTweets = function(username, password)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            local user = GetTwiterUserAccount(username, password)
            if user == false then
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
                return
            end

            local accountId = user and user.id
            local tweets = TwitterGetFavotireTweets(accountId)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', player, tweets)
            else
                TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
            end
        else
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
        end
    else
        local tweets = TwitterGetFavotireTweets(false)
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', player, tweets)
        else
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
        end
    end
end

gcPhoneT.twitter_postTweets = function(username, password, message)
    local player = source
    local srcIdentifier = gcPhoneT.getPlayerID(player)
    TwitterPostTweet(username, password, message, player, srcIdentifier)
end

gcPhoneT.twitter_postImmagine = function(username, password, message)
    local player = source
    local srcIdentifier = gcPhoneT.getPlayerID(player)
    TwitterPostTweet(username, password, message, player, srcIdentifier)
end

gcPhoneT.twitter_toogleLikeTweet = function(username, password, tweetId)
    local player = source
    TwitterToogleLike(username, password, tweetId, player)
end

gcPhoneT.twitter_setAvatarUrl = function(username, password, avatarUrl)
    local player = source
    MySQL.Async.execute("UPDATE `phone_twitter_accounts` SET `avatar_url`= @avatarUrl WHERE phone_twitter_accounts.username = @username AND phone_twitter_accounts.password = @password", {
        ['@username'] = username,
        ['@password'] = password,
        ['@avatarUrl'] = avatarUrl
    }, function (result)
        if result == 1 then
            for _, account in pairs(CACHED_ACCOUNTS) do
                if account.username == username and account.password == password then
                    account.avatar_url = avatarUrl
                    account.authorIcon = avatarUrl
                    break
                end
            end
            TriggerClientEvent('gcPhone:twitter_setAccount', player, username, password, avatarUrl)
            TwitterShowSuccess(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_AVATAR_SUCCESS')
        else
            TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
        end
    end)
end