--====================================================================================
--  Telefoni Fissi
--====================================================================================

local PHONE_BOXES_STATUS = {}
local USING_PHONE_BOX = false

local function getPhoneBoxNumber(coords)
    local x, y, z = "0", "0", "0"

    if coords.x < 0 then
        x = "1"
    end

    x = x .. string.format("%04d", tostring(math.ceil(math.abs(coords.x))))
    if coords.y < 0 then
        y = "1"
    end

    y = y .. string.format("%04d", tostring(math.ceil(math.abs(coords.y))))
    if coords.z < 0 then
        z = "1"
    end

    z = z .. string.format("%04d", tostring(math.ceil(math.abs(coords.z))))
    return  x .. y .. z
end

function StartFixedCall(phone_number)
    local number = ''
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 10)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end

    if phone_number == nil then
        if GetOnscreenKeyboardResult() then
            number =  GetOnscreenKeyboardResult()
        end
    else
        number = phone_number
    end

    if number ~= '' and number ~= nil then
        SendNUIMessage({ event = "autoStartCall", number = number, extraData = { useNumber = number } })
        PhonePlayCall(true)
    end
end

function AnswerPhone(infoCall)
    TogglePhone()
    SendNUIMessage({ event = 'waitingCall', infoCall = infoCall, initiator = initiator })
    gcPhoneServerT.acceptCall(infoCall, nil)
end

RegisterNetEvent("gcPhone:notifyFixePhoneChange")
AddEventHandler("gcPhone:notifyFixePhoneChange", function(_PhoneInCall)
    PHONE_BOXES_STATUS = _PhoneInCall
end)

RegisterNetEvent('gcPhone:register_FixePhone')
AddEventHandler('gcPhone:register_FixePhone', function(phone_number, data)
    Config.PhoneBoxes[phone_number] = data
end)

if Config.EnablePhoneBoxes then
    Citizen.CreateThread(function()
        local mod, inRangedist, dist = 0, 0, 0
        local inRangeToActivePhone = false
        local p_coords = nil

        while true do
            if #PHONE_BOXES_STATUS > 0 then
                p_coords = GetEntityCoords(GetPlayerPed(-1))
                for i, v in pairs(PHONE_BOXES_STATUS) do
                    dist = v.coords - p_coords
                    if dist <= Config.MaxPhoneBoxesRingRange then
                        inRangeToActivePhone = true
                        inRangedist = dist
                        if dist <= 1.0 then 
                            ESX.ShowHelpNotification(translate("HELPNOTIFICATION_PHONE_BOXES_ANSWER"):format(Config.KeyLabel))
                            if IsControlJustPressed(1, Config.KeyTakeCall) then
                                AnswerPhone(PHONE_BOXES_STATUS[i])
                                PHONE_BOXES_STATUS[i] = {}
                                StopSoundJS('ring2.ogg')
                                USING_PHONE_BOX = true
                            end
                        end
                        break
                    end
                end

                if inRangeToActivePhone and not currentPlaySound then
                    PlaySoundJS('ring2.ogg', 0.2 + (inRangedist - Config.MaxPhoneBoxesRingRange) / - (Config.MaxPhoneBoxesRingRange * 0.8), true)
                    currentPlaySound = true
                elseif inRangeToActivePhone then
                    mod = mod + 1
                    if mod == 15 then
                        mod = 0
                        SetSoundVolumeJS('ring2.ogg', 0.2 + (inRangedist - Config.MaxPhoneBoxesRingRange) / - (Config.MaxPhoneBoxesRingRange * 0.8))
                    end
                elseif not inRangeToActivePhone and currentPlaySound then
                    currentPlaySound = false
                    StopSoundJS('ring2.ogg')
                end
            else
                Citizen.Wait(5000)
            end

            Citizen.Wait(1)
        end
    end)

    Citizen.CreateThread(function()
        local p_coords = nil
        local props = {}
        local idle = 1

        while true do
            idle = 1
            p_coords = GetEntityCoords(GetPlayerPed(-1))
            if not USING_PHONE_BOX then
                for number, v in pairs(Config.PhoneBoxes) do
                    dist = Vdist(v.coords - p_coords)
                    if dist <= 2.5 then
                        if not props[number] then
                            props[number] = CreateObject(GetHashKey(Config.PhonePropModel), v.coords.x, v.coords.y, v.coords.z, false, true, false)
                        end
                        if dist <= 2.0 then
                            ESX.ShowHelpNotification(translate("HELPNOTIFICATION_PHONE_BOXES_CALL"):format(Config.KeyLabel))
                            if IsControlJustPressed(0, Config.KeyTakeCall) then
                                if not number then
                                    number = getPhoneBoxNumber(v.coords)
                                end
                                StartFixedCall(number)
                            end
                        end
                    else
                        if props[number] then
                            DeleteObject(props[number])
                            props[number] = nil
                        end
                    end
                end
            else
                idle = 1500
            end

            Citizen.Wait(idle)
        end
    end)
end