--
-- Created by IntelliJ IDEA.
-- User: chiradip
-- Date: 8/27/14
-- Time: 11:45 AM
-- To change this template use File | Settings | File Templates.
--
-- incr global:getNextUserId
-- set uid:4:username bob
-- set username:bob:uid 4
-- set uid:4:email ch@ch.com
-- set uid:4:password secret
-- set email:ch@ch.com:uid 4

local uid = redis.call('INCR', "global:getNextUserId")

local unamecheck_uid = redis.call('GET', "username:" ..ARGV[1].. ":uid")
if unamecheck_uid then error(":::Username already exists") end
local emailcheck_uid = redis.call('GET', "email:" ..ARGV[2].. ":uid")
if emailcheck_uid then error(":::Email already registered with anothe user name.. yours?") end
redis.call('SET', "uid:" ..uid.. ":username", ARGV[1]) -- ARGV[1] is username
redis.call('SET', "username:" ..ARGV[1].. ":uid", uid)
redis.call('SET', "uid:" ..uid.. ":email", ARGV[2]) -- ARGV[2] is email
redis.call('SET', "uid:" ..uid.. ":password", ARGV[3]) -- ARGV[3] is password
redis.call('SET', "email:" ..ARGV[2].. ":uid", uid)
redis.call('SET', "uid:" ..uid.. ":name", ARGV[4]) -- ARGV[4] is the fullname of the user
redis.call('SET', "uid:" ..uid.. ":status", ARGV[5]) -- ARGV[5] is the status of user - active/inactive/premium etc.
return ARGV[1] ..":".. uid ..":".. ARGV[2]
