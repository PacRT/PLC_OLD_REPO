###
Module dependencies.
###
express = require "express"
routes = require "./routes"
user = require "./routes/user"
googimg = require "./routes/googimg"
ops = require "./routes/ops"
cluster = require "cluster"
numCPUs = require("os").cpus().length
passport = require "passport"
flash = require "connect-flash"
LocalStrategy = require("passport-local").Strategy

util = require "util"

if(cluster.isMaster)

  i = 0
  while(i < numCPUs)
    cluster.fork()
    i++
else
  users = [{ id: 1, username: 'bob', password: 'secret', email: 'bob@example.com' },
           { id: 2, username: 'joe', password: 'birthday', email: 'joe@example.com' }]

  findById = (id, fn) ->
    idx = id - 1
    if (users[idx])
      console.info "User exists - found by id"
      fn(null, users[idx])
    else
      fn(new Error('User ' + id + ' does not exist'))

  findByUsername = (username, fn) ->
    #for (i = 0, len = users.length; i < len; i++)
    for i in [0..users.length-1]
      user = users[i]
      if (user.username == username)
        console.info "User exists - found by username"
        return fn(null, user)
    return fn(null, null)

  passport.serializeUser (user, done) ->
    console.info("Serializing - User: " + util.inspect(user))
    return done(null, user.id)

  passport.deserializeUser (id, done) ->
    console.info("Deserializing - UserId: #{id}")
    findById id, (err, user) ->
      console.info "Deserializing - User:" + util.inspect(user)
      return done(err, user)

  passport.use(new LocalStrategy(
    (username, password, done) ->
      process.nextTick( () ->
        findByUsername(username, (err, user) ->
          if (err)
            return done(err)
          if (!user)
            return done(null, false, { message: 'Unknown user ' + username })
          if (user.password != password)
            return done(null, false, { message: 'Invalid password' })
          return done(null, user) ))))

  #stream_file_upload = require("./middleware/streamupload").stream_file_upload

  #http = require("http")
  path = require("path")
  app = express()

  # all environments
  app.configure(() ->
    app.set "port", process.env.PORT or 3000
    app.set "views", path.join(__dirname, "views")
    app.set "view engine", "ejs"
    app.use express.favicon()
    app.use express.logger("dev")
    app.use express.cookieParser()

    #app.use stream_file_upload
    app.use express.json()
    app.use express.urlencoded()
    #app.use express.multipart() #- probably we dont need it - check out while uploading big files

    app.use express.methodOverride()
    app.use express.session({ secret: 'keyboard cat' })

    app.use flash()
    app.use passport.initialize()
    app.use passport.session()

    app.use app.router
    app.use require("stylus").middleware(path.join(__dirname, "public"))
    app.use express.static(path.join(__dirname, "public"))
    app.use express.static(path.join(__dirname, "bower_components"))

    # development only
    app.use express.errorHandler()  if "development" is app.get("env")
  )

  #app.get "/", routes.index
  app.get "/", ops.ensureAuthenticated, routes.ngupload

  app.get('/api/users/me',
    passport.authenticate('local', { session: true }),
    (req, res) ->
      res.json({ id: req.user.id, username: req.user.username }))

  app.get "/jqupload", routes.jqupload
  app.get "/users", user.list
  app.all "/upload/**", ops.ensureAuthenticated, ops.upload

  app.get '/login', (req, res) ->
    res.render('login', { user: req.user, message: req.flash('error') })

  app.post '/login', passport.authenticate('local',
    { successRedirect: '/', failureRedirect: '/login', failureFlash: "error" }), (req, res) ->
      res.redirect('/')

  app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/'

  app.listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")


###app.get('*', googimg.googimg)
#http.createServer(app).listen app.get("port"), ->

io = require('socket.io').listen(app.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port"))

io.sockets.on 'connection', (socket) ->
  ops.sioupload(socket)

io.configure 'development', () ->
  io.enable 'browser client etag'
  io.set 'log level', 1###

###exports.ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated() is true
    next()
  res.redirect('/login')###


### # io.set 'transports', [ // //
#   'websocket'
, 'flashsocket'
, 'htmlfile'
, 'xhr-polling'
, 'jsonp-polling'
]###
