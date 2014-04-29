"use strict"

appInfo         = require "../../package.json"
config          = require "config"
Url             = require "url"
deferred        = require "deferred"
Series          = require "series.js"

Origin          = require "../model/origin"
Path            = require "../model/path"

# object overwrite
overwrite = (opts...)->
  option = {}
  for opt in opts
    for k, v of opt
      option[k] = v
  option

#
# ## index
#
index =
  get: (req, res) ->
    res.sendfile "public/index.html"

#
# ## testapi
#
# self host for testing
#
testapi =
  get: (req, res) ->
    if req.query.fail
      res.json error:
        code: req.query.fail
        message: "fail"
    else
      res.json data: req.query
    return

  post: (req, res) ->
    if req.body.fail
      res.json error:
        code: req.body.fail
        message: "fail"
    else
      res.json data: req.body
    return

#
# ## api
#
api =
  origin:
    get: (req, res)->
      Origin.get()
      .then((results)->
        res.json {data: results}
      , (err)->
        res.json {error: {code: err.status, message: err.message}}
      )

    post: (req, res)->
      key = "#{config.prefix or 'snatch'}:#{req.body.origin}"
      deferred(do ()->
        try
          origin = new Origin(
            origin:         req.body.origin
            proxy:          req.body.proxy
          )
        catch err
          return err
      )
      .then((origin)->
        origin.save()
      )
      .then((origin)->
        res.json {data: origin}
      , (err)->
        console.log err
        res.json {error: {code: err.stats or 500, message: err.message}}
      )
  originId: {}
  path:
    get: (req, res)->
    post: (req, res)->
      path = new Path(req.body)

      path.exec()
      .then(([header, body])->
        path.response = {header, body}
        path.save()
      )
      .then((data)->
        res.json {data: path}
      , (err)->
        console.log err
        res.json {error: {code: err.status or 500, message: err.message}}
      )
  pathId:
    get: (req, res)->
    put: (req, res)->
    delete: (req, res)->
      Path.get({id: req.params.id})
      .then(([path])->
        console.log path
        unless path
          err = new Error("path not found for #{req.params.id}")
          err.status = 404
          return err
        path.destroy()
      )
      .then((result)->
        res.json {data: req.params.id}
      , (err)->
        res.json {error: {code: err.status or 500, message: err.message}}
      )



# routes
routes = overwrite
  "/":                  index
  "/testapi":           testapi
  "/api/origin":        api.origin
  "/api/origin/:id":    api.originId

  "/api/path":          api.path
  "/api/path/:id":      api.pathId

# routing
module.exports = (app) ->
  for route, methods of routes
    for method, handler of methods
      app[method] route, handler
