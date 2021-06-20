local CACHED_TWEETS = {}
local CACHED_LIKES = {}
local CACHED_ACCOUNTS = {}

MySQL.ready(function()
    MySQL.Async.execute("DELETE FROM phone_twitter_tweets WHERE (DATEDIFF(CURRENT_DATE, time) > 20)", {})

	MySQL.Async.fetchAll("SELECT * FROM phone_twitter_tweets", {}, function(tweets)
		--[[
			likes,			ok
			realUser,		ok
			message,		ok
			id,				ok
			authorIcon,
			author,
			time,			ok
			authorId		ok
		]]
		
		--[[
			id,
			authorId,
			realUser,
			message,
			time,
			likes,
		]]
		-- for _, tweet in pairs(tweets) do
		-- 	table.insert(CACHED_TWEETS, tweet)
		-- end
		CACHED_TWEETS = tweets

		MySQL.Async.fetchAll("SELECT * FROM phone_twitter_accounts", {}, function(accounts)
			for _, account in pairs(accounts) do
				for _, tweet in pairs(CACHED_TWEETS) do
					if tweet.authorId == account.id then
						tweet.authorIcon = account.avatar_url
						tweet.author = account.username
					end
				end
			end

			gcPhone.debug("Twitter messages cache loaded")
		end)
	end)

	MySQL.Async.fetchAll("SELECT * FROM phone_twitter_likes", {}, function(likes)
		for _, like in pairs(likes) do
			if not CACHED_LIKES[like.tweetId] then CACHED_LIKES[like.tweetId] = {} end
			table.insert(CACHED_LIKES[like.tweetId], like)
		end
		
		gcPhone.debug("Twitter likes cache loaded")
	end)

	MySQL.Async.fetchAll("SELECT * FROM phone_twitter_accounts", {}, function(accounts)
		for _, account in pairs(accounts) do
			account.author = account.username
			account.authorIcon = account.avatar_url
			table.insert(CACHED_ACCOUNTS, account)
		end
	end)
end)

local function TwitterShowError(player, title, message)
	--[[
		Vue.notify({
			message: store.getters.LangString(data.message),
			title: store.getters.LangString(data.title) + ':',
			icon: data.icon,
			backgroundColor: data.color,
			appName: data.appName
		})
	]]
	TriggerClientEvent("gcphone:sendGenericNotification", player, {
		message = message,
		title = title,
		icon = "twitter",
		color = "rgb(80, 160, 230)",
		appName = "Twitter"
	})
	-- TriggerClientEvent('gcPhone:twitter_showError', player, title, message)
end

local function TwitterShowSuccess(player, title, message)
	TriggerClientEvent("gcphone:sendGenericNotification", player, {
		message = message,
		title = title,
		icon = "twitter",
		color = "rgb(80, 160, 230)",
		appName = "Twitter"
	})
	-- TriggerClientEvent('gcPhone:twitter_showSuccess', player, title, message)
end

