myCover = nil
local isMenuOpened = false

Citizen.CreateThread(function()
    while ESX == nil do Citizen.Wait(100) end

    TriggerEvent('gridsystem:registerMarker', {
		name = "negozio_cover",
		type = 20,
		coords = Config.CoverShop,
		colour = { r = 55, g = 255, b = 55 },
		size =  vector3(0.8, 0.8, 0.8),
        action = function()
            ESX.TriggerServerCallback("gcphone:cover_requestCovers", function(covers)
                openShopMenu(covers)
            end)
		end,
		msg = "Premi ~INPUT_CONTEXT~ per acquistare una cover",
	})
end)

AddEventHandler("gridsystem:hasExitedMarker", function(marker)
    if marker == nil then return end
    if marker.name == "negozio_cover" then
        ESX.UI.Menu.CloseAll()
        ChangeCover("Nessuna cover", "base")
        SendNUIMessage({ show = false })
    end
end)

function requestCovers()
    ESX.TriggerServerCallback("gcphone:cover_requestCovers", function(covers)
        SendNUIMessage({ event = "receiveCovers", covers = covers })
    end)
end

RegisterNUICallback("requestMyCovers", function(data, cb)
    requestCovers()
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
    isMenuOpened = true

    Citizen.CreateThread(function()
        while isMenuOpened do
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), Config.CoverShop, true) >= 5.0 then
                isMenuOpened = false
                ESX.UI.Menu.CloseAll()
                ChangeCover("Nessuna cover", "base")
                SendNUIMessage({ show = false })
            end

            Citizen.Wait(1000)
        end
    end)

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
        if data.current.value == nil then return end
        local value = data.current.value
        local name = data.current.name

        TriggerServerEvent("nfesx_mall:buyGift", name, value.label, 'covers', value.price)

        --[[
            ESX.TriggerServerCallback("gcphone:cover_buyCover", function(ok)
                if ok then
                    ESX.ShowNotification("~g~Cover comprata con successo")
                    requestCovers()
                else
                    ESX.ShowNotification("~r~Non hai abbastanza punti per comprare una cover")
                end

                ESX.UI.Menu.CloseAll()
                SendNUIMessage({ show = false })

                ChangeCover(value.label, name)
            end, name)
        ]]

        ESX.UI.Menu.CloseAll()
        SendNUIMessage({ show = false })
        ChangeCover(value.label, name)
    end

    -- onMenuChangeIndex
    onMenuChangeIndex = function(data, _)
        ChangeCover(data.current.value.label, data.current.name)
    end

    -- onMenuClose
    onMenuClose = function(data, _)
        ESX.UI.Menu.CloseAll()
        ChangeCover("Nessuna cover", "base")
        SendNUIMessage({ show = false })
    end

    ESX.UI.Menu.CloseAll()
    SendNUIMessage({ show = true })

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'negozio_cover', {
        title = "Negozio di cover",
        elements = elements
    }, onMenuSelect, onMenuClose, onMenuChangeIndex)
end


function ChangeCover(label, cover)
    cover = cover..".png"
    SendNUIMessage({ event = "changePhoneCover", cover = cover, label = label })
end