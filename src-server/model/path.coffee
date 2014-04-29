"use strict"

appInfo         = require "../../package.json"
config          = require "config"
deferred        = require "deferred"
uuid            = require "uuid"
qs              = require "querystring"
request         = require "request"

dr              = require "../utils/deferred-redis"

module.exports = class Path
  @key: (cond)->
    key = "#{config.prefix or 'snatch'}:path"
    for name in ["origin", "method", "status", "id"]
      key += ":#{cond[name] or '*'}"
    key

  @get: (cond)->
    getkey = @key(cond)

    dr("keys", getkey)
    .then((keys)->
      keys = [keys] unless keys instanceof Array
      return [] if keys.length is 0
      deferred.apply(deferred, keys.map((key)->
        dr("hgetall", key)
        .then((data)->
          data.request =
            header:     data["request:header"]
            body:       data["request:header"]
          data.response =
            header:     data["response:header"]
            body:       data["response:header"]
          data
        )
      ))
    )
    .then((pathes)->
      pathes = [pathes] unless pathes instanceof Array
      pathes.map((path)-> new Path(path))
    , (err)->
      console.log err
    )

  constructor: (data)->
    @id         = data.id or uuid()
    @origin     = data.origin
    @path       = data.path
    @method     = data.method
    @status     = data.status
    @request    = @parseRequest(data.request)
    @response   = @parseResponse(data.response)
    @comment    = data.comment

  parseRequest: (req)->
    return unless req
    body = req.body
      .replace(/^[\s\n\r\t\b]*|[\s\n\r\t\b]*$/g, "")
      .replace(/\r\n/g, "&")

    body:       qs.parse(body)
    header:     req.header

  parseResponse: (res)->
    return unless res

  exec: ()->
    params =
      url:      "#{@origin}#{@path}"
      proxy:    @proxy
      method:   @method
      form:     @request.body

    d = deferred()
    request params, (err, res, body)->
      return d.reject(err) if err
      d.resolve([res.headers, body])

    d.promise

  save: ()->
    return new Error("no response") unless @response
    key = @key()
    deferred(
      dr("hset", key, "id",            @id)
      dr("hset", key, "origin",        @origin)
      dr("hset", key, "path",          @path)
      dr("hset", key, "status",        @status)
      dr("hset", key, "method",        @method)
      dr("hset", key, "comment",       @comment)
      dr("hset", key, "request:header",  @request.header)
      dr("hset", key, "request:body",    @request.body)
      dr("hset", key, "response:header", @response.header)
      dr("hset", key, "response:body",   @response.body)
    )
  destroy: ()->
    dr("del", @key())


  key: ()->
    "#{config.prefix or 'snatch'}:path:#{@origin}:#{@method}:#{@status}"
