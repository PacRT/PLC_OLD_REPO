// Generated by CoffeeScript 1.7.1
(function() {
  var FileData, client, findbyidlua, findbyusernamelua, lua_find_by_id, lua_find_by_username, reader, redis, registrationlua, util;

  redis = require("redis");

  client = redis.createClient();

  util = require("util");

  reader = require("./routes/filereader");

  FileData = reader.FileData;

  findbyidlua = new FileData("./miscscripts/findbyid.lua", "ascii");

  findbyusernamelua = new FileData("./miscscripts/findbyusername.lua", "ascii");

  registrationlua = new FileData("./miscscripts/registration.lua", "ascii");

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  exports.registerUser = function(name, username, password, email, status, fn) {
    console.log("Calling: registerUser");
    registrationlua.getData(function(err, data) {
      console.log("Registration lua content: " + data);
      if (!err) {
        console.log("Data " + data);
        return client["eval"](data, 0, "" + username, "" + email, "" + password, "" + name, "" + status, function(error, resp) {
          if (!error) {
            client.publish("RegReqConfEmail", "{\"name\" : \"" + name + "\", \"username\": \"" + username + "\", \"email\": \"" + email + "\", \"status\" : \"" + status + "\" }");
            console.log("Resp: " + resp);
            return fn(error, resp);
          } else {
            console.log("Error error: " + error);
            return fn(error, resp);
          }
        });
      } else {
        console.log("Error err: " + err);
        return console.log("" + (process.cwd()));
      }
    });
  };

  lua_find_by_id = "\n -- KEYS[1] is the supplied UID here \n local username = redis.call('GET', \"uid:\" ..KEYS[1].. \":username\")\n local password = redis.call('GET', \"uid:\" ..KEYS[1].. \":password\")\n local email = redis.call('GET', \"uid:\" ..KEYS[1].. \":email\")\n print(KEYS[1] ..\"|\".. username ..\"|\".. password ..\"|\".. email)\n return KEYS[1] ..\"|\".. username ..\"|\".. password ..\"|\".. email\n";

  lua_find_by_username = "\n -- KEYS[1] is the supplied username here \n local uid = redis.call('GET', \"username:\" .. KEYS[1] .. \":uid\" )\n local password = redis.call('GET', \"uid:\" ..uid.. \":password\")\n local email = redis.call('GET', \"uid:\" ..uid.. \":email\")\n print(uid ..\"|\".. KEYS[1] ..\"|\".. password ..\"|\".. email)\n return uid ..\"|\".. KEYS[1] ..\"|\".. password ..\"|\".. email\n";

  exports.findById = function(id, fn) {
    return findbyidlua.getData(function(err, data) {
      if (!err) {
        console.log("Data: " + data);
        return client["eval"](data, 1, "" + id, function(error, resp) {
          var arr, user;
          if (!error) {
            console.log(resp);
            arr = resp.split('|');
            user = {
              id: arr[0],
              username: arr[1],
              password: arr[2],
              email: arr[3],
              name: arr[4],
              status: arr[5]
            };
            if (arr[1]) {
              fn(null, user);
            } else {
              fn(new Error("User: " + username + " does not exist"));
            }
          } else {
            console.log("Error: " + error);
            fn(new Error("User: " + username + " does not exist"));
          }
        });
      }
    });
  };

  exports.findByUsername = function(username, fn) {
    return findbyusernamelua.getData(function(err, data) {
      console.log(data);
      return client["eval"](data, 1, "" + username, function(error, resp) {
        var arr, user;
        if (!error) {
          console.log(resp);
          arr = resp.split('|');
          user = {
            id: arr[0],
            username: arr[1],
            password: arr[2],
            email: arr[3],
            name: arr[4],
            status: arr[5]
          };
          if (arr[0]) {
            return fn(null, user);
          } else {
            return fn(null, null);
          }
        } else {
          console.log("Error: " + error);
          return fn(null, null);
        }
      });
    });
  };

  exports.findByIdOld = function(id, fn) {
    console.log(lua_find_by_id);
    return client["eval"](lua_find_by_id, 1, "" + id, function(error, resp) {
      var arr, user;
      if (!error) {
        console.log(resp);
        arr = resp.split('|');
        user = {
          id: arr[0],
          username: arr[1],
          password: arr[2],
          email: arr[3]
        };
        if (arr[1]) {
          fn(null, user);
        } else {
          fn(new Error("User: " + username + " does not exist"));
        }
      } else {
        console.log("Error: " + error);
        fn(new Error("User: " + username + " does not exist"));
      }
    });
  };

  exports.findByUsernameOld = function(username, fn) {
    console.log(lua_find_by_username);
    return client["eval"](lua_find_by_username, 1, "" + username, function(error, resp) {
      var arr, user;
      if (!error) {
        console.log(resp);
        arr = resp.split('|');
        user = {
          id: arr[0],
          username: arr[1],
          password: arr[2],
          email: arr[3]
        };
        if (arr[0]) {
          return fn(null, user);
        } else {
          return fn(null, null);
        }
      } else {
        console.log("Error: " + error);
        return fn(null, null);
      }
    });
  };

}).call(this);
