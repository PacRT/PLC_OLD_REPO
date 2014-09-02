-- KEYS[1] is the supplied UID here 
local username = redis.call('GET', "uid:" ..KEYS[1].. ":username")
local password = redis.call('GET', "uid:" ..KEYS[1].. ":password")
local email = redis.call('GET', "uid:" ..KEYS[1].. ":email")
local name = redis.call('GET', "uid:" ..KEYS[1].. ":name")
print(KEYS[1].. "|" ..username.. "|" ..password.. "|" ..email.. "|" ..(name or username))
return KEYS[1].. "|" ..username.. "|" ..password.. "|" ..email.. "|" ..(name or username)