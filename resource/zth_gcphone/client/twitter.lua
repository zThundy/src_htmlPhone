RegisterNetEvent("gcPhone:twitter_getTweets")
AddEventHandler("gcPhone:twitter_getTweets", function(tweets)
    SendNUIMessage({event = 'twitter_tweets', tweets = tweets})
end)

RegisterNetEvent("gcPhone:twitter_getFavoriteTweets")
AddEventHandler("gcPhone:twitter_getFavoriteTweets", function(tweets)
    SendNUIMessage( {event = 'twitter_favoritetweets', tweets = tweets })
end)

RegisterNetEvent("gcPhone:twitter_newTweets")
AddEventHandler("gcPhone:twitter_newTweets", function(tweet, sourceAuthor)
	SendNUIMessage({ event = 'twitter_newTweet', tweet = tweet, sourceAuthor = sourceAuthor })
end)

RegisterNetEvent("gcPhone:twitter_updateTweetLikes")
AddEventHandler("gcPhone:twitter_updateTweetLikes", function(tweetId, likes)
    SendNUIMessage({ event = 'twitter_updateTweetLikes', tweetId = tweetId, likes = likes })
end)

RegisterNetEvent("gcPhone:twitter_setAccount")
AddEventHandler("gcPhone:twitter_setAccount", function(username, password, avatarUrl)
    SendNUIMessage({ event = 'twitter_setAccount', username = username, password = password, avatarUrl = avatarUrl })
end)

RegisterNetEvent("gcPhone:twitter_setTweetLikes")
AddEventHandler("gcPhone:twitter_setTweetLikes", function(tweetId, has_like)
    SendNUIMessage({ event = 'twitter_setTweetLikes', tweetId = tweetId, has_like = has_like })
end)

RegisterNUICallback('twitter_login', function(data, cb)
    gcPhoneServerT.twitter_login(data.username, data.password)
    cb("ok")
end)

RegisterNUICallback('twitter_changePassword', function(data, cb)
    gcPhoneServerT.twitter_changePassword(data.username, data.password, data.newPassword)
    cb("ok")
end)

RegisterNUICallback('twitter_createAccount', function(data, cb)
    gcPhoneServerT.twitter_createAccount(data.username, data.password, data.avatarUrl)
    cb("ok")
end)

RegisterNUICallback('twitter_getTweets', function(data, cb)
    gcPhoneServerT.twitter_getTweets(data.username, data.password)
    cb("ok")
end)

RegisterNUICallback('twitter_getFavoriteTweets', function(data, cb)
    gcPhoneServerT.twitter_getFavoriteTweets(data.username, data.password)
    cb("ok")
end)

RegisterNUICallback('twitter_postTweet', function(data, cb)
    gcPhoneServerT.twitter_postTweets(data.username or '', data.password or '', data.message)
    cb("ok")
end)

RegisterNUICallback('twitter_toggleLikeTweet', function(data, cb)
    gcPhoneServerT.twitter_toogleLikeTweet(data.username or '', data.password or '', data.tweetId)
    cb("ok")
end)

RegisterNUICallback('twitter_setAvatarUrl', function(data, cb)
    gcPhoneServerT.twitter_setAvatarUrl(data.username or '', data.password or '', data.avatarUrl)
    cb("ok")
end)

RegisterNUICallback('twitter_requestImage', function(data, cb)
    TriggerEvent("camera:open", data)
    cb("ok")
end)
