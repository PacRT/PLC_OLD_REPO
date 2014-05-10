-- KEYS[1] is the supplied UID here 
local username = redis.call('GET', "uid:" ..KEYS[1].. ":username")
local password = redis.call('GET', "uid:" ..KEYS[1].. ":password")
local email = redis.call('GET', "uid:" ..KEYS[1].. ":email")
print(KEYS[1] .."|".. username .."|".. password .."|".. email)
return KEYS[1] .."|".. username .."|".. password .."|".. email