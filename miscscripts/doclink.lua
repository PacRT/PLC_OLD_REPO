--
-- Created by IntelliJ IDEA.
-- User: chiradip
-- Date: 5/6/14
-- Time: 6:18 PM
-- To change this template use File | Settings | File Templates.
--

-- KEYS[1] is owner's UID, ARGV[1] is score/timestamp and ARGV[2] is docurl
redis.call('ZADD', "owner:"  ..KEYS[1]..":docs", ARGV[1], ARGV[2])
-- KEYS[2] is issuer's UID, ARGV[1] is score/timestamp and ARGV[2] is docurl
redis.call('ZADD', "issuer:"  ..KEYS[2]..":docs", ARGV[1], ARGV[2])
redis.call('HMSET', "doc:"..ARGV[2], "owner.uid", KEYS[1], "issuer.uid", KEYS[2])
print(KEYS[1] .."|".. KEYS[2] .."|".. ARGV[1] .."|".. ARGV[2])
