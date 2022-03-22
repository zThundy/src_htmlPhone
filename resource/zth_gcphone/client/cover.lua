myCover = "base"

local function RefreshCovers()
    local covers = gcPhoneServerT.cover_requestCovers()
    SendNUIMessage({ event = "receiveCovers", covers = covers })
end

local function ChangeCover(cover)
    local label = Config.Covers[cover].label or Config.Covers["base"].label
    cover = cover..".png"
    SendNUIMessage({ event = "changePhoneCover", cover = cover, label = label })
end

local function OpenShopMenu(myCovers)
    local elements = {}

    -- qui mi preparo la table per controllare quale cover ho già e quali no
    local tempCovers = {}
    for name, val in pairs(myCovers) do tempCovers[string.gsub(val.value, ".png", "")] = val end

    for name, info in pairs(Config.Covers) do
        if name ~= "base" then
            if tempCovers[name] == nil then
                table.insert(elements, { label = info.label.." - "..info.price.."$", value = info, name = name })
            end
        end
    end

    -- onMenuSelect
    onMenuSelect = function(data, _)
        if data.current.value == nil then return end
        local value = data.current.value
        local name = data.current.name

        if gcPhoneServerT.cover_buyCover(name) then
            ESX.ShowNotification(translate("COVER_BOUGHT_OK"))
            RefreshCovers()
        else
            ESX.ShowNotification(translate("COVER_BOUGHT_ERROR"))
        end

        ESX.UI.Menu.CloseAll()
        SendNUIMessage({ show = false })
        ChangeCover(name)
    end

    -- onMenuChangeIndex
    onMenuChangeIndex = function(data, _)
        ChangeCover(data.current.name)
    end

    -- onMenuClose
    onMenuClose = function(data, _)
        ESX.UI.Menu.CloseAll()
        ChangeCover("base")
        SendNUIMessage({ show = false })
    end

    ESX.UI.Menu.CloseAll()
    SendNUIMessage({ show = true })

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'negozio_cover', {
        title = translate("COVER_SHOP_TITLE"),
        elements = elements
    }, onMenuSelect, onMenuClose, onMenuChangeIndex)
end

RegisterNUICallback("requestMyCovers", function(data, cb)
    RefreshCovers()
    cb("ok")
end)

RegisterNUICallback("changingCover", function(data, cb)
    myCover = string.gsub(data.cover.value, ".png", "")
    onCoverChange()
    cb("ok")
end)

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
            OpenShopMenu(covers)
		end,
        onExit = function()
            ESX.UI.Menu.CloseAll()
            ChangeCover("base")
            SendNUIMessage({ show = false })
        end,
		msg = translate("HELPNOTIFICATION_COVER_SHOP_LABEL"),
	})

    local info = Config.CoverShopBlip
    if info.enable then
		local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipHighDetail(blip, true)
		SetBlipSprite(blip, info.sprite)
		SetBlipColour(blip, info.color)
		SetBlipScale(blip, info.scale)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.name)
		EndTextCommandSetBlipName(blip)
	end
end)