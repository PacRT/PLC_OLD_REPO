redis = require("redis")
client = redis.createClient()
util = require "util"

#redis.debug_mode = true

reader = require "./routes/filereader"

FileData = reader.FileData

findbyidlua = new FileData("./miscscripts/findbyid.lua", "ascii")
findbyusernamelua = new FileData("./miscscripts/findbyusername.lua", "ascii")
registrationlua = new FileData("./miscscripts/registration.lua", "ascii")

# if you'd like to select database 3, instead of 0 (default), call
# client.select(3, function() { /* ... */ });
client.on "error", (err) ->
  console.log "Error " + err
  return

exports.registerUser = (name, username, password, email, status, fn) ->
  console.log "Calling: registerUser"
  registrationlua.getData( (err, data) ->
    console.log "Registration lua content: #{data}"
    unless err
      console.log "Data #{data}"
      client.eval data, 0, "#{username}", "#{email}", "#{password}", "#{name}", "#{status}", (error, resp) ->
        unless error
          client.publish "RegReqConfEmail", "{\"name\" : \"#{name}\", \"username\": \"#{username}\", \"email\": \"#{email}\", \"status\" : \"#{status}\" }"
          console.log "Resp: #{resp}"
          fn(error, resp)
        else
          console.log "Error error: #{error}"
          fn(error, resp)
    else
      console.log "Error err: #{err}"
      console.log "#{process.cwd()}"
  )
  return

lua_find_by_id = "\n
  -- KEYS[1] is the supplied UID here \n
  local username = redis.call('GET', \"uid:\" ..KEYS[1].. \":username\")\n
  local password = redis.call('GET', \"uid:\" ..KEYS[1].. \":password\")\n
  local email = redis.call('GET', \"uid:\" ..KEYS[1].. \":email\")\n
  print(KEYS[1] ..\"|\".. username ..\"|\".. password ..\"|\".. email)\n
  return KEYS[1] ..\"|\".. username ..\"|\".. password ..\"|\".. email\n
  "

lua_find_by_username = "\n
  -- KEYS[1] is the supplied username here \n
  local uid = redis.call('GET', \"username:\" .. KEYS[1] .. \":uid\" )\n
  local password = redis.call('GET', \"uid:\" ..uid.. \":password\")\n
  local email = redis.call('GET', \"uid:\" ..uid.. \":email\")\n
  print(uid ..\"|\".. KEYS[1] ..\"|\".. password ..\"|\".. email)\n
  return uid ..\"|\".. KEYS[1] ..\"|\".. password ..\"|\".. email\n
  "

exports.findById = (id, fn) ->
  findbyidlua.getData( (err, data) ->
    unless err
      console.log "Data: #{data}"
      client.eval data, 1, "#{id}", (error, resp) ->
        unless error
          console.log resp
          arr = resp.split '|'
          user = {
            id: arr[0]
            username: arr[1]
            password: arr[2]
            email: arr[3]
            name: arr[4]
            status: arr[5]
          }
          if arr[1]
            fn null, user
          else
            fn new Error("User: #{username} does not exist")
        else
          console.log "Error: #{error}"
          fn new Error("User: #{username} does not exist")
        return
  )

exports.findByUsername = (username, fn) ->
  findbyusernamelua.getData( (err, data) ->
    console.log data
    client.eval data, 1, "#{username}", (error, resp) ->
      unless error
        console.log resp
        arr = resp.split '|'
        user = {
          id: arr[0]
          username: arr[1]
          password: arr[2]
          email: arr[3]
          name: arr[4]
          status: arr[5]
        }
        if arr[0]
          fn null, user
        else
          #fn new Error("User: #{username} does not exist")
          fn null, null
      else
        console.log "Error: #{error}"
        #fn new Error("User: #{username} does not exist")
        fn null, null
  )


exports.findByIdOld = (id, fn) ->
  console.log lua_find_by_id
  client.eval lua_find_by_id, 1, "#{id}", (error, resp) ->
    unless error
      console.log resp
      arr = resp.split '|'
      user = {
        id: arr[0]
        username: arr[1]
        password: arr[2]
        email: arr[3]
      }
      if arr[1]
        fn null, user
      else
        fn new Error("User: #{username} does not exist")
    else
      console.log "Error: #{error}"
      fn new Error("User: #{username} does not exist")
    return

exports.findByUsernameOld = (username, fn) ->
  console.log lua_find_by_username
  client.eval lua_find_by_username, 1, "#{username}", (error, resp) ->
    unless error
      console.log resp
      arr = resp.split '|'
      user = {
        id: arr[0]
        username: arr[1]
        password: arr[2]
        email: arr[3]
      }
      if arr[0]
        fn null, user
      else
        #fn new Error("User: #{username} does not exist")
        fn null, null
    else
      console.log "Error: #{error}"
      #fn new Error("User: #{username} does not exist")
      fn null, null



