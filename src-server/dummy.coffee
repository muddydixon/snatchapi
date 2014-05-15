"use strict"

config          = require "config"
appInfo         = require "../package.json"
deferred        = require "deferred"

express         = require "express"
path            = require "path"
Url             = require "url"
qs              = require "qs"

module.exports = class App
  @servers: {}
  constructor: (@origin)->
    @app =      express()
    @pathMap = @getPathMap(@origin.pathes or [])

    @init()

  notFound: (req, res)->
    res.send "no path <a target='_blank' href='http://localhost:8030'>create path</a>"

  init: ()->
    # all environments
    @app.use express.logger("dev")
    @app.use express.json()
    @app.use express.urlencoded()
    @app.use express.methodOverride()
    @app.use @app.router

    # development only
    @app.use express.errorHandler()  if "development" is @app.get("env")

    # routing
    for path, methods of @pathMap
      for method, pathes of methods
        do (path, method, pathes)=>
          @app[method](path, (req, res, next)=>
            response = @getMatchedPath(req, pathes)

            if response
              for k, v of response.header
                res.set k, v
              res.send response.body
            else next()
          )
    @app.all("*", @notFound)
    @app

  getMatchedPath: (req, pathes)->
    dataPart    = ["post", "put"].indexOf(req.method) > -1 and "body" or "query"
    reqData     = req[dataPart]

    for path in pathes
      if dataPart is "query"
        pathData = qs.parse((Url.parse(path.path).query or "").replace(/^\?/, ''))
      else
        pathData = path.request.body

      if @isMatchPath(reqData, pathData)
        return path.response

    undefined

  isMatchPath: (reqData, pathData)->
    match = true
    for k, v of pathData
      return false unless reqData[k] is v
    match

  getPathMap: (pathes)->
    map = {}
    for path in pathes
      url       = Url.parse(path.path)
      pathname  = url.pathname
      method    = path.method.toLowerCase()

      map[pathname] = {} unless map[pathname]
      map[pathname][method] = [] unless map[pathname][method]
      map[pathname][method].push path
    map

  run: ->
    d = deferred()
    try
      @server = @app.listen(+@origin.port, =>
        d.resolve @
      )
    catch err
      d.reject err
    d.promise

  close: ->
    d = deferred()
    @server.close()
    d.resolve @
    d.promise