local function TwitterGetTweets(accountId)
	table.sort(CACHED_TWEETS, function(a, b) return a.id > b.id end)
	if not accountId then
		-- MySQL.Async.fetchAll([===[
		-- 	SELECT phone_twitter_tweets.*,
		-- 		phone_twitter_accounts.username as author,
		-- 		phone_twitter_accounts.avatar_url as authorIcon
		-- 	FROM phone_twitter_tweets
		-- 		LEFT JOIN phone_twitter_accounts
		-- 		ON phone_twitter_tweets.authorId = phone_twitter_accounts.id
		-- 	ORDER BY id DESC LIMIT 130
		-- ]===], {}, cb)
		return CACHED_TWEETS
	else
		local tweets = {}
		local tweet = {}
		for _, info in pairs(CACHED_TWEETS) do
			-- tweet = DuplicateTable(info)
			if info.has_like then info.has_like = nil end
			tweet = info
			-- print("info.id")
			-- print(info.id)
			-- print("json.encode(CACHED_LIKES[info.id]), accountId")
			-- print(json.encode(CACHED_LIKES[info.id]), accountId)
			if CACHED_LIKES[tweet.id] then
				for _, like in pairs(CACHED_LIKES[tweet.id]) do
					if like and like.authorId == accountId then
						-- print(like.authorId, accountId, tweet.message)
						-- print("adding has_like to id", tweet.id, tweet.message)
						-- print("CACHED_LIKES[info.id].authorId, accountId")
						-- print(CACHED_LIKES[info.id].authorId, accountId)
						tweet.has_like = tweet.id
					-- else
					-- 	print("removing has_like", tweet.message)
					-- 	if tweet.has_like then tweet.has_like = nil end
					end
				end
			end
			table.insert(tweets, tweet)
		end
		table.sort(tweets, function(a, b) return a.id > b.id end)
		-- print(DumpTable(tweets))
		-- print("------------------------------")
		-- print(DumpTable(CACHED_TWEETS))
		-- MySQL.Async.fetchAll([===[
		-- 	SELECT phone_twitter_tweets.*,
		-- 		phone_twitter_accounts.username as author,
		-- 		phone_twitter_accounts.avatar_url as authorIcon,
		-- 		phone_twitter_likes.id AS has_like
		-- 	FROM phone_twitter_tweets
		-- 		LEFT JOIN phone_twitter_accounts
		-- 		ON phone_twitter_tweets.authorId = phone_twitter_accounts.id
		-- 		LEFT JOIN phone_twitter_likes 
		-- 		ON phone_twitter_tweets.id = phone_twitter_likes.tweetId AND phone_twitter_likes.authorId = @accountId
		-- 	ORDER BY id DESC LIMIT 130
		-- ]===], { ['@accountId'] = accountId }, function(r)
		-- 	print(DumpTable(r))
		-- end)
		return tweets
	end
end

local function TwitterGetFavotireTweets(accountId)
	if not accountId then
		-- MySQL.Async.fetchAll([===[
		-- 	SELECT phone_twitter_tweets.*,
		-- 		phone_twitter_accounts.username as author,
		-- 		phone_twitter_accounts.avatar_url as authorIcon
		-- 	FROM phone_twitter_tweets
		-- 		LEFT JOIN phone_twitter_accounts
		-- 		ON phone_twitter_tweets.authorId = phone_twitter_accounts.id
		-- 	WHERE phone_twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
		-- 	ORDER BY likes DESC, TIME DESC LIMIT 30
		-- ]===], {}, cb)
		local fav_tweets = DuplicateTable(CACHED_TWEETS)
		if not fav_tweets then fav_tweets = {} end
		table.sort(fav_tweets, function(a, b) return a.likes > b.likes end)
		return fav_tweets
	else
		local fav_tweets = {}
		local tweet = {}
		for _, info in pairs(CACHED_TWEETS) do
			if info.has_like then info.has_like = nil end
			-- tweet = DuplicateTable(info)
			tweet = info
			-- print("info.id")
			-- print(info.id)
			-- print("json.encode(CACHED_LIKES[info.id]), accountId")
			-- print(json.encode(CACHED_LIKES[info.id]), accountId)
			if CACHED_LIKES[tweet.id] then
				for _, like in pairs(CACHED_LIKES[tweet.id]) do
					if like and like.authorId == accountId then
						-- print("adding has_like to id", tweet.id, tweet.message)
						-- print("CACHED_LIKES[info.id].authorId, accountId")
						-- print(CACHED_LIKES[info.id].authorId, accountId)
						tweet.has_like = tweet.id
					-- else
					-- 	if tweet.has_like then tweet.has_like = nil end
					end
				end
			end
			table.insert(fav_tweets, tweet)
		end
		table.sort(fav_tweets, function(a, b) return a.likes > b.likes end)
		return fav_tweets
		-- MySQL.Async.fetchAll([===[
		-- 	SELECT phone_twitter_tweets.*,
		-- 		phone_twitter_accounts.username as author,
		-- 		phone_twitter_accounts.avatar_url as authorIcon,
		-- 		phone_twitter_likes.id AS has_like
		-- 	FROM phone_twitter_tweets
		-- 		LEFT JOIN phone_twitter_accounts
		-- 		ON phone_twitter_tweets.authorId = phone_twitter_accounts.id
		-- 		LEFT JOIN phone_twitter_likes 
		-- 		ON phone_twitter_tweets.id = phone_twitter_likes.tweetId AND phone_twitter_likes.authorId = @accountId
		-- 	WHERE phone_twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
		-- 	ORDER BY likes DESC, TIME DESC LIMIT 30
		-- ]===], { ['@accountId'] = accountId }, cb)
	end
