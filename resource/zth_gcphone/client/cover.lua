RegisterNUICallback("requestMyCovers", function(data, cb)
    ESX.TriggerServerCallback("gcphone:cover_requestCovers", function(covers)
        cb(covers)
    end)
end)

function openShopMenu()
    local elements = {}

    for k, v in pairs(Config.Covers) do
        -- il label andrà cambiato con una traduzione dei colori
        table.insert(elements, {label = k, value = v, name = k})
    end
    
    -- funzione extended apri menù

    -- onMenuSelect
    onMenuSelect = function(_, data)
        ESX.TriggerServerCallback("gcphone:cover_buyCover", function(ok)
            if ok then
                ESX.ShowNotification("~g~Cover comprata con successo")
            else
                ESX.ShowNotification("~r~Non hai abbastanza soldi in banca")
            end
        end, data.current.name)
    end

    -- onMenuChangeIndex
    onMenuChangeIndex = function(_, data)
        ChangeCover(data.current.name)
    end

    -- onMenuClose
    onMenuClose = function(_, data)
        ChangeCover("base")
    end
end

function ChangeCover(cover)
    cover = cover..".png"
    SendNUIMessages({ event = "changePhoneCover", cover = cover })
end