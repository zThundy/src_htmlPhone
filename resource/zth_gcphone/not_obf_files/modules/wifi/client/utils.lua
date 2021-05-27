function Reti.getLowestDistanceTIndex(coords)
	local indice = 0
	local lowestDistance = 0

	local torre = nil
	local tempDistanza = nil

	for i = 1, #torriRadio do
		torre = torriRadio[i]
		tempDistanza = Vdist(tonumber(torre.x) * 1.0, tonumber(torre.y) * 1.0, coords.z, coords.x, coords.y, coords.z)

		if tempDistanza < Config.RaggioTorri then
			if lowestDistance == 0 then
				lowestDistance = tempDistanza
				indice = i
			else
				if tempDistanza < lowestDistance then
					lowestDistance = tempDistanza
					indice = i
				end
			end
		end
	end

	return indice, lowestDistance
end

function Reti.getPotenzaSegnale(curr_distance)
	local RaggioTorri = Config.RaggioTorri

	if curr_distance == nil then return 4 end

	if curr_distance < RaggioTorri / 8 then
		return 4
	elseif curr_distance < RaggioTorri / 1.5 then
		return 3
	elseif curr_distance < RaggioTorri / 1.125 then
		return 2
	elseif curr_distance < RaggioTorri then
		return 1
	else
		return 0
	end
end

function Reti.RefreshBlips()
	for _, v in pairs(blips_radius) do RemoveBlip(v) end
	for _, v in pairs(blips) do RemoveBlip(v) end

	for player, info in pairs(torriRadio) do
		local blip = AddBlipForCoord(info.x, info.y, 1.0)

		SetBlipHighDetail(blip, true)
		SetBlipSprite(blip, 459)
		SetBlipScale(blip, 0.5)
		SetBlipAsShortRange(blip, true)

		if info.broken then
			SetBlipColour(blip, 1)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Torre radio (rotta)")
			EndTextCommandSetBlipName(blip)
		else
			SetBlipColour(blip, 3)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Torre radio")
			EndTextCommandSetBlipName(blip)
		end

		if Config.DebugRadiusTowers then
			local radius = AddBlipForRadius(info.x, info.y, 1.0, Config.RaggioTorri)

			SetBlipColour(radius, 1)
			SetBlipAlpha(radius, 75)

			table.insert(blips_radius, radius)
		end

		table.insert(blips, blip)
	end

	return true
end