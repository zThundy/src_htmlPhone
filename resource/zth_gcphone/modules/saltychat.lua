
-- unused for now :P
gcPhoneT.removeEndpointSource = function()
    if SaltyChat[source] then SaltyChat[source] = nil end
end

gcPhoneT.setEndpointSource = function(endpoint)
    SaltyChat[source] = endpoint
end

gcPhoneT.getEndpointSource = function()
    return SaltyChat[source]
end
---------------------

gcPhoneT.EstablishCall = function(callerId)
    callerId = tonumber(callerId)
    exports["saltychat"]:EstablishCall(source, callerId)
end

gcPhoneT.EndCall = function(callerId)
    callerId = tonumber(callerId)
    exports["saltychat"]:EndCall(source, callerId)
end