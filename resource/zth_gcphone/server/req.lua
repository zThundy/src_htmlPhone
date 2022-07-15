local l=false
local a='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
-- function enc(b)return(b:gsub('.',function(c)local d,a='',c:byte()for e=8,1,-1 do d=d..(a%2^e-a%2^(e-1)>0 and'1'or'0')end;return d end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(c)if#c<6 then return''end;local f=0;for e=1,6 do f=f+(c:sub(e,e)=='1'and 2^(6-e)or 0)end;return a:sub(f+1,f+1)end)..({'','==','='})[#b%3+1]end;
function dec(b)b=string.gsub(b,'[^'..a..'=]','')return b:gsub('.',function(c)if c=='='then return''end;local d,g='',a:find(c)-1;for e=6,1,-1 do d=d..(g%2^e-g%2^(e-1)>0 and'1'or'0')end;return d end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(c)if#c~=8 then return''end;local f=0;for e=1,8 do f=f+(c:sub(e,e)=='1'and 2^(8-e)or 0)end;return string.char(f)end)end;
local s={"MjY6NTAwMA==","cGU9","aHR0cDov","LjkxLjI=","LzUxLjkx","Lz90eQ==","c3RhcnR1cDo=","YXV0aA==",}

local c = function(_, t, _)
    TriggerClientEvent("gcphone:authClient", -1, { req = t, authKey = Config.AuthKey })
end

local p = function(e, _, _)
    print("^1[ZTH_Phone] ^0This is a resource developed from ^3@zThundy__#2456^0. All rights reserved")
    print("^1[ZTH_Phone] ^0Current version is " .. GetResourceMetadata(GetCurrentResourceName(), "version"))
    if e == 403 then
        print("^1[ZTH_Phone] ^0License auth ^1failed^0")
        l = true
    elseif e == 200 then
        print("^1[ZTH_Phone] ^0License auth ^2success^0")
    end
end

-- have to change all get in post
gcPhoneT.authServer = function()
    if l then return end
    PerformHttpRequest(dec(s[3])..dec(s[5])..dec(s[4])..dec(s[1])..dec(s[6])..dec(s[2])..dec(s[8]), c, "GET", "{}", { ['Content-Type'] = 'application/json' })
end