"use strict"

config          = require "config"
appInfo         = require "../package.json"

express         = require "express"
path            = require "path"
deferred        = require "deferred"
http            = require "http"
routes          = require "./routes"

module.exports = class DashBoard
  constructor: (@port = 8030)->
    @app                = express()

    # all environments
    @app.use express.favicon()
    @app.use express.logger("dev")
    @app.use express.json()
    @app.use express.urlencoded()
    @app.use express.methodOverride()
    @app.use @app.router
    @app.use express.static(path.join(__dirname, "../public"))

    # development only
    @app.use express.errorHandler()  if "development" is @app.get("env")

    # routing
    routes @app

  run: ()->
    d = deferred()

    http.createServer(@app).listen @port, =>
      d.resolve @
    d.promise
