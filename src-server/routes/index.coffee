"use strict"

appInfo         = require "../../package.json"
config          = require "config"
request         = require "request"
Url             = require "url"
qs              = require "querystring"
uuid            = require "uuid"
deferred        = require "deferred"
Series          = require "series.js"


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
# ## api
#
# self host for testing
#
api =
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

data =
  get: (req, res)->
    # uuid = do ->
    #   s4 = ->
    #     (0|(1 + Math.random()) * 0x10000)
    #       .toString(16)
    #       .substring(1)
    #   ->
    #     s4() + s4() + s4() + s4()

    # methods = ["GET", "POST", "PUT", "DELETE"]
    # statuses = ["Normal", "Abnormal"]

    # data = [0...3].map ()->
    #   origin: "http://localhost:#{8000 + (0|Math.random() * 10) * 10}"
    #   pathes: [0...3].map ()->
    #     path:     "/api/#{uuid()}/"
    #     method:   methods[0|Math.random() * methods.length]
    #     status:   statuses[0|Math.random() * statuses.length]
    #     comment:  "comment #{uuid()}"
    dr("keys", "#{config.prefix or 'snatch'}*")
    .then((keys)->
      deferred.apply(deferred, keys.map((key)->
        [origin, other] = key.split(":path:")
        origin = origin.replace(new RegExp("^#{config.prefix or 'snatch'}:"), '')
        [path, method, status, id] = other.split(":")

        dr('hgetall', key)
        .then((result)->
          {
            id:         id
            origin:     origin
            path:       path
            method:     method
            status:     status
            comment:    result.comment
            request:
              header:   result.reqheader
              body:     result.reqbody
            response:
              header:   result.resheader
              body:     result.resbody
          }
        , (err)->
          {
            id:         id
            origin:     origin
            path:       path
            method:     method
            status:     status
            err:        err.message
          }
        )
      ))
    )
    .then((results)->
      results = [results] unless results instanceof Array

      originMap = Series.nest().key((d)-> d.origin).map(results)
      originList = ({origin: origin, pathes: pathes} for origin, pathes of originMap)
      res.json {data: originList}
    )


# routes
routes = overwrite
  "/":          index
  "/origin":    origin
  "/api":       api
  "/data":      data

# routing
module.exports = (app) ->
  for route, methods of routes
    for method, handler of methods
      app[method] route, handler
