local WHATSAPP_GROUPS = {}

local function WhatsappShowNotificationError(player, title, message)
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

local function WhatsappShowNotificationSuccess(player, title, message)
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

-- to be optimized
local function UpdateGroupsCache()
    local r = MySQL.Sync.fetchAll("SELECT * FROM phone_whatsapp_groups", {})
    for k, v in pairs(r) do
        WHATSAPP_GROUPS[tonumber(v.id)] = v
    end
end

MySQL.ready(UpdateGroupsCache)

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

local function GetContact(identifier, number)
    for _, contact in pairs(CACHED_CONTACTS[tostring(identifier)]) do
        -- print(contact.number, number)
        if contact.number == number then
            -- print(DumpTable(contact))
            return contact
        end
    end
    return nil
end

local function UpdateGroupLabels(source)
    local identifier = gcPhoneT.getPlayerID(source)
    local number = gcPhoneT.getPhoneNumber(identifier)
    -- local groups = UpdateGroupsCache()

    for _, group in pairs(WHATSAPP_GROUPS) do
        local members = json.decode(group.partecipanti)
        for index, member in pairs(members) do
            -- print(member.number)
            local contact = GetContact(identifier, member.number)
            if contact then
                -- print(DumpTable(contact))
                member.display = contact.display
            end
        end
    end

    -- print(DumpTable(WHATSAPP_GROUPS))
    TriggerClientEvent("gcphone:whatsapp_updateGruppi", source, WHATSAPP_GROUPS, number)
end

ESX.RegisterServerCallback("gcPhone:getMessaggiFromGroupId", function(source, cb, id)
    local messages = {}
    local identifier = gcPhoneT.getPlayerID(source)
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

        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.1 * #messages)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
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
    UpdateGroupLabels(player)
end

gcPhoneT.whatsapp_sendMessage = function(data)
    -- print("should be sending messages", json.encode(data))
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)

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
    local identifier = gcPhoneT.getPlayerID(player)
    local myNumber = gcPhoneT.getPhoneNumber(identifier)

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
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

        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, #partecipanti * 0.2)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)

            MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                ['@id'] = data.gruppo.id,
                ['@partecipanti'] = json.encode(partecipanti)
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    if WHATSAPP_GROUPS[tonumber(data.gruppo.id)] then
                        WHATSAPP_GROUPS[tonumber(data.gruppo.id)].partecipanti = json.encode(partecipanti)
                        UpdateGroupLabels(player)
                    end
                    -- UpdateGroupsCache()
                    -- TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, UpdateGroupsCache(), myNumber)
                end
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
    local identifier = gcPhoneT.getPlayerID(player)
    local number = gcPhoneT.getPhoneNumber(identifier)

    -- print(number, group.id)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 5.0)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)

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
                MySQL.Async.execute("DELETE FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = group.id}, function()
                    -- UpdateGroupsCache()
                    WHATSAPP_GROUPS[tonumber(group.id)] = nil
                    UpdateGroupLabels(player)
                end)
                return
            end

            MySQL.Async.execute("UPDATE phone_whatsapp_groups SET partecipanti = @partecipanti WHERE id = @id", {
                ['@partecipanti'] = json.encode(partecipanti),
                ['@id'] = group.id
            }, function()
                -- UpdateGroupsCache()
                WHATSAPP_GROUPS[tonumber(group.id)].partecipanti = json.encode(partecipanti)
                UpdateGroupLabels(player)
            end)
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
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    local partecipanti = {}

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)

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
            if id then
                WHATSAPP_GROUPS[tonumber(id)] = {
                    icona = data.groupImage or '/html/static/img/app_whatsapp/defaultgroup.png',
                    id = id,
                    gruppo = data.groupTitle,
                    partecipanti = json.encode(partecipanti)
                }
                -- UpdateGroupsCache()
                UpdateGroupLabels(player)
            else
                WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_ERROR_CREATING_GROUP")
            end
            -- TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, UpdateGroupsCache(), phone_number)
        end)
    else
        WhatsappShowNotificationError(player, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
    end
end

gcPhoneT.whatsapp_deleteGroup = function(data)
    local id = data.gruppo.id
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local phone_number = gcPhoneT.getPhoneNumber(identifier)
    MySQL.Async.execute("DELETE FROM phone_whatsapp_groups WHERE id = @id", {['@id'] = id}, function()
        MySQL.Async.execute("DELETE FROM phone_whatsapp_messages WHERE idgruppo = @id", {['@id'] = id}, function()
            -- UpdateGroupsCache()
            WHATSAPP_GROUPS[tonumber(id)] = nil
            TriggerClientEvent("gcphone:whatsapp_updateGruppi", player, WHATSAPP_GROUPS, phone_number)
        end)
    end)
end

ESX.RegisterServerCallback("gcphone:whatsapp_editGroup", function(source, cb, group)
    local identifier = gcPhoneT.getPlayerID(source)

    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 2.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        
        MySQL.Async.execute("UPDATE phone_whatsapp_groups SET gruppo = @gruppo, icona = @icona WHERE id = @id", {
            ['@gruppo'] = group.gruppo,
            ['@icona'] = group.icona,
            ['@id'] = group.id
        }, function(rowsChanged)
            WHATSAPP_GROUPS[tonumber(group.id)].gruppo = group.gruppo
            WHATSAPP_GROUPS[tonumber(group.id)].icona = group.icona
            -- UpdateGroupsCache()
            UpdateGroupLabels(player)
            if rowsChanged > 0 then cb(true) else cb(false) end
        end)
    else
        WhatsappShowNotificationError(source, "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        -- TriggerClientEvent("gcphone:whatsapp_showError", "WHATSAPP_INFO_TITLE", "WHATSAPP_NOT_ENOUGH_GIGA")
        cb(false)
    end
end)