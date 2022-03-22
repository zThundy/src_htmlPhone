function Reti.LoadAndSendWifi()
    for _, v in pairs(CACHED_WIFIS) do v.pos = vector3(v.x, v.y, v.z) end
    TriggerClientEvent('esx_wifi:riceviRetiWifi', -1, CACHED_WIFIS)
end

function Reti.UpdateCellTower(tower)
    if tower then
        MySQL.Async.execute("UPDATE phone_cell_towers SET tower_label = @label, x = @x, y = @y, broken = @broken WHERE id = @id", {
            ['@label'] = tower.tower_label,
            ['@x'] = tower.x,
            ['@y'] = tower.y,
            ['@broken'] = tower.broken,
            ['@id'] = tower.id
        }, function()
            for id, t in pairs(CACHED_TOWERS) do
                if t.id == tower.id then
                    t.label = tower.tower_label
                    t.x = tower.x
                    t.y = tower.y
                    t.broken = tower.broken
                end
            end
        end)
    end
end

function Reti.AddReteWifi(source, rete, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('INSERT INTO phone_wifi_nets(steam_id, label, password, x, y, z, due_date) VALUES(@steam_id, @label, @password, @x, @y, @z, @due_date)', {
        ['@steam_id'] = xPlayer.identifier,
        ['@label'] = rete.label,
        ['@password'] = rete.password,
        ['@x'] = tonumber(string.format("%." .. 3 .. "f", rete.coords.x)),
        ['@y'] = tonumber(string.format("%." .. 3 .. "f", rete.coords.y)),
        ['@z'] = tonumber(string.format("%." .. 3 .. "f", rete.coords.z)),
        ['@due_date'] = os.date("%Y-%m-%d %H:%m:%S", rete.due_date)
    }, function(rowsChanged)
        if rowsChanged > 0 then
            showXNotification(xPlayer, translate("WIFI_MODEM_CREATED_OK"))
            table.insert(CACHED_WIFIS, {
                steam_id = xPlayer.identifier,
                label = rete.label,
                password = rete.password,
                x = tonumber(string.format("%." .. 3 .. "f", rete.coords.x)),
                y = tonumber(string.format("%." .. 3 .. "f", rete.coords.y)),
                z = tonumber(string.format("%." .. 3 .. "f", rete.coords.z)),
                due_date = os.time() * 1000
            })
            Reti.LoadAndSendWifi()
            Reti.Debug(translate("WIFI_LOAD_DEBUG_4"))
            if cb ~= nil then cb(true) end
        else
            showXNotification(xPlayer, translate("WIFI_MODEM_CREATED_ERROR"))
            if cb ~= nil then cb(false) end
        end
    end)
end

function Reti.RemoveReteWifi(source, rete)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE * FROM phone_wifi_nets WHERE steam_id = @steam_id', {
        ['@steam_id'] = rete.owner_id
    }, function(rowsChanged)
        if rowsChanged > 0 then
            showXNotification(xPlayer, translate("WIFI_MODEM_DELETE_OK"))
            for id, r in pairs(CACHED_WIFIS) do
                if r.steam_id == rete.owner_id then
                    CACHED_WIFIS[id] = nil
                    break
                end
            end
            Reti.LoadAndSendWifi()
            Reti.Debug(translate("WIFI_LOAD_DEBUG_4"))
        else
            showXNotification(xPlayer, translate("WIFI_MODEM_DELETE_ERROR"))
        end
    end)
end

function Reti.UpdateReteWifi(source, rete, param)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('UPDATE phone_wifi_nets SET '..param..' = @'..param..' WHERE steam_id = @steam_id', {
        ['@steam_id'] = tostring(xPlayer.identifier),
        ['@'..param] = rete[param]
    }, function(rowsChanged)
        if rowsChanged > 0 then
            showXNotification(xPlayer, translate("WIFI_MODEM_UPDATE_OK"))
            for id, r in pairs(CACHED_WIFIS) do
                if r.steam_id == rete.owner_id then
                    r[param] = rete[param]
                    break
                end
            end
            Reti.LoadAndSendWifi()
            Reti.Debug(translate("WIFI_LOAD_DEBUG_4"))
        else
            showXNotification(xPlayer, translate("WIFI_MODEM_UPDATE_ERROR"))
        end
    end)
end

function Reti.CheckDueDate()
    Reti.Debug(translate("WIFI_LOAD_DEBUG_5"))
    for index, rete in pairs(CACHED_WIFIS) do
        if rete.not_expire == 0 then
            local due_date = math.floor(rete.due_date / 1000)
            local created = math.floor(rete.created / 1000)
            if os.difftime(created, due_date) >= 0 then
                Reti.Debug(translate("WIFI_LOAD_DEBUG_6"):format(rete.steam_id))
                MySQL.Async.execute("DELETE FROM phone_wifi_nets WHERE steam_id = @steam_id AND label = @label", {
                    ['@steam_id'] = rete.steam_id,
                    ['@label'] = rete.label
                })
            end
        else
            Reti.Debug(translate("WIFI_LOAD_DEBUG_7"):format(rete.steam_id))
        end
    end
end