end

local function getTwiterUserAccount(username, password)
	for _, account in pairs(CACHED_ACCOUNTS) do
		if account.username == username and account.password == password then
			return account
		end
	end
	return false
	-- MySQL.Async.fetchAll("SELECT id, username as author, avatar_url as authorIcon FROM phone_twitter_accounts WHERE phone_twitter_accounts.username = @username AND phone_twitter_accounts.password = @password", {
	-- 	['@username'] = username,
	-- 	['@password'] = password
	-- }, function (data)
	-- 	if #data > 0 then
	-- 		cb(data[1])
	-- 	else
	-- 		cb(false)
	-- 	end
	-- end)
end

local function TwitterPostTweet(username, password, message, player, realUser)
	local identifier = gcPhoneT.getPlayerID(player)

	if not message then
		TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_MESSAGE_NEEDED')
		return
	end

	local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
	if isAble then
		gcPhoneT.usaDatiInternet(identifier, mbToRemove)

		local user = getTwiterUserAccount(username, password)
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
			-- MySQL.Async.fetchAll('SELECT * from phone_twitter_tweets WHERE id = @id', {
			-- 	['@id'] = id
			-- }, function (tweets)
				--[[
					likes,			ok
					realUser,		ok
					message,		ok
					id,				ok
					authorIcon,
					author,
					time,			ok
					authorId		ok
				]]
				
				table.insert(CACHED_TWEETS, {
					likes = 0,
					realUser = realUser,
					message = message,
					id = id,
					authorIcon = user.authorIcon,
					author = user.author,
					time = os.time() * 1000,
					authorId = user.id
				})
				TriggerClientEvent('gcPhone:twitter_newTweets', -1, CACHED_TWEETS)
				-- tweet = tweets[1]
				-- if tweet then
				-- 	tweet['author'] = user.author
				-- 	tweet['authorIcon'] = user.authorIcon
				-- 	TriggerClientEvent('gcPhone:twitter_newTweets', -1, tweet)
				-- end
			-- end)
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
		gcPhoneT.usaDatiInternet(identifier, mbToRemove)
			
		local user = getTwiterUserAccount(username, password)
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

				-- if the like exists, i update id in cache and in the database
				-- adding one entry to the general cache
				-- local like = CACHED_LIKES[tweetId]
				-- if not like then
				-- 	CACHED_LIKES[tweetId] = {}
				-- 	like = {}
				-- 	gcPhone.debug(("Like from the tweetId %s is not cached. This should not be happening. Maybe error?"):format(tweetId))
				-- 	return
				-- end
				
				if HasLikedTweet(user.id, tweetId) then
				-- if CACHED_LIKES[tweetId] then
					for id, like in pairs(CACHED_LIKES[tweetId]) do
						if user.id == like.authorId and tweetId == like.tweetId then
							MySQL.Async.execute('DELETE FROM phone_twitter_likes WHERE id = @id', {
								['@id'] = like.id,
							}, function()
								-- like = nil
								print(DumpTable(CACHED_LIKES[tweetId]))
								print("removing like on message", tweet.message, "from id", like.authorId)
								CACHED_LIKES[tweetId][id] = nil
								-- table.remove(CACHED_LIKES[tweetId], id)
								if #CACHED_LIKES[tweetId] == 0 then CACHED_LIKES[tweetId] = nil end
								print(DumpTable(CACHED_LIKES[tweetId]))
								
								tweet.likes = tweet.likes - 1

								MySQL.Async.execute('UPDATE `phone_twitter_tweets` SET `likes` = likes - 1 WHERE id = @id', {
									['@id'] = tweet.id
								}, function()
									TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes)
									TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, false)
									TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes)
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
							TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes)
						end)    
					end)
				end
			end
		end

		--[[
			MySQL.Async.fetchAll('SELECT * FROM phone_twitter_tweets WHERE id = @id', {
				['@id'] = tweetId
			}, function (tweets)
				if (tweets[1] == nil) then return end
				local tweet = tweets[1]
				MySQL.Async.fetchAll('SELECT * FROM phone_twitter_likes WHERE authorId = @authorId AND tweetId = @tweetId', {
					['authorId'] = user.id,
					['tweetId'] = tweetId
				}, function (row) 
					if (row[1] == nil) then
						MySQL.Async.insert('INSERT INTO phone_twitter_likes (`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
							['authorId'] = user.id,
							['tweetId'] = tweetId
						}, function (newrow)
							MySQL.Async.execute('UPDATE `phone_twitter_tweets` SET `likes`= likes + 1 WHERE id = @id', {
								['@id'] = tweet.id
							}, function ()
								TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes + 1)
								TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, true)
								TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes + 1)
							end)    
						end)
					else
						MySQL.Async.execute('DELETE FROM phone_twitter_likes WHERE id = @id', {
							['@id'] = row[1].id,
						}, function (newrow)
							MySQL.Async.execute('UPDATE `phone_twitter_tweets` SET `likes`= likes - 1 WHERE id = @id', {
								['@id'] = tweet.id
							}, function ()
								TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes - 1)
								TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, false)
								TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes - 1)
							end)
						end)
					end
				end)
			end)
		]]
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
-- ALTER TABLE `phone_twitter_accounts`	CHANGE COLUMN `username` `username` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci';

