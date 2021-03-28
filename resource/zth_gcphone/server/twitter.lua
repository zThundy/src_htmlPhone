function TwitterShowError(player, title, message)
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


function TwitterShowSuccess(player, title, message)
	TriggerClientEvent("gcphone:sendGenericNotification", player, {
		message = message,
		title = title,
		icon = "twitter",
		color = "rgb(80, 160, 230)",
		appName = "Twitter"
	})
	-- TriggerClientEvent('gcPhone:twitter_showSuccess', player, title, message)
end


function TwitterGetTweets (accountId, cb)
	if accountId == nil then
		MySQL.Async.fetchAll([===[
			SELECT twitter_tweets.*,
				twitter_accounts.username as author,
				twitter_accounts.avatar_url as authorIcon
			FROM twitter_tweets
				LEFT JOIN twitter_accounts
				ON twitter_tweets.authorId = twitter_accounts.id
			ORDER BY id DESC LIMIT 130
		]===], {}, cb)
	else
		MySQL.Async.fetchAll([===[
			SELECT twitter_tweets.*,
				twitter_accounts.username as author,
				twitter_accounts.avatar_url as authorIcon,
				twitter_likes.id AS isLikes
			FROM twitter_tweets
				LEFT JOIN twitter_accounts
				ON twitter_tweets.authorId = twitter_accounts.id
				LEFT JOIN twitter_likes 
				ON twitter_tweets.id = twitter_likes.tweetId AND twitter_likes.authorId = @accountId
			ORDER BY id DESC LIMIT 130
		]===], { ['@accountId'] = accountId }, cb)
	end
end


function TwitterGetFavotireTweets (accountId, cb)
	if accountId == nil then
		MySQL.Async.fetchAll([===[
			SELECT twitter_tweets.*,
				twitter_accounts.username as author,
				twitter_accounts.avatar_url as authorIcon
			FROM twitter_tweets
				LEFT JOIN twitter_accounts
				ON twitter_tweets.authorId = twitter_accounts.id
			WHERE twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
			ORDER BY likes DESC, TIME DESC LIMIT 30
		]===], {}, cb)
	else
		MySQL.Async.fetchAll([===[
			SELECT twitter_tweets.*,
				twitter_accounts.username as author,
				twitter_accounts.avatar_url as authorIcon,
				twitter_likes.id AS isLikes
			FROM twitter_tweets
				LEFT JOIN twitter_accounts
				ON twitter_tweets.authorId = twitter_accounts.id
				LEFT JOIN twitter_likes 
				ON twitter_tweets.id = twitter_likes.tweetId AND twitter_likes.authorId = @accountId
			WHERE twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
			ORDER BY likes DESC, TIME DESC LIMIT 30
		]===], { ['@accountId'] = accountId }, cb)
	end
end


function getTwiterUserAccount(username, password, cb)
	MySQL.Async.fetchAll("SELECT id, username as author, avatar_url as authorIcon FROM twitter_accounts WHERE twitter_accounts.username = @username AND twitter_accounts.password = @password", {
		['@username'] = username,
		['@password'] = password
	}, function (data)
		if #data > 0 then
			cb(data[1])
		else
			cb(false)
		end
	end)
end


function TwitterPostTweet(username, password, message, player, realUser)
	local identifier = gcPhone.getPlayerID(player)

	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)

			getTwiterUserAccount(username, password, function(user)
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

    			MySQL.Async.insert("INSERT INTO twitter_tweets (`authorId`, `message`, `realUser`) VALUES(@authorId, @message, @realUser);", {
      				['@authorId'] = user.id,
      				['@message'] = message,
      				['@realUser'] = realUser
    			}, function (id)
      				MySQL.Async.fetchAll('SELECT * from twitter_tweets WHERE id = @id', {
        				['@id'] = id
      				}, function (tweets)
        				tweet = tweets[1]
        				tweet['author'] = user.author
        				tweet['authorIcon'] = user.authorIcon
        				TriggerClientEvent('gcPhone:twitter_newTweets', -1, tweet)
      				end)
    			end)
  			end)
		else
  			TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
		end
	end)
end


