--====================================================================================
-- #Author: zThundy__
--====================================================================================

-- notifiche

--[[
    RegisterNetEvent("gcPhone:instagram_showError")
    AddEventHandler("gcPhone:instagram_showError", function(title, message)
        SendNUIMessage({ event = 'instagram_showError', message = message, title = title, volume = volume })
    end)

    RegisterNetEvent("gcPhone:instagram_showSuccess")
    AddEventHandler("gcPhone:instagram_showSuccess", function(title, message)
        SendNUIMessage({ event = 'instagram_showSuccess', message = message, title = title, volume = volume })
    end)
]]

-- nuovi post e request dei post

RegisterNUICallback('nuovoPost', function(data, cb)
    TriggerServerEvent("gcPhone:instagram_nuovoPost", data.username, data.password, data.imgTable)
    cb("ok")
end)

RegisterNUICallback("requestPosts", function(data, cb)
    TriggerServerEvent("gcPhone:instagram_getPosts", data.username, data.password)
    cb("ok")
end)

RegisterNetEvent("gcPhone:instagram_updatePosts")
AddEventHandler("gcPhone:instagram_updatePosts", function(posts)
    if segnaleRadio > 0 then
        SendNUIMessage({event = 'instagramRecivePosts', posts = posts})
    end
end)

RegisterNetEvent("gcPhone:instagram_newPostToNUI")
AddEventHandler("gcPhone:instagram_newPostToNUI", function(post)
    SendNUIMessage({event = "instagramNewPost", post = post})
end)

-- gestione like dei post

RegisterNUICallback('togglePostLike', function(data, cb)
    TriggerServerEvent("gcPhone:instagram_toggleLikePost", data.username, data.password, data.postId)
    cb("ok")
end)

RegisterNetEvent("gcPhone:instagram_updatePostLikes")
AddEventHandler("gcPhone:instagram_updatePostLikes", function(postId, likes)
    SendNUIMessage({event = 'instagram_updatePostLikes', postId = postId, likes = likes})
end)

RegisterNetEvent("gcPhone:instagram_updateLikeForUser")
AddEventHandler("gcPhone:instagram_updateLikeForUser", function(postId, isLike)
    SendNUIMessage({event = 'instagram_updatePostIsLiked', postId = postId, isLike = isLike})
end)
-- account

RegisterNUICallback("createNewAccount", function(data, cb)
    -- print(data.username, data.password, data.avatarUrl)
    TriggerServerEvent("gcPhone:instagram_createAccount", data.username, data.password, data.avatarUrl)
    cb("ok")
end)

RegisterNUICallback("loginInstagram", function(data, cb)
    -- print(data.username, data.password)
    TriggerServerEvent("gcPhone:instagram_loginAccount", data.username, data.password)
    cb("ok")
end)

RegisterNUICallback('changePassword', function(data, cb)
    TriggerServerEvent("gcPhone:instagram_changePassword", data.username, data.password, data.newPassword)
    cb("ok")
end)

RegisterNUICallback('instagram_changeAvatar', function(data, cb)
    TriggerServerEvent("gcPhone:instagram_setAvatarurl", data.username, data.password, data.avatarUrl)
    cb("ok")
end)


-- sync posts

RegisterNetEvent("gcPhone:instagram_recivedPosts")
AddEventHandler("gcPhone:instagram_recivedPosts", function(data)
    SendNUIMessage({event = "instagramRecivePosts", data = data})
end)

RegisterNetEvent("gcPhone:instagram_setAccount")
AddEventHandler("gcPhone:instagram_setAccount", function(username, password, avatarUrl)
    SendNUIMessage({event = "instagramSetupAccount", data = {
        username = username,
        password = password,
        avatarUrl = avatarUrl
    }})
end)