gcPhoneT.twitter_login = function(username, password)
	local player = source
	local identifier = gcPhoneT.getPlayerID(player)
	
	local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
	if isAble then
		gcPhoneT.usaDatiInternet(identifier, mbToRemove)

		local user = getTwiterUserAccount(username, password)
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
		gcPhoneT.usaDatiInternet(identifier, mbToRemove)
			
		local user = getTwiterUserAccount(username, password)
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
				if (result == 1) then
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
		gcPhoneT.usaDatiInternet(identifier, mbToRemove)

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
			gcPhoneT.usaDatiInternet(identifier, mbToRemove)
				
			local user = getTwiterUserAccount(username, password)
			if user == false then
				TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
				return
			end

			local accountId = user and user.id
			local tweets = TwitterGetTweets(accountId)
			-- print(DumpTable(tweets))
			local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
			if isAble then
				gcPhoneT.usaDatiInternet(identifier, mbToRemove)
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
			gcPhoneT.usaDatiInternet(identifier, mbToRemove)
			local tweets = TwitterGetTweets(false)
			-- print(DumpTable(tweets))
			local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
			if isAble then
				gcPhoneT.usaDatiInternet(identifier, mbToRemove)
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
			gcPhoneT.usaDatiInternet(identifier, mbToRemove)
			
			local user = getTwiterUserAccount(username, password)
			if user == false then
				TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
				return
			end

			local accountId = user and user.id
			local tweets = TwitterGetFavotireTweets(accountId)
			-- print(DumpTable(tweets))
			local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
			if isAble then
				gcPhoneT.usaDatiInternet(identifier, mbToRemove)
				TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', player, tweets)
			else
				TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
			end
		else
			TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
		end
  	else
    	local tweets = TwitterGetFavotireTweets(false)
		-- print(DumpTable(tweets))
		local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.04 * #tweets)
		if isAble then
			gcPhoneT.usaDatiInternet(identifier, mbToRemove)
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
		if (result == 1) then
			TriggerClientEvent('gcPhone:twitter_setAccount', player, username, password, avatarUrl)
			TwitterShowSuccess(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_AVATAR_SUCCESS')
		else
			TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
		end
	end)
end