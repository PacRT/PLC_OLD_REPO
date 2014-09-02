--
-- Created by IntelliJ IDEA.
-- User: chiradip
-- Date: 8/27/14
-- Time: 9:06 PM
-- To change this template use File | Settings | File Templates.
--

-- KEYS[1] is the supplied username here 
local uid = redis.call('GET', "username:" .. KEYS[1] .. ":uid" )
local password = redis.call('GET', "uid:" ..uid.. ":password")
local email = redis.call('GET', "uid:" ..uid.. ":email")
local name = redis.call('GET', "uid:" ..uid.. ":name")
print(uid .. "|" ..KEYS[1].. "|".. password .. "|" .. email.. "|" ..(name or KEYS[1]))
return uid .. "|" ..KEYS[1].. "|" ..password.. "|" ..email.. "|" ..(name or KEYS[1])

