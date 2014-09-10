-- KEYS[1] is the supplied UID here 
local username = redis.call('GET', "uid:" ..KEYS[1].. ":username")
local password = redis.call('GET', "uid:" ..KEYS[1].. ":password")
local email = redis.call('GET', "uid:" ..KEYS[1].. ":email")
local name = redis.call('GET', "uid:" ..KEYS[1].. ":name")
local status = redis.call('GET', "uid:" ..KEYS[1].. ":status")
print(KEYS[1].. "|" ..username.. "|" ..password.. "|" ..email.. "|" ..(name or username).. "|" ..(status or "active"))
return KEYS[1].. "|" ..username.. "|" ..password.. "|" ..email.. "|" ..(name or username).. "|" ..(status or "active")