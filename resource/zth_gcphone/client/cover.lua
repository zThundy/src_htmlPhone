myCover = nil
-- local isMenuOpened = false

local function RefreshCovers()
    local covers = gcPhoneServerT.cover_requestCovers()
    -- ESX.TriggerServerCallback("gcphone:cover_requestCovers", function(covers)
    SendNUIMessage({ event = "receiveCovers", covers = covers })
    -- end)
end

local function ChangeCover(label, cover)
    cover = cover..".png"
    SendNUIMessage({ event = "changePhoneCover", cover = cover, label = label })
end

Citizen.CreateThread(function()
    while ESX == nil do Citizen.Wait(100) end

    local coords = Config.CoverShop
    TriggerEvent('gridsystem:registerMarker', {
		name = "negozio_cover",
		type = 20,
		pos = coords,
		color = { r = 55, g = 255, b = 55 },
		scale = vector3(0.8, 0.8, 0.8),
        action = function()
            local covers = gcPhoneServerT.cover_requestCovers()
            -- ESX.TriggerServerCallback("gcphone:cover_requestCovers", function(covers)
            openShopMenu(covers)
            -- end)
		end,
        onExit = function()
            ESX.UI.Menu.CloseAll()
            ChangeCover(Config.Language["NO_COVER_LABEL"], "base")
            SendNUIMessage({ show = false })
        end,
        -- need to think about this cause idk if i like this
        -- onEnter = function()
        --     SendNUIMessage({ show = true })
        -- end,
		msg = Config.Language["HELPNOTIFICATION_COVER_SHOP_LABEL"],
	})

    local info = Config.CoverShopBlip
    if info.enable then
		local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipHighDetail(blip, true)
		SetBlipSprite(blip, info.sprite)
		SetBlipColour(blip, info.color)
		SetBlipScale(blip, info.scale)
		SetBlipAsShortRange(blip, true)
		-- SetBlipAlpha(blip, 255)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.name)
		EndTextCommandSetBlipName(blip)
	end
end)

--[[
    AddEventHandler("gridsystem:hasExitedMarker", function(marker)
        if marker == nil then return end
        if marker.name == "negozio_cover" then
            ESX.UI.Menu.CloseAll()
            ChangeCover(Config.Language["NO_COVER_LABEL"], "base")
            SendNUIMessage({ show = false })
        end
    end)
]]

RegisterNUICallback("requestMyCovers", function(data, cb)
    RefreshCovers()
    cb("ok")
end)

RegisterNUICallback("changingCover", function(data, cb)
    myCover = string.gsub(data.cover.value, ".png", "")
    -- print("changingCover", myCover)
    onCoverChange()
    cb("ok")
end)

function openShopMenu(myCovers)
    local elements = {}
    -- print(DumpTable(myCovers))
    -- isMenuOpened = true

    -- Citizen.CreateThread(function()
    --     while isMenuOpened do
    --         if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.CoverShop, true) >= 5.0 then
    --             isMenuOpened = false
    --             ESX.UI.Menu.CloseAll()
    --             ChangeCover(Config.Language["NO_COVER_LABEL"], "base")
    --             SendNUIMessage({ show = false })
    --         end
    --         Citizen.Wait(1000)
    --     end
    -- end)

    -- qui mi preparo la table per controllare quale cover ho già e quali no
    local tempCovers = {}
    for name, val in pairs(myCovers) do tempCovers[string.gsub(val.value, ".png", "")] = val end

    for name, info in pairs(Config.Covers) do
        if tempCovers[name] == nil then
            table.insert(elements, { label = info.label.." - "..info.price.."$", value = info, name = name })
        end
    end

    -- onMenuSelect
    onMenuSelect = function(data, _)
        -- print(DumpTable(data))
        if data.current.value == nil then return end
        local value = data.current.value
        local name = data.current.name

        ESX.TriggerServerCallback("gcphone:cover_buyCover", function(ok)
            if ok then
                ESX.ShowNotification(Config.Language["COVER_BOUGHT_OK"])
                RefreshCovers()
            else
                ESX.ShowNotification(Config.Language["COVER_BOUGHT_ERROR"])
            end

            ESX.UI.Menu.CloseAll()
            SendNUIMessage({ show = false })
            ChangeCover(value.label, name)
        end, name)
        -- ESX.UI.Menu.CloseAll()
        -- SendNUIMessage({ show = false })
        -- ChangeCover(value.label, name)
    end

    -- onMenuChangeIndex
    onMenuChangeIndex = function(data, _)
        ChangeCover(data.current.value.label, data.current.name)
    end

    -- onMenuClose
    onMenuClose = function(data, _)
        ESX.UI.Menu.CloseAll()
        ChangeCover(Config.Language["NO_COVER_LABEL"], "base")
        SendNUIMessage({ show = false })
    end

    ESX.UI.Menu.CloseAll()
    SendNUIMessage({ show = true })

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'negozio_cover', {
        title = Config.Language["COVER_SHOP_TITLE"],
        elements = elements
    }, onMenuSelect, onMenuClose, onMenuChangeIndex)
end