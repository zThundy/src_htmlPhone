local CACHED_POSTS = {}
local CACHED_LIKES = {}
local CACHED_ACCOUNTS = {}

MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_instagram_posts WHERE (DATEDIFF(CURRENT_DATE, data) > 20)", {})

    MySQL.Async.fetchAll("SELECT * FROM phone_instagram_posts", {}, function(posts)
        CACHED_POSTS = posts
        MySQL.Async.fetchAll("SELECT * FROM phone_instagram_accounts", {}, function(accounts)
            for _, account in pairs(accounts) do
                for _, post in pairs(CACHED_POSTS) do
                    post.authorId = tostring(post.authorId)
                    account.id = tostring(account.id)
                    if post.authorId == account.id then
                        post.authorIcon = account.avatar_url
                        post.author = account.username
                    end
                end
                account.author = account.username
                account.authorIcon = account.avatar_url
                table.insert(CACHED_ACCOUNTS, account)
            end
            gcPhone.debug(Config.Language["CACHE_INSTAGRAM_1"])
        end)
    end)

    MySQL.Async.fetchAll("SELECT * FROM phone_instagram_likes", {}, function(likes)
        for _, like in pairs(likes) do
            if not CACHED_LIKES[like.postId] then CACHED_LIKES[like.postId] = {} end
            table.insert(CACHED_LIKES[like.postId], like)
        end
        gcPhone.debug(Config.Language["CACHE_INSTAGRAM_2"])
    end)
end)

local function InstagramShowError(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
        message = message,
        title = title,
        icon = "instagram",
        color = "rgb(255, 204, 0)",
        appName = "Instagram",
        sound = "Instagram_Error.ogg"
    })
end

local function InstagramShowSuccess(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
        message = message,
        title = title,
        icon = "instagram",
        color = "rgb(255, 204, 0)",
        appName = "Instagram",
        sound = "Instagram_Notification.ogg"
    })
end

local function InstagramGetPosts(accountId)
    table.sort(CACHED_POSTS, function(a, b) return a.id > b.id end)
    if not accountId then
        return CACHED_POSTS
    else
        local posts = {}
        local post = {}
        for _, info in pairs(CACHED_POSTS) do
            if info.has_like then info.has_like = nil end
            post = info
            if CACHED_LIKES[post.id] then
                for _, like in pairs(CACHED_LIKES[post.id]) do
                    if like and like.authorId == accountId then
                        post.has_like = post.id
                    end
                end
            end
            table.insert(posts, post)
        end
        table.sort(posts, function(a, b) return a.id > b.id end)
        return posts
    end
end


local function GetInstagramUser(username, password)
    for _, account in pairs(CACHED_ACCOUNTS) do
        if account.username == username and account.password == password then
            return account
        end
    end
    return false
end

local function InstagramCreateAccount(username, password, avatarUrl, cb)
    MySQL.Async.insert('INSERT IGNORE INTO phone_instagram_accounts(`username`, `password`) VALUES(@username, @password)', {
        ['@username'] = username,
        ['@password'] = password
    }, cb)
end

local function HasLikedPost(authorId, postId)
    if CACHED_LIKES[postId] then
        for _, like in pairs(CACHED_LIKES[postId]) do
            if like.authorId == authorId then
                return true
            end
        end
    end
    return false
end

gcPhoneT.instagram_nuovoPost = function(username, password, data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetInstagramUser(username, password)
        if not user then
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NO_ACCOUNT')
            return
        end
        MySQL.Async.insert("INSERT INTO phone_instagram_posts(`authorId`, `image`, `identifier`, `filter`, `didascalia`) VALUES(@authorId, @message, @identifier, @filter, @didascalia)", {
            ['@authorId'] = user.id,
            ['@message'] = data.message,
            ['@identifier'] = identifier,
            ['@filter'] = data.filter,
            ['@didascalia'] = data.didascalia
        }, function(id)
            local posts = InstagramGetPosts(nil)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #posts)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                local post = {
                    id = id,
                    identifier = identifier,
                    authorId = data.id,
                    author = user.username,
                    authorIcon = user.authorIcon,
                    image = data.message,
                    didascalia = data.didascalia,
                    filter = data.filter,
                    likes = 0,
                    data = os.time() * 1000
                }
                table.insert(CACHED_POSTS, 1, post)
                TriggerClientEvent('gcPhone:instagram_updatePosts', player, CACHED_POSTS)
            else
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
            end
        end)
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.instagram_getPosts = function(username, password)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            -- funzione che controlla se l'utente esista effettivamente
            local user = GetInstagramUser(username, password)
            if not user then
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NO_ACCOUNT')
                return
            end
            -- questa funzione ti ritorna la table già bella
            -- buildata da mandare a nui
            local accountId = user and user.id
            local posts = InstagramGetPosts(accountId)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #posts)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent('gcPhone:instagram_updatePosts', player, posts)
            else
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
            end
        else
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
        end
    else
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            local posts = InstagramGetPosts(nil)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #posts)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent('gcPhone:instagram_updatePosts', player, posts)
            else
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
            end
        else
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
        end
    end
end

