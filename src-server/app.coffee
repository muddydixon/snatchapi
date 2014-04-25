###
Module dependencies.
###
config          = require "config"
express         = require "express"
routes          = require "./routes"
http            = require "http"
path            = require "path"
appInfo         = require "../package.json"

app             = express()
process.title   = "#{appInfo.name.toLowerCase()}-#{appInfo.version}"

# all environments
app.set "port", process.env.PORT or 8030
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "../public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

# routing
routes app

# listen port
http.createServer(app).listen app.get("port"), ->
  console.log "#{process.title} server listening on port " + app.get("port")
