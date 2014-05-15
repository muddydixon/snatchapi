"use strict"

appInfo         = require "../../package.json"
config          = require "config"
deferred        = require "deferred"
uuid            = require "uuid"
qs              = require "querystring"
request         = require "request"
Url             = require "url"

dr              = require "../utils/deferred-redis"

parseJSON   = (str)->
  try
    JSON.parse str
  catch err
    str

module.exports = class Path
  @key: (cond = {})->
    key = "#{config.prefix or 'snatch'}:path:" +
      "#{cond.origin?.origin or '*'}:" +
      ["method", "status", "id"]
      .map((key)-> "#{cond[key] or '*'}").join(":")

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
            header:     parseJSON data["request:header"]
            body:       parseJSON data["request:body"]
          data.response =
            header:     parseJSON data["response:header"]
            body:       parseJSON data["response:body"]
          data
        )
      ))
    )
    .then((pathes)->
      pathes = [pathes] unless pathes instanceof Array
      pathes.map((path)->
        [m, origin, id] = path.id.match(/^(.+?)\:([^\:]+)$/)
        new Path({origin: origin}, path)
      )
    , (err)->
      console.log "Path.get", err
    )

  constructor: (origin, data = {})->
    unless data.path
      err = new Error("Path requires `path`")
      err.status = 400
      throw err

    @id         = data.id or "#{origin.origin}:#{uuid()}"
    @origin     = origin
    @path       = data.path
    @method     = data.method or "GET"
    @status     = data.status or "Normal"
    @comment    = data.comment or ""
    @request    = data.request or {header: {}, body: {}}
    @response   = data.response or {header: {}, body: {}}

  exec: ()->
    params =
      uri:      "#{@origin.origin}#{@path}"
      proxy:    @origin.proxy
      method:   @method
      form:     @request.body
      json:     true
      headers:  @request.header

    if Url.parse(@origin.origin).protocol is "https:"
      params.strictSSL = false
    console.log params

    d = deferred()
    request params, (err, res, body)->
      return d.reject(err) if err
      d.resolve([
        res.headers,
        parseJSON(body)
      ])

    d.promise

  save: ()->
    return new Error("no response") unless @response
    key = @key()
    deferred(
      dr("hset", key, "id",            @id)
      dr("hset", key, "origin",        @origin.origin)
      dr("hset", key, "path",          @path)
      dr("hset", key, "status",        @status)
      dr("hset", key, "method",        @method)
      dr("hset", key, "comment",       @comment)
      dr("hset", key, "request:header",  JSON.stringify @request.header)
      dr("hset", key, "request:body",    JSON.stringify @request.body)
      dr("hset", key, "response:header", JSON.stringify @response.header)
      dr("hset", key, "response:body",   JSON.stringify @response.body)
    )
  destroy: ()->
    dr("del", @key())

  key: ()-> Path.key(@)