function TwitterToogleLike(username, password, tweetId, player)
	local identifier = gcPhone.getPlayerID(player)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.02, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)
			  
  			getTwiterUserAccount(username, password, function (user)
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

    			MySQL.Async.fetchAll('SELECT * FROM twitter_tweets WHERE id = @id', {
      				['@id'] = tweetId
    			}, function (tweets)
      				if (tweets[1] == nil) then return end
      				local tweet = tweets[1]
      				MySQL.Async.fetchAll('SELECT * FROM twitter_likes WHERE authorId = @authorId AND tweetId = @tweetId', {
        				['authorId'] = user.id,
        				['tweetId'] = tweetId
      				}, function (row) 
        				if (row[1] == nil) then
          					MySQL.Async.insert('INSERT INTO twitter_likes (`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
            					['authorId'] = user.id,
            					['tweetId'] = tweetId
          					}, function (newrow)
            					MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes + 1 WHERE id = @id', {
              						['@id'] = tweet.id
            					}, function ()
              						TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes + 1)
              						TriggerClientEvent('gcPhone:twitter_setTweetLikes', player, tweet.id, true)
              						TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes + 1)
            					end)    
          					end)
        				else
          					MySQL.Async.execute('DELETE FROM twitter_likes WHERE id = @id', {
            					['@id'] = row[1].id,
          					}, function (newrow)
            					MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes - 1 WHERE id = @id', {
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
			end)
		else
  			TwitterShowError(player, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  		end
  	end)
end


function TwitterCreateAccount(username, password, avatarUrl, cb)
	MySQL.Async.insert('INSERT IGNORE INTO twitter_accounts (`username`, `password`, `avatar_url`) VALUES(@username, @password, @avatarUrl)', {
		['username'] = username,
		['password'] = password,
		['avatarUrl'] = avatarUrl
	}, cb)
end
-- ALTER TABLE `twitter_accounts`	CHANGE COLUMN `username` `username` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci';

gcPhoneT.twitter_login = function(username, password)
	local identifier = gcPhone.getPlayerID(source)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)

  			getTwiterUserAccount(username, password, function (user)
				if user == false then
					TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
      				return
				end
				
				if user == nil then
      				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
    			else
      				TwitterShowSuccess(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_SUCCESS')
      				TriggerClientEvent('gcPhone:twitter_setAccount', source, username, password, user.authorIcon)
    			end
  			end)
  		else
  			TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  		end
  	end)
end

gcPhoneT.twitter_changePassword = function(username, password, newPassword)
	local identifier = gcPhone.getPlayerID(source)
	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
			gcPhone.usaDatiInternet(identifier, mbToRemove)
			  
			getTwiterUserAccount(username, password, function (user)
				if user == false then
					TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
      				return
				end

    			if user == nil then
      				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_ERROR')
    			else
      				MySQL.Async.execute("UPDATE `twitter_accounts` SET `password`= @newPassword WHERE twitter_accounts.username = @username AND twitter_accounts.password = @password", {
        				['@username'] = username,
        				['@password'] = password,
        				['@newPassword'] = newPassword
      				}, function (result)
        				if (result == 1) then
          					TriggerClientEvent('gcPhone:twitter_setAccount', source, username, newPassword, user.authorIcon)
          					TwitterShowSuccess(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_SUCCESS')
        				else
          					TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NEW_PASSWORD_ERROR')
        				end
      				end)
    			end
  			end)
  		else
  			TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  		end
  	end)
end

gcPhoneT.twitter_createAccount = function(username, password, avatarUrl)
  	local identifier = gcPhone.getPlayerID(source)
  	
	gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
  			gcPhone.usaDatiInternet(identifier, mbToRemove)
			TwitterCreateAccount(username, password, avatarUrl, function (id)
    			if (id ~= 0) then
      				TriggerClientEvent('gcPhone:twitter_setAccount', source, username, password, avatarUrl)
      				TwitterShowSuccess(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_ACCOUNT_CREATE_SUCCESS')
    			else
      				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_ACCOUNT_CREATE_ERROR')
    			end
  			end)
  		else
  			TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  		end
  	end)
end

