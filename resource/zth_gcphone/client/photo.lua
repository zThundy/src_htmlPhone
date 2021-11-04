local enabled = true
local HUD_ELEMENTS = {
    WANTED_STARS = 1,
    WEAPON_ICON = 2,
    CASH = 3,
    MP_CASH = 4,
    MP_MESSAGE = 5,
    VEHICLE_NAME = 6,
    AREA_NAME = 7,
    VEHICLE_CLASS = 8,
    STREET_NAME = 9,
    HELP_TEXT = 10,
    FLOATING_HELP_TEXT_1 = 11,
    FLOATING_HELP_TEXT_2 = 12,
    CASH_CHANGE = 13,
    RETICLE = 14,
    SUBTITLE_TEXT = 15,
    RADIO_STATIONS = 16,
    SAVING_GAME = 17,
    GAME_STREAM = 18,
    WEAPON_WHEEL = 19,
    WEAPON_WHEEL_STATS = 20,
    HUD_COMPONENTS = 21,
    HUD_WEAPONS = 22
}

local CellFrontCamActivate = function(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

local function HideHudLoop()
    Citizen.CreateThreadNow(function()
        while enabled do
            -- this for loop will hide all hud components
            for _, id in pairs(HUD_ELEMENTS) do HideHudComponentThisFrame(id) end
            -- these two elements will hide minimap and help texts
            HideHudAndRadarThisFrame()
            HideHelpTextThisFrame()
            Citizen.Wait(0)
        end
    end)
end

local function OpenFakeCamera(data, cb)
    enabled = true
	local frontCam = false
	CreateMobilePhone(1)
	CellCamActivate(true, true)
    HideHudLoop()
    -- if ignore controls is true, then send a callback to js
    -- to let the code continue with its things
    if data.ignoreControls then cb("ok") end
	while enabled do
		if IsControlJustPressed(1, 172) then -- ARROW UP
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
		elseif IsControlJustPressed(1, 177) and not data.ignoreControls then -- CANCEL
            cb(false)
        elseif IsControlJustPressed(1, 176) and not data.ignoreControls then -- ENTER
            cb(true)
		end
        Citizen.Wait(0)
	end
    -- destroy and delete fake camera effect
    DestroyMobilePhone()
    CellCamActivate(false, false)
    -- play animation to player :)
	PhonePlayOut()
	ClearPedTasksImmediately(GetPlayerPed(-1))
	Citizen.Wait(100)
	PhonePlayText()
end

RegisterNUICallback('openFakeCamera', function(data, cb) Citizen.CreateThreadNow(function() OpenFakeCamera(data, cb) end) end)
RegisterNUICallback('setEnabledFakeCamera', function(data, cb) enabled = data cb("ok") end)