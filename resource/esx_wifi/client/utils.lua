function getLowestDistanceTIndex(coords)
	indice = 0
	lowestDistance = 0

	torre = nil
	tempDistanza = nil
	for i=1, #torriRadio do
		torre = torriRadio[i]
		tempDistanza = Vdist(tonumber(torre.x) * 1.0, tonumber(torre.y) * 1.0, coords.z, coords.x, coords.y, coords.z)
		if tempDistanza < Config.raggioTorri then
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

function getPotenzaSegnale(distanze)
	raggioTorri = Config.raggioTorri
	if distanza < raggioTorri / 8 then
		return 4
	elseif distanza < raggioTorri / 1.5 then
		return 3
	elseif distanza < raggioTorri / 1.125 then
		return 2
	elseif distanza < raggioTorri then
		return 1
	else
		return 0
	end
end