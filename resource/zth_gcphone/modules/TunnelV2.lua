local IDManager = module("zth_gcphone", "modules/IDManager")

local a='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function enc(b)return(b:gsub('.',function(c)local d,a='',c:byte()for e=8,1,-1 do d=d..(a%2^e-a%2^(e-1)>0 and'1'or'0')end;return d end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(c)if#c<6 then return''end;local f=0;for e=1,6 do f=f+(c:sub(e,e)=='1'and 2^(6-e)or 0)end;return a:sub(f+1,f+1)end)..({'','==','='})[#b%3+1]end;

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

-- define per dest regulator
Tunnel.delays = {}

-- set the base delay between Triggers for this destination in milliseconds (0 for instant trigger)
function Tunnel.setDestDelay(dest, delay)
    Tunnel.delays[dest] = {delay, 0}
end

local function tunnel_resolve(itable,key)
    local mtable = getmetatable(itable)
    local iname = mtable.name
    local ids = mtable.tunnel_ids
    local callbacks = mtable.tunnel_callbacks
    local identifier = mtable.identifier
    local license = mtable.license
    -- print("tunnel_resolve", license)

    local fname = key
    local no_wait = false
    if string.sub(key, 1, 1) == "_" then
        fname = string.sub(key, 2)
        no_wait = true
    end

  -- vRP 2
    local fcall = function(...)
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
                    rid = ids:gen()
                    callbacks[rid] = r
                end
                if SERVER then
                    TriggerRemoteEvent(license .. "::" .. iname .. ":tunnel_req", dest, fname, args, identifier, rid)
                else
                    TriggerRemoteEvent(license .. "::" .. iname .. ":tunnel_req", fname, args, identifier, rid)
                end
            end)
        else
            local rid = -1
            if r then
                rid = ids:gen()
                callbacks[rid] = r
            end

            if SERVER then
                TriggerRemoteEvent(license .. "::" .. iname .. ":tunnel_req", dest, fname, args, identifier, rid)
            else
                TriggerRemoteEvent(license .. "::" .. iname .. ":tunnel_req", fname, args, identifier, rid)
            end
        end

        if r then
            return r:wait()
        end
    end

    itable[key] = fcall -- add generated call to table (optimization)
    return fcall
end

function Tunnel.bindInterface(license, name, interface)
    license = enc(license)
    RegisterLocalEvent(license .. "::" .. name .. ":tunnel_req")
    AddEventHandler(license .. "::" .. name .. ":tunnel_req", function(member, args, identifier, rid)
        local source = source
        local f = interface[member]

        local rets = {}
        if type(f) == "function" then rets = {f(table.unpack(args, 1, table_maxn(args)))} end

        -- send response (even if the function doesn't exist)
        if rid >= 0 then
            if SERVER then
                TriggerRemoteEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res", source, rid, rets)
            else
                TriggerRemoteEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res", rid, rets)
            end
        end
    end)
end

function Tunnel.getInterface(license, name, identifier)
    if not identifier then identifier = GetCurrentResourceName() end
    license = enc(license)
    local ids = IDManager()
    local callbacks = {}

    -- build interface
    local r = setmetatable({}, { __index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier, license = license })

    -- receive response
    RegisterLocalEvent(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res")
    AddEventHandler(license .. "::" .. name .. ":" .. identifier .. ":tunnel_res", function(rid, args)
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