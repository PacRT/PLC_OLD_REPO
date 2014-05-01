findById = (id, fn) ->
  idx = id - 1
  if users[idx]
    fn null, users[idx]
  else
    fn new Error("User " + id + " does not exist")
  return
findByUsername = (username, fn) ->
  i = 0
  len = users.length

  while i < len
    user = users[i]
    return fn(null, user)  if user.username is username
    i++
  fn null, null

ensureAuthenticated = (req, res, next) ->
  return next()  if req.isAuthenticated()
  req.session.returnTo = req.path #This is t redirect the page to original requester after log-in
  res.redirect "/landing"
  return
express = require("express")
passport = require("passport")
LocalStrategy = require("passport-local").Strategy
routes = require "./routes"
ops = require "./routes/ops"
User = require "./User"
users = [
  {
    id: 1
    username: "bob"
    password: "secret"
    email: "bob@example.com"
  }
  {
    id: 2
    username: "joe"
    password: "birthday"
    email: "joe@example.com"
  }
]
passport.serializeUser (user, done) ->
  done null, user.id
  return

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done err, user
    return

  return

passport.use new LocalStrategy((username, password, done) ->
  process.nextTick ->
    User.findByUsername username, (err, user) ->
      return done(err)  if err
      unless user
        return done(null, false,
          message: "Unknown user " + username
        )
      unless user.password is password
        return done(null, false,
          message: "Invalid password"
        )
      done null, user

    return

  return
)

path = require "path"
app = express()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  #app.engine "ejs", require("ejs-locals")
  app.use express.logger()
  app.use express.cookieParser()
  #app.use express.bodyParser() - this bodyParser() is equivalent of the following three json(), urlencoded() and multipart()
  app.use express.json()
  app.use express.urlencoded()
  #app.use express.multipart() #- probably we dont need it - check out while uploading big files
  app.use express.methodOverride()
  app.use express.session(secret: "keyboard cat")
  app.use passport.initialize()
  app.use passport.session()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  app.use express.static(path.join(__dirname, "bower_components"))
  return

app.get "/", (req, res) ->
  res.render "main",
    user: req.user


app.get "/login", (req, res) ->
  res.render "partials/login",
    user: req.user
    message: req.session.messages

  return

app.get "/contact", (req, res) ->
  res.render "main",
    user: req.user

app.get "/partials/login", (req, res) ->
  res.render "partials/login",
    user: req.user
    message: req.session.messages

  return

app.get "/landing", (req, res) ->
  res.render "partials/landing",
    user: req.user
    message: req.session.messages

  return

app.get "/partials/landing", (req, res) ->
  res.render "partials/landing",
    user: req.user
    message: req.session.messages

  return

app.get "/partials/:filename", ensureAuthenticated, (req, res) ->
  filename = req.params.filename
  return unless filename # might want to change this
  res.render "partials/#{filename}",
    user: req.user
    message:req.session.message

  return

app.get "/ngupload", ensureAuthenticated, (req, res) ->
  res.render "upload-ng",
    user: req.user

#app.get "/main", ensureAuthenticated, (req, res) ->
#  res.render "main",
#    user: req.user
#
#  return

app.all "/upload/**", ensureAuthenticated, ops.upload

#app.get "/login", (req, res) ->
#  res.render "partials/login",
#    user: req.user
#    message: req.session.messages
#
#  return

app.post "/login", (req, res, next) ->
  passport.authenticate("local", (err, user, info) ->
    return next(err)  if err
    unless user
      req.session.messages = [info.message]
      return res.redirect("/#/login")
    req.logIn user, (err) ->
      return next(err)  if err
      console.log "req.session.returnTo #{req.session.returnTo}"
      if req.session.returnTo == "/partials/upload-part"
        res.redirect "/"
      else
        res.redirect req.session.returnTo || "/" #returnTo is a custom session variable to identify requesting page

    return
  ) req, res, next
  return

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/"
  return

app.listen 3000, ->
  console.log "Express server listening on port 3000"
  return