gcPhoneT.instagram_createAccount = function(username, password, avatarUrl)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        InstagramCreateAccount(username, password, avatarUrl, function(id)
            if id ~= 0 then
                table.insert(CACHED_ACCOUNTS, {
                    username = username,
                    password = password,
                    avatar_url = avatarUrl,
                    author = username,
                    authorIcon = avatarUrl,
                    id = id
                })
                TriggerClientEvent('gcPhone:instagram_setAccount', player, username, password, avatarUrl)
                InstagramShowSuccess(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_ACCOUNT_CREATED')
            else
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_ACCOUNT_CREATE_ERROR')
            end
        end)
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.instagram_loginAccount = function(username, password)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetInstagramUser(username, password)
        if not user then
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NO_ACCOUNT')
            return
        end
        -- if user == nil then
        --     InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_LOGIN_ERROR')
        -- else
        InstagramShowSuccess(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_LOGIN_SUCCESS')
        TriggerClientEvent('gcPhone:instagram_setAccount', player, username, password, user.avatar_url)
        -- end
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.instagram_changePassword = function(username, password, newPassword)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetInstagramUser(username, password)
        if not user then
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NO_ACCOUNT')
            return
        end
        -- if user == nil then
        --     InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_LOGIN_ERROR')
        -- else
        MySQL.Async.execute("UPDATE phone_instagram_accounts SET password = @newpassword WHERE username = @username AND password = @password", {
            ['@username'] = username,
            ['@password'] = password, 
            ['@newpassword'] = newPassword
        }, function()
            for _, account in pairs(CACHED_ACCOUNTS) do
                if account.username == username and account.password == password then
                    account.password = newPassword
                    break
                end
            end
            InstagramShowSuccess(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_PASSCHANGE_SUCCESS')
        end)
        -- end
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.instagram_toggleLikePost = function(username, password, postId)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.02)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local user = GetInstagramUser(username, password)
        if not user then
            InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_LOGIN_ERROR')
            return
        end
        -- if user == false then
        --     InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NO_ACCOUNT')
        --     return
        -- end
        ---------------------------------------------
        for _, info in pairs(CACHED_POSTS) do
            if tonumber(info.id) == tonumber(postId) then
                if HasLikedPost(user.id, postId) then
                    for id, like in pairs(CACHED_LIKES[postId]) do
                        if user.id == like.authorId and postId == like.postId then
                            MySQL.Async.execute('DELETE FROM phone_instagram_likes WHERE id = @id', { ['@id'] = like.id, }, function()
                                CACHED_LIKES[postId][id] = nil
                                if #CACHED_LIKES[postId] == 0 then CACHED_LIKES[postId] = nil end
                                info.likes = info.likes - 1
                                MySQL.Async.execute('UPDATE `phone_instagram_posts` SET `likes` = likes - 1 WHERE id = @id', { ['@id'] = info.id }, function()
                                    -- questo evento aggiorna i like per tutti i giocatori
                                    TriggerClientEvent('gcPhone:instagram_updatePostLikes', -1, info.id, info.likes)
                                    -- questo evento aggiorna il colore del cuore per chi lo mette
                                    TriggerClientEvent('gcPhone:instagram_updateLikeForUser', player, info.id, false)
                                end)
                            end)
                            return
                        end
                    end
                else
                    if CACHED_LIKES[postId] == nil then CACHED_LIKES[postId] = {} end
                    MySQL.Async.insert('INSERT INTO phone_instagram_likes(`authorId`, `postId`) VALUES(@authorId, @postId)', {
                        ['@authorId'] = user.id,
                        ['@postId'] = postId
                    }, function(id)
                        table.insert(CACHED_LIKES[postId], {
                            id = id,
                            authorId = user.id,
                            postId = postId
                        })
                        info.likes = info.likes + 1
                        MySQL.Async.execute('UPDATE `phone_instagram_posts` SET `likes` = likes + 1 WHERE id = @id', { ['@id'] = info.id }, function()
                            -- questo evento aggiorna i like per tutti i giocatori
                            TriggerClientEvent('gcPhone:instagram_updatePostLikes', -1, info.id, info.likes)
                            -- questo evento aggiorna il colore del cuore per chi lo mette
                            TriggerClientEvent('gcPhone:instagram_updateLikeForUser', player, info.id, true)
                        end)    
                    end)
                end
            end
        end
        -- if post == nil then
        --     InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_POST_NOT_FOUND')
        --     return
        -- end
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end

gcPhoneT.instagram_setAvatarurl = function(username, password, avatarUrl)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        -- local user = GetInstagramUser(username, password)
        MySQL.Async.execute("UPDATE phone_instagram_accounts SET avatar_url = @avatarUrl WHERE username = @username AND password = @password", {
            ['@username'] = username,
            ['@password'] = password,
            ['@avatarUrl'] = avatarUrl
        }, function(result)
            if result == 1 then
                for _, account in pairs(CACHED_ACCOUNTS) do
                    if account.username == username and account.password == password then
                        account.avatar_url = avatarUrl
                        account.authorIcon = avatarUrl
                        break
                    end
                end
                TriggerClientEvent('gcPhone:instagram_setAccount', player, username, password, avatarUrl)
                InstagramShowSuccess(player, 'Instagram Info', 'APP_INSTAGRAM_NOTIF_AVATAR_SUCCESS')
            else
                InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_LOGIN_ERROR')
            end
        end)
    else
        InstagramShowError(player, 'INSTAGRAM_INFO_TITLE', 'APP_INSTAGRAM_NOTIF_NO_CONNECTION')
    end
end