SaltyChat = {}

-- unused for now :P
gcPhoneT.removeEndpointSource = function()
    local player = source
    if SaltyChat[player] then SaltyChat[player] = nil end
end

gcPhoneT.setEndpointSource = function(endpoint)
    local player = source
    SaltyChat[player] = endpoint
end

gcPhoneT.getEndpointSource = function()
    local player = source
    return SaltyChat[player]
end
---------------------

gcPhoneT.EstablishCall = function(callerId)
    local player = source
    callerId = tonumber(callerId)
    exports["saltychat"]:EstablishCall(player, callerId)
end

gcPhoneT.EndCall = function(callerId)
    local player = source
    callerId = tonumber(callerId)
    exports["saltychat"]:EndCall(player, callerId)
end