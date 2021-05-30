local WHATSAPP_GROUPS = {}

local function WhatsappShowNotificationError(player, titile, message)
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
		icon = "whatsapp",
		color = "rgb(90, 200, 105)",
		appName = "Whatsapp",
		sound = "Whatsapp_Message_Sound.ogg"
	})
end

local function WhatsappShowNotificationSuccess(player, titile, message)
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
		icon = "whatsapp",
		color = "rgb(90, 200, 105)",
		appName = "Whatsapp",
		sound = "Whatsapp_Message_Sound.ogg"
	})
end

local function updateCachedGroups()
    local r = MySQL.Sync.fetchAll("SELECT * FROM phone_whatsapp_groups", {})
    for k, v in pairs(r) do
        WHATSAPP_GROUPS[tonumber(v.id)] = v
    end
    return WHATSAPP_GROUPS
end

MySQL.ready(function()
    updateCachedGroups()
end)

local function formatTableIndex(table)
    local tb = {}
    for k, v in pairs(table) do
        if k ~= "creator" then
            tb[tonumber(k)] = v
        else
            tb["creator"] = v
        end
    end
    return tb
end

ESX.RegisterServerCallback("gcPhone:getMessaggiFromGroupId", function(source, cb, id)
    local messages = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    messages[tostring(id)] = {}

    MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_messages WHERE idgruppo = @id", {['@id'] = id}, function(result)
        for k, v in pairs(result) do
            -- inserisco i valori nella table come li vuole vue
            -- diobestemmia
            -- print("index on server is", k)
            table.insert(messages[tostring(v.idgruppo)], {
                id = v.idgruppo,
                sender = v.sender,
                message = v.message
            })
        end

        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 0.1 * #messages)
        if isAble then
            gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)
            cb(messages)
        else
            WhatsappShowNotificationError(source, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
            -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
            cb(false)
        end
    end)
end)

gcPhoneT.getAllGroups = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local number = gcPhoneT.getPhoneNumber(xPlayer.identifier)

    TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups(), number)
end

gcPhoneT.whatsapp_sendMessage = function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 1.5)
    if isAble then
        gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)

        MySQL.Async.insert("INSERT INTO phone_whatsapp_messages(idgruppo, sender, message) VALUES(@id, @sender, @message)", {
            ['@id'] = data.id,
            ['@sender'] = data.phoneNumber,
            ['@message'] = data.messaggio
        }, function(id)
            -- print("ho fatto la query. id è", id)
            if id > 0 then
                local group = WHATSAPP_GROUPS[tonumber(data.id)]

                for _, val in pairs(json.decode(group.partecipanti)) do
                    -- print(val.number, "il numero del partecipante è questo")
                    local g_source = gcPhoneT.getSourceFromPhoneNumber(val.number)
                    -- print(g_source, "ho ricevuto la source")

                    if g_source ~= nil then
                        -- message, label, sender, id | sender, label, message, id
                        TriggerClientEvent("gcphone:whatsapp_sendNotificationToMembers", g_source, data.phoneNumber, group.gruppo, data.messaggio, data.id)
                    end
                end
            end
        end)
    else
        WhatsappShowNotificationError(source, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
    end
end

function isUserInGroup(number, partecipanti)
    for k, v in pairs(partecipanti) do
        if tostring(v.number) == tostring(number) then
            return true
        end
    end

    return false
end

function getPartecipanti(groupid)
    local result = MySQL.Sync.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = groupid})
    if result[1] == nil then return nil end
    return json.decode(result[1].partecipanti)
end

-- ATTENZIONE
-- l'aggiornamento istantaneo dei partecipanti al gruppo, è solo per chi lo fa in quell'istante,
-- gli altri devono chiudere e riaprire il telefono
-- FIX
-- usi la funzione che ho fatto su getSourceFromPhoneNumber loopando i numeri sul
-- loop sotto. Non ho intenzione di farlo ora.
gcPhoneT.whatsapp_addGroupMembers = function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local myNumber = gcPhoneT.getPhoneNumber(xPlayer.identifier)

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 1)
    if isAble then
        gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)
        
        local partecipanti = formatTableIndex(getPartecipanti(data.gruppo.id))

        -- print(ESX.DumpTable(partecipanti))
        -- print(ESX.DumpTable(data.selected))
        -- print("---------------------------------------------")

        for _, val in pairs(data.contacts) do
            if partecipanti[tostring(val.id)] ~= nil then partecipanti[tostring(val.id)] = nil end
            if partecipanti[tonumber(val.id)] ~= nil then partecipanti[tonumber(val.id)] = nil end
            -- visto che nel js non ho voglia di passare contacts su i mutuate states
            -- controllo qua se il contatto non è stato toccato
            if val.number ~= myNumber then
                -- + 1 A CAZZIO DIOCAN MA PORCODDIO
                if data.selected[tonumber(val.id) + 1] then
                    partecipanti[tonumber(val.id)] = {
                        display = val.display,
                        icon = val.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                        id = val.id,
                        number = val.number
                    }
                end
            end
        end

        -- print(ESX.DumpTable(partecipanti))

        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, #partecipanti * 0.2)
        if isAble then
            gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)

            MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                ['@id'] = data.gruppo.id,
                ['@partecipanti'] = json.encode(partecipanti)
            }, function(rowsChanged)
                if rowsChanged > 0 then TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups(), myNumber) end
            end)
        else
            WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
            -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        end
    else
        WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
    end
