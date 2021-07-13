-- nuovi post e request dei post
RegisterNUICallback('nuovoPost', function(data, cb)
    gcPhoneServerT.instagram_nuovoPost(data.username, data.password, data.imgTable)
    cb("ok")
end)

RegisterNUICallback("requestPosts", function(data, cb)
    gcPhoneServerT.instagram_getPosts(data.username, data.password)
    cb("ok")
end)

RegisterNetEvent("gcPhone:instagram_updatePosts")
AddEventHandler("gcPhone:instagram_updatePosts", function(posts)
    SendNUIMessage({ event = 'instagramRecivePosts', posts = posts })
end)

-- gestione like dei post
RegisterNUICallback('togglePostLike', function(data, cb)
    gcPhoneServerT.instagram_toggleLikePost(data.username, data.password, data.postId)
    cb("ok")
end)

RegisterNetEvent("gcPhone:instagram_updatePostLikes")
AddEventHandler("gcPhone:instagram_updatePostLikes", function(postId, likes)
    SendNUIMessage({ event = 'instagram_updatePostLikes', postId = postId, likes = likes })
end)

RegisterNetEvent("gcPhone:instagram_updateLikeForUser")
AddEventHandler("gcPhone:instagram_updateLikeForUser", function(postId, isLike)
    SendNUIMessage({ event = 'instagram_updatePostIsLiked', postId = postId, isLike = isLike })
end)
-- account

RegisterNUICallback("createNewAccount", function(data, cb)
    gcPhoneServerT.instagram_createAccount(data.username, data.password, data.avatarUrl)
    cb("ok")
end)

RegisterNUICallback("loginInstagram", function(data, cb)
    gcPhoneServerT.instagram_loginAccount(data.username, data.password)
    cb("ok")
end)

RegisterNUICallback('changePassword', function(data, cb)
    gcPhoneServerT.instagram_changePassword(data.username, data.password, data.newPassword)
    cb("ok")
end)

RegisterNUICallback('instagram_changeAvatar', function(data, cb)
    gcPhoneServerT.instagram_setAvatarurl(data.username, data.password, data.avatarUrl)
    cb("ok")
end)

-- sync posts

RegisterNetEvent("gcPhone:instagram_recivedPosts")
AddEventHandler("gcPhone:instagram_recivedPosts", function(data)
    SendNUIMessage({ event = "instagramRecivePosts", data = data })
end)

RegisterNetEvent("gcPhone:instagram_setAccount")
AddEventHandler("gcPhone:instagram_setAccount", function(username, password, avatarUrl)
    SendNUIMessage({ event = "instagramSetupAccount", data = {
        username = username,
        password = password,
        avatarUrl = avatarUrl
    } })
end)