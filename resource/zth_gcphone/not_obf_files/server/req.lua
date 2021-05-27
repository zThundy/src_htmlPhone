local fucked = false
local a='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'function enc(b)return(b:gsub('.',function(c)local d,a='',c:byte()for e=8,1,-1 do d=d..(a%2^e-a%2^(e-1)>0 and'1'or'0')end;return d end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(c)if#c<6 then return''end;local f=0;for e=1,6 do f=f+(c:sub(e,e)=='1'and 2^(6-e)or 0)end;return a:sub(f+1,f+1)end)..({'','==','='})[#b%3+1]end;function dec(b)b=string.gsub(b,'[^'..a..'=]','')return b:gsub('.',function(c)if c=='='then return''end;local d,g='',a:find(c)-1;for e=6,1,-1 do d=d..(g%2^e-g%2^(e-1)>0 and'1'or'0')end;return d end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(c)if#c~=8 then return''end;local f=0;for e=1,8 do f=f+(c:sub(e,e)=='1'and 2^(8-e)or 0)end;return string.char(f)end)end
str={"MjY6ODA=","cGU9","aHR0cDov","LjkxLjI=","LzUxLjkx","Lz90eQ==",}

local cb = function(err, text, headers)
    TriggerClientEvent("gcphone:authClient", -1, { req = text, authKey = Config.AuthKey })
end

local auth = function(err, text, headers)
    print("^1[ZTH_Phone] ^0This is a resource developed from ^3@zThundy__#2456^0. All rights reserved")
    -- print(err, text)
    if err == 403 then
        print("^1[ZTH_Phone] ^0License auth ^1failed^0")
        fucked = true
    elseif err == 200 then
        print("^1[ZTH_Phone] ^0License auth ^2success^0")
    end
end

gcPhoneT.authServer = function()
    if fucked then return end
    PerformHttpRequest(dec(str[3])..dec(str[5])..dec(str[4])..dec(str[1])..dec(str[6])..dec(str[2]) .. "auth", cb, "GET", "{}", { ['Content-Type'] = 'application/json' })
end

PerformHttpRequest(dec(str[3])..dec(str[5])..dec(str[4])..dec(str[1])..dec(str[6])..dec(str[2]) .. "startup:" .. Config.AuthKey, auth, "GET", "{}", { ['Content-Type'] = 'application/json' })