gcPhoneT.twitter_getTweets = function(username, password)
	local identifier = gcPhone.getPlayerID(source)
	
	if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
  		gcPhone.isAbleToSurfInternet(identifier, 1, function(isAble, mbToRemove)
			if isAble then
				gcPhone.usaDatiInternet(identifier, mbToRemove)
				  
				getTwiterUserAccount(username, password, function (user)
					if user == false then
						TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
						return
					end

      				local accountId = user and user.id
      				TwitterGetTweets(accountId, function (tweets)
      					gcPhone.isAbleToSurfInternet(identifier, 0.04 * #tweets, function(isAble, mbToRemove)
							if isAble then
  								gcPhone.usaDatiInternet(identifier, mbToRemove)
        						TriggerClientEvent('gcPhone:twitter_getTweets', source, tweets)
        					else
  								TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  							end
  						end)
      				end)
    			end)
  			else
  				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  			end
  		end)
  	else
  		gcPhone.isAbleToSurfInternet(identifier, 1, function(isAble, mbToRemove)
			if isAble then
  				gcPhone.usaDatiInternet(identifier, mbToRemove)
    			TwitterGetTweets(nil, function (tweets)
    				gcPhone.isAbleToSurfInternet(identifier, 0.04 * #tweets, function(isAble, mbToRemove)
						if isAble then
  							gcPhone.usaDatiInternet(identifier, mbToRemove)
      						TriggerClientEvent('gcPhone:twitter_getTweets', source, tweets)
      					else
  							TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  						end
  					end)
    			end)
  			else
  				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  			end
  		end)
  	end
end

gcPhoneT.twitter_getFavoriteTweets = function(username, password)
	local identifier = gcPhone.getPlayerID(source)
	
	if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
  		gcPhone.isAbleToSurfInternet(identifier, 1, function(isAble, mbToRemove)
			if isAble then
				gcPhone.usaDatiInternet(identifier, mbToRemove)
				
				getTwiterUserAccount(username, password, function(user)
					if user == false then
						TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NO_ACCOUNT')
						return
					end

      				local accountId = user and user.id
      				TwitterGetFavotireTweets(accountId, function (tweets)
      					gcPhone.isAbleToSurfInternet(identifier, 0.04 * #tweets, function(isAble, mbToRemove)
							if isAble then
  								gcPhone.usaDatiInternet(identifier, mbToRemove)
        						TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', source, tweets)
        					else
  								TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  							end
  						end)
      				end)
    			end)
    		else
  				TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  			end
  		end)
  	else
    	TwitterGetFavotireTweets(nil, function (tweets)
      		gcPhone.isAbleToSurfInternet(identifier, 0.04 * #tweets, function(isAble, mbToRemove)
				if isAble then
  					gcPhone.usaDatiInternet(identifier, mbToRemove)
        			TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', source, tweets)
        		else
  					TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_NO_CONNECTION')
  				end
    		end)
    	end)
  	end
end

gcPhoneT.twitter_postTweets = function(username, password, message)
	local srcIdentifier = gcPhone.getPlayerID(source)
	TwitterPostTweet(username, password, message, source, srcIdentifier)
end

gcPhoneT.twitter_postImmagine = function(username, password, message)
	local srcIdentifier = gcPhone.getPlayerID(source)
	TwitterPostTweet(username, password, message, source, srcIdentifier)
end

gcPhoneT.twitter_toogleLikeTweet = function(username, password, tweetId)
	TwitterToogleLike(username, password, tweetId, source)
end

gcPhoneT.twitter_setAvatarUrl = function(username, password, avatarUrl)
	MySQL.Async.execute("UPDATE `twitter_accounts` SET `avatar_url`= @avatarUrl WHERE twitter_accounts.username = @username AND twitter_accounts.password = @password", {
		['@username'] = username,
		['@password'] = password,
		['@avatarUrl'] = avatarUrl
	}, function (result)
		if (result == 1) then
			TriggerClientEvent('gcPhone:twitter_setAccount', source, username, password, avatarUrl)
			TwitterShowSuccess(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_AVATAR_SUCCESS')
		else
			TwitterShowError(source, 'TWITTER_INFO_TITLE', 'APP_TWITTER_NOTIF_LOGIN_ERROR')
		end
	end)
end