end

gcPhoneT.whatsapp_leaveGroup = function(group)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local number = gcPhoneT.getPhoneNumber(xPlayer.identifier)

    -- print(number, group.id)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 5.0)
    if isAble then
        gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)

        MySQL.Async.fetchAll("SELECT * FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function(r)
            if r[1] == nil then return end

            local partecipanti = formatTableIndex(json.decode(r[1].partecipanti))

            -- print(ESX.DumpTable(partecipanti))
            -- print("-------------------------------------------")
            
            for id, v in pairs(partecipanti) do
                if v.number == number then
                    partecipanti[tonumber(id)] = nil
                    break
                end
            end

            -- print(ESX.DumpTable(partecipanti))
            -- print(#partecipanti)

            if #partecipanti == 0 then
                MySQL.Async.execute("DELETE FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function() updateCachedGroups() end)
                return
            end

            MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                ['@partecipanti'] = json.encode(partecipanti),
                ['@id'] = group.id
            }, function() updateCachedGroups() end)
        end)
    else
        WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
    end
end

--[[
    contacts:
        0:
            display: "stoprovando"
            icon: "https://u.trs.tn/tohqw.jpg"
            id: 1
            number: "5554444"
            selected: true
        1:
            display: "questoenuovo"
            id: 2
            number: "55529322"
            selected: true
    infoGroup:
        title: "Nessun titolo"
        image: null
]]

gcPhoneT.whatsapp_creaNuovoGruppo = function(data)
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    local phone_number = gcPhoneT.getPhoneNumber(xPlayer.identifier)
    local partecipanti = {}

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 1.5)
    if isAble then
        gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)

        -- print(ESX.DumpTable(partecipanti))
        -- print(ESX.DumpTable(data.selected))
        -- print("--------------------------------------------")

        for _, val in pairs(data.contacts) do
            if data.selected[tonumber(val.id) + 1] then
                partecipanti[tonumber(val.id)] = {
                    display = val.display,
                    icon = val.icon or '/html/static/img/app_whatsapp/defaultgroup.png',
                    id = val.id,
                    number = val.number
                }
            end
        end

        partecipanti = formatTableIndex(partecipanti)
        -- print(ESX.DumpTable(partecipanti))

        partecipanti["creator"] = {
            display = data.myInfo.display,
            number = data.myInfo.number,
            id = lastId,
            icon = '/html/static/img/app_whatsapp/defaultgroup.png'
        }

        MySQL.Async.insert("INSERT INTO phone_whatsapp_groups(icona, gruppo, partecipanti) VALUES(@icona, @gruppo, @partecipanti)", {
            ['@icona'] = data.groupImage or '/html/static/img/app_whatsapp/defaultgroup.png',
            ['@gruppo'] = data.groupTitle,
            ['@partecipanti'] = json.encode(partecipanti)
        }, function(id)
            TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, updateCachedGroups(), phone_number)
        end)
    else
        WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
    end
end

ESX.RegisterServerCallback("gcphone:whatsapp_editGroup", function(source, cb, group)
    local xPlayer = ESX.GetPlayerFromId(source)

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(xPlayer.identifier, 2.5)
    if isAble then
        gcPhoneT.usaDatiInternet(xPlayer.identifier, mbToRemove)
        
        MySQL.Async.execute("UPDATE phone_whatsapp_groups SET gruppo = @gruppo, icona = @icona WHERE id = @id", {
            ['@gruppo'] = group.gruppo,
            ['@icona'] = group.icona,
            ['@id'] = group.id
        }, function(rowsChanged)
            if rowsChanged > 0 then cb(true) else cb(false) end
        end)
    else
        WhatsappShowNotificationError(source, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        cb(false)
    end
end)