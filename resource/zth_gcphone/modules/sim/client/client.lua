local function OpenSimMenu()
    ESX.UI.Menu.CloseAll()
    local elements = gcPhoneServerT.getSimList()
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'phone_change', {
        title = translate("SIM_MENU_TITLE"),
        elements = elements,
    }, function(data, menu)
        local phone_number = data.current.value.phone_number
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_change', {
            title = tostring(phone_number),
            elements = {
                { label = translate("SIM_MENU_CHOICE_1"), value = 'sim_use' },
                { label = translate("SIM_MENU_CHOICE_2"), value = 'sim_give' },
                { label = translate("SIM_MENU_CHOICE_3"), value = 'sim_rename' },
                { label = translate("SIM_MENU_CHOICE_4"), value = 'sim_delete' }
            },
        }, function(data2, menu2)
            if data2.current.value == 'sim_use' then
                ESX.UI.Menu.CloseAll()
                gcPhoneServerT.usaSim({ number = phone_number, piano_tariffario = data.current.piano_tariffario })
                ESX.ShowNotification(translate("SIM_USED_MESSAGE_OK"):format(phone_number))
                Citizen.Wait(2000)
                gcPhoneServerT.allUpdate()
            end

            if data2.current.value == 'sim_give' then
                ESX.UI.Menu.CloseAll()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification(translate("SIM_NO_PLAYER_NEARBY"))
                else
                    gcPhoneServerT.daiSim(phone_number, GetPlayerServerId(closestPlayer))
                end
                Citizen.Wait(2000)
                gcPhoneServerT.allUpdate()
            end

            if data2.current.value == 'sim_rename' then
                ESX.UI.Menu.CloseAll()
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'usate_dialog_money', {
                    title = translate("SIM_RENAME_MENU_LABEL")
                }, function(data3, menu3)
                    local sim_name = tostring(data3.value)

                    if #sim_name > 20 then
                        ESX.ShowNotification(translate("SIM_RENAME_ERROR"))
                        menu3.close()
                        return
                    end

                    gcPhoneServerT.rinominaSim(phone_number, sim_name)
                    ESX.ShowNotification(translate("SIM_RENAME_OK"))
                    ESX.UI.Menu.CloseAll()
                end, function(data3, menu3)
                    menu3.close()
                    ESX.ShowNotification(translate("SIM_RENAME_CANCEL"))
                end)
            end

            if data2.current.value == 'sim_delete' then
                ESX.UI.Menu.CloseAll()
                gcPhoneServerT.eliminaSim(phone_number)
                ESX.ShowNotification(translate("SIM_DESTROY_OK"):format(phone_number))
                Citizen.Wait(2000)
                gcPhoneServerT.allUpdate()
            end

            menu2.close()
        end, function(data2, menu2)
            menu2.close()
        end)

    end, function(data, menu)
        menu.close()
    end)
end

local function OpenSimInfoMenu(number)
    ESX.UI.Menu.CloseAll()

    -- this is just visual, the logic to renew is server
    -- sided
    local elementi = {}
    for k, v in pairs(Config.Tariffs) do
        table.insert(elementi, {label = v.label, value = v})
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_scegli_piano', {
        title = number,
        elements = elementi
    }, function(data, menu)
        local v = data.current.value
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_compra_piano', {
            title = number,
            elements = {
                {label = translate("SIM_TARIFFS_OFFER_LABEL_2"):format(v.minuti)},
                {label = translate("SIM_TARIFFS_OFFER_LABEL_3"):format(v.messaggi)},
                {label = translate("SIM_TARIFFS_OFFER_LABEL_4"):format(v.dati)},
                {label = translate("SIM_TARIFFS_OFFER_LABEL_7"):format(v.price)},
                {label = translate("SIM_TARIFFS_OFFER_LABEL_BUY"), value = "acquista"}
            }
        }, function(data2, menu2)
            if data2.current.value == "acquista" then
                local ok = gcPhoneServerT.buyOffer(v.label, number)
                if ok then
                    ESX.ShowNotification(translate("SIM_TARIFFS_BUY_OK"))
                else
                    ESX.ShowNotification(translate("SIM_TARIFFS_BUY_ERROR"))
                    OpenSimInfoMenu(number)
                end
                
                ESX.UI.Menu.CloseAll()
            end
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenShopMenu()
    ESX.UI.Menu.CloseAll()
    local elements = gcPhoneServerT.getSimList()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_listasim_numeri', {
        title = translate("SIM_TARIFFS_SHOP_TITLE"),
        elements = elements
    }, function(data, menu)
        local phone_number = data.current.value.phone_number
        local offerta = gcPhoneServerT.getOfferFromNumber(phone_number)
        if offerta.piano_tariffario == "nessuno" then
            elements = {
                {label = translate("SIM_TARIFFS_SHOP_NO_OFFER")},
                {label = translate("SIM_TARIFFS_SHOP_CHOOSE_OFFER"), value = "scegli_offerta", icon = 22}
            }
        else
            for k, v in pairs(Config.Tariffs) do
                if v.label == offerta.piano_tariffario then
                    elements = {
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_1"):format(v.label)},
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_2"):format(v.minuti)},
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_3"):format(v.messaggi)},
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_4"):format(v.dati)},
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_5"), value = "scegli_offerta", icon = 22},
                        {label = translate("SIM_TARIFFS_OFFER_LABEL_6"), value = "rinnova_offerta", icon = 22}
                    }
                end
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_listasim_piani', {
            title = phone_number,
            elements = elements
        }, function(data2, menu2)
            if data2.current.value == "scegli_offerta" then
                OpenSimInfoMenu(phone_number)
            end
            if data2.current.value == "rinnova_offerta" then
                local ok = gcPhoneServerT.renewOffer(offerta.piano_tariffario, phone_number)
                if ok then
                    ESX.ShowNotification(translate("SIM_TARIFFS_RENEWED_OK"))
                else
                    ESX.ShowNotification(translate("SIM_TARIFFS_RENEWED_ERROR"))
                    OpenShopMenu()
                end
            end
        end, function(data2, menu2) ESX.UI.Menu.CloseAll() end)
    end, function(data, menu) ESX.UI.Menu.CloseAll() end)
end

Citizen.CreateThread(function()
    while ESX == nil do Citizen.Wait(100) end
    while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end
    
    local coords = Config.TariffsShop
    TriggerEvent('gridsystem:registerMarker', {
        name = "piano_tariffario",
        type = 20,
        pos = coords,
        color = { r = 55, b = 55, g = 255 },
        scale =  vector3(0.8, 0.8, 0.8),
        action = function()
            OpenShopMenu()
        end,
        onExit = function()
            ESX.UI.Menu.CloseAll()
        end,
        msg = translate("HELPNOTIFICATION_SIM_SHOP_LABEL"),
    })

    local info = Config.TariffsBlip
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

    RegisterKeyMapping('+openSimMenu', translate("SETTINGS_SIM_KEY_LABEL"), 'keyboard', Config.SimCardKey)
    RegisterCommand('+openSimMenu', function() OpenSimMenu() end, false)
    RegisterCommand('-openSimMenu', function() end, false)
end)