"use strict"

appInfo         = require "../../package.json"
config          = require "config"
request         = require "request"
Url             = require "url"
qs              = require "querystring"
uuid            = require "uuid"
deferred        = require "deferred"
Redis           = require "redis"
Series          = require "series.js"

redis = Redis.createClient(
  config.redis?.port or 6379
  config.redis?.host or "localhost"
)
redis.on "error", (err)->
  console.log "require redis server"
  process.exit -1

dr = (method, args...)->
  d = deferred()
  args.push (err, res)->
    if err then d.reject(err) else d.resolve(res)

  redis[method].apply(redis, args)
  d.promise

# object overwrite
overwrite = (opts...)->
  option = {}
  for opt in opts
    for k, v of opt
      option[k] = v
  option


requestHeader = (req) ->
  req._header

responseHeader = (res) ->
  body = []
  for key, val of res.headers
    body.push "#{key}: #{val}"
  body.join "\n"

#
# ## index
#
index =
  get: (req, res) ->
    res.sendfile "public/index.html"

  post: (req, res) ->
    origin      = req.body.origin
    path        = req.body.path
    method      = req.body.method
    query       = req.body.query
    body        = req.body.body
    header      = req.body.header
    proxy       = req.body.proxy


    body        = body
      .replace(/^[\s\n\r\t\b]*|[\s\n\r\t\b]*$/g, "")
      .replace(/\r\n/g, "&")
    bodyObj     = qs.parse(body)

    originObject = Url.parse(origin)
    unless originObject.protocol and originObject.hostname
      return res.render("index",
        title: appInfo.name
        params: req.body
      )

    params =
      url:      origin + path
      query:    query
      proxy:    proxy
      method:   method
      form:     bodyObj

    request params, (err, reqRes, reqBody) ->
      return res.render("index",
        title: appInfo.name
        params: req.body
        requestHeader: requestHeader(reqRes.req)
        responseHeader: responseHeader(reqRes)
        requestBody: JSON.stringify(bodyObj)
        responseBody: reqBody
      )

#
# ## origin
#
origin =
  get: (req, res) ->
    res.sendfile "public/origin.html"
  post: (req, res)->
    key = "#{config.prefix or 'snatch'}:#{req.body.origin}:path:#{req.body.path}:#{req.body.method}:#{req.body.status}:#{uuid()}"

    body        = req.body.body
      .replace(/^[\s\n\r\t\b]*|[\s\n\r\t\b]*$/g, "")
      .replace(/\r\n/g, "&")
    bodyObj     = qs.parse(body)

    originObject = Url.parse(req.body.origin)
    unless originObject.protocol and originObject.hostname
      return res.redirect("/")

    params =
      url:      req.body.origin + req.body.path
      proxy:    req.body.proxy
      method:   req.body.method
      form:     bodyObj

    resBody     = undefined
    resHeader   = undefined

    deferred(()->
      d = deferred()
      request params, (err, _resRes, _resBody) ->
        resBody = _resBody
        return d.reject(err) if err
        # todo parse
        d.resolve(reqBody)

      d.promise
    ).then(
      dr('hset', key, "reqheader", req.body.header)
      dr('hset', key, "reqbody", req.body.body)
      dr('hset', key, "resheader", "")
      dr('hset', key, "resbody", resBody)
      dr('hset', key, "comment", req.body.comment)
    )
    .then((results)->
      res.redirect("/")
    )


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
