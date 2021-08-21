local IDManager = module("zth_gcphone", "modules/IDManager")

local a='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function enc(b)return(b:gsub('.',function(c)local d,a='',c:byte()for e=8,1,-1 do d=d..(a%2^e-a%2^(e-1)>0 and'1'or'0')end;return d end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(c)if#c<6 then return''end;local f=0;for e=1,6 do f=f+(c:sub(e,e)=='1'and 2^(6-e)or 0)end;return a:sub(f+1,f+1)end)..({'','==','='})[#b%3+1]end;
-- function dec(d)d=string.gsub(d,'[^'..d..'=]','');return (d:gsub('.', function(x)if (x == '=') then return '' end;local r,f='',(d:find(x)-1)for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end;return r;end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)if(#x ~= 8)then;return'';end;local c=0;for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end;return string.char(c)end))end;

local TriggerRemoteEvent = nil
local RegisterLocalEvent = nil
if SERVER then
    TriggerRemoteEvent = TriggerClientEvent
    RegisterLocalEvent = RegisterServerEvent
else
    TriggerRemoteEvent = TriggerServerEvent
    RegisterLocalEvent = RegisterNetEvent
end

local Tunnel = {}
Tunnel.delays = {}

--[[
    REMOVED TO CLEAR SOME MEMORY AND BECAUSE UNUSED

    function Tunnel.setDestDelay(dest, delay)
        Tunnel.delays[dest] = {delay, 0}
    end
]]

local function tunnel_resolve(itable, key)
    local mtable = getmetatable(itable)

    local fname = key
    local no_wait = false
    if string.sub(key, 1, 1) == "_" then
        fname = string.sub(key, 2)
        no_wait = true
    end

    -- this is the function that the resolver will call and send arguments
    local fcall = function(...)
        -- inside args are stored the name of the function
        -- and the argument of that function
        local args = {...}
        local r = nil

        local dest = nil
        if SERVER then
            dest = args[1]
            args = table.unpack(args, 2, table_maxn(args))
            if dest >= 0 and not no_wait then r = async() end
        elseif not no_wait then
            r = async()
        end

        -- get delay data
        local delay_data = nil
        if dest then delay_data = Tunnel.delays[dest] end
        if delay_data == nil then delay_data = {0, 0} end

        -- increase delay
        local add_delay = delay_data[1]
        delay_data[2] = delay_data[2] + add_delay

        if delay_data[2] > 0 then
            SetTimeout(delay_data[2], function() 
                delay_data[2] = delay_data[2] - add_delay
                local rid = -1
                if r then
                    rid = mtable.tunnel_ids:gen()
                    mtable.tunnel_callbacks[rid] = r
                end
                if SERVER then
                    TriggerRemoteEvent(mtable.license .. "::" .. mtable.name .. ":tunnel_req:" .. mtable.c, dest, fname, args, mtable.identifier, rid)
                else
                    TriggerRemoteEvent(mtable.license .. "::" .. mtable.name .. ":tunnel_req:" .. mtable.c, fname, args, mtable.identifier, rid)
                end
            end)
        else
            local rid = -1
            if r then
                rid = mtable.tunnel_ids:gen()
                mtable.tunnel_callbacks[rid] = r
            end
            if SERVER then
                TriggerRemoteEvent(mtable.license .. "::" .. mtable.name .. ":tunnel_req:" .. mtable.c, dest, fname, args, mtable.identifier, rid)
            else
                TriggerRemoteEvent(mtable.license .. "::" .. mtable.name .. ":tunnel_req:" .. mtable.c, fname, args, mtable.identifier, rid)
            end
        end
        if r then
            return r:wait()
        end
    end
    itable[key] = fcall
    return fcall
end

function Tunnel.bindInterface(license, name, interface)
    license = enc(license)
    local c = enc(tostring(os.time()))
    if SERVER then SetConvarReplicated("zth_phone_start", c) end
    RegisterLocalEvent(license .. "::" .. name .. ":tunnel_req:" .. c)
    AddEventHandler(license .. "::" .. name .. ":tunnel_req:" .. c, function(member, args, identifier, rid)
        local source = source
        local f = interface[member]
        local rets = {}
        if type(f) == "function" then rets = {f(table.unpack(args, 1, table_maxn(args)))} end
        if rid >= 0 then
            if SERVER then
                TriggerRemoteEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res:" .. c, source, rid, rets)
            else
                TriggerRemoteEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res:" .. c, rid, rets)
            end
        end
    end)
end

function Tunnel.getInterface(license, name, identifier)
    if not identifier then identifier = GetCurrentResourceName() end
    local c = GetConvar("zth_phone_start", "none")
    license = enc(license)
    local ids = IDManager()
    local callbacks = {}
    local r = setmetatable({}, {
        __index = tunnel_resolve,
        name = name,
        tunnel_ids = ids,
        tunnel_callbacks = callbacks,
        identifier = identifier,
        license = license,
        c = c
    })
    RegisterLocalEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res:" .. c)
    AddEventHandler(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res:" .. c, function(rid, args)
        local callback = callbacks[rid]
        if callback then
            -- free request id
            ids:free(rid)
            callbacks[rid] = nil
            -- call
            callback(table.unpack(args, 1, table_maxn(args)))
        end
    end)
    return r
end

return Tunnel