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

allowCrossDomain = (req, res, next) ->
  res.header('Access-Control-Allow-Origin', "*")
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')

  next()


app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  #app.engine "ejs", require("ejs-locals")
  app.use express.logger('tiny')
  app.use express.cookieParser()
  #app.use express.bodyParser() - this bodyParser() is equivalent of the following three json(), urlencoded() and multipart()
  app.use express.json()
  app.use express.urlencoded()
  #app.use express.multipart() #- probably we dont need it - check out while uploading big files
  app.use express.methodOverride()
  app.use express.session(
    secret: "hizibizi kitkat"
  )
  app.use passport.initialize()
  app.use passport.session()
  app.use(allowCrossDomain)
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  app.use express.static(path.join(__dirname, "bower_components"))
  return

getuser = (req, res) ->
  if typeof req.user != 'undefined'
    return req.user.name
  else
    return 'notdefined'

app.get "/", (req, res) ->
  res.render "main",
    user: req.user
    name: getuser(req, res)

app.get "/contact", (req, res) ->
  res.render "main",
    user: req.user

app.get "/landing", (req, res) ->
  res.render "partials/landing", {user: req.user, message: req.session.messages}
  return

app.get "/partials/landing", (req, res) ->
  res.render "partials/landing", {user: req.user, message: req.session.messages}
  return

app.get "/about", (req, res) ->
  res.render "partials/about", {user: req.user, message: req.session.messages}
  return

app.get "/partials/about", (req, res) ->
  res.render "partials/about",
    user: req.user
    message: req.session.messages

  return

app.get "/register", (req, res) ->
  res.render "partials/register",
    user: req.user
    message: req.session.messages

  return

app.get "/partials/register", (req, res) ->
  res.render "partials/register",
    user: req.user
    message: req.session.messages

  return

app.get "/loginfailure", (req, res) ->
  res.render "partials/loginfailure",
    user: req.user
    message: req.session.messages

  return

app.get "/partials/loginfailure", (req, res) ->
  res.render "partials/loginfailure",
    user: req.user
    message: req.session.messages

  return


app.get "/registrationResponse", (req, res) ->
  res.render "partials/registrationResponse", {user: req.user, message: req.session.messages}
  return

app.get "/partials/registrationResponse", (req, res) ->
  res.render "partials/registrationResponse", {user: req.user, message: req.session.messages}
  return

app.get "/inactiveResponse", (req, res) ->
  res.render "partials/inactiveResponse", {user: req.user, message: req.session.messages}
  return

app.get "/partials/inactiveResponse", (req, res) ->
  res.render "partials/inactiveResponse", {user: req.user, message: req.session.messages}
  return

app.get "/registrationError", (req, res) ->
  res.render "partials/registrationError", {user: req.user, message: req.session.messages}
  return

app.get "/partials/registrationError", (req, res) ->
  res.render "partials/registrationError", {user: req.user, message: req.session.messages}
  return

app.get "/dashboard", ensureAuthenticated, (req, res) ->
  res.render "partials/dashboard",
    user: req.user
    message: req.session.messages

  return

app.get "/invite", ensureAuthenticated, (req, res) ->
  res.render "partials/invite",
    user: req.user
    message: req.session.messages

  return

app.get "/partials/invite", (req, res) ->
  res.render "partials/invite",
    user: req.user
    message: req.session.messages

  return


app.get "/messages", (req, res) ->
  res.send(req.session.messages)

app.get "/partials/:filename", ensureAuthenticated, (req, res) ->
  filename = req.params.filename
  return unless filename # might want to change this
  res.render "partials/#{filename}",
    user: req.user
    message:req.session.messages

  return

app.all "/upload/**", ensureAuthenticated, ops.upload

app.post "/login", (req, res, next) ->
  passport.authenticate("local", (err, user, info) ->
    return next(err)  if err
    unless user
      req.session.messages = [info.message]
      req.loginfailed = true
      console.log "info.message #{info.message}"
      return res.redirect("/#/loginfailure")
    console.log "User: %j", user
    return res.redirect '/#/inactiveResponse' if user.status == "inactive"
    req.logIn user, (err) ->
      return next(err)  if err
      console.log "req.session.returnTo #{req.session.returnTo}"
      if req.session.returnTo == "/partials/upload-part"
        res.redirect "/#/"
      else if req.session.returnTo == "/documents"
        res.redirect "/#/dashboard"
      else
        res.redirect req.session.returnTo || "/" #returnTo is a custom session variable to identify requesting page

    return
  ) req, res, next
  return

app.post "/register", (req, res, next) ->
  console.log "Registering user: #{req.param("username")}"
  console.log "Registering user's password (hehe dont keep it long here): #{req.param("password")}"
  console.log "Registering user's email: #{req.param("email")}"
  User.registerUser(req.param("name"), req.param("username"), req.param("password"), req.param("email"), "inactive", (error, resp) ->
    console.log "/register - error #{error}"
    unless error
      res.redirect '/#/registrationResponse'
    else
      req.session.messages = "Error: #{error.substring(error.lastIndexOf(':::')+3)}"
      res.redirect '/#/registrationError'
  )
  #res.redirect '/#/registrationResponse'
  # , {response: "Check your email at #{req.param('email')} for quickly complete last leg of your registration"}
  #User.registerUser(req.getParameter())

app.get "/documents", ensureAuthenticated, ops.getdocuments2

app.get "/documents/:vs/:prt/:fid", ensureAuthenticated, ops.fileServiceMask

app.get "/logout", (req, res) ->
  req.logout()
  res.redirect "/#/"
  return

app.listen 8000, ->
  console.log "Express server listening on port 8000"
  return
