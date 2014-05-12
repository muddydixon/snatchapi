"use strict"

appInfo         = require "../../package.json"
config          = require "config"
deferred        = require "deferred"
uuid            = require "uuid"
qs              = require "querystring"
request         = require "request"

dr              = require "../utils/deferred-redis"

parse   = (str)->
  try
    JSON.parse str
  catch err
    str

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
            header:     parse data["request:header"]
            body:       parse data["request:body"]
          data.response =
            header:     parse data["response:header"]
            body:       parse data["response:body"]
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
    @comment    = data.comment
    @request    = data.request or {}
    @response   = data.response or {}

  exec: ()->
    csrf = @withCsrf() if @csrfName
    params =
      uri:      "#{@origin}#{@path}"
      proxy:    @proxy
      method:   @method
      form:     @request.body
      json:     true

    d = deferred()
    request params, (err, res, body)->
      return d.reject(err) if err
      d.resolve([
        res.headers,
        parse(body)
      ])

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
      dr("hset", key, "request:header",  JSON.stringify @request.header)
      dr("hset", key, "request:body",    JSON.stringify @request.body)
      dr("hset", key, "response:header", JSON.stringify @response.header)
      dr("hset", key, "response:body",   JSON.stringify @response.body)
    )
  destroy: ()->
    dr("del", @key())

  key: ()->
    "#{config.prefix or 'snatch'}:path:#{@origin}:#{@method}:#{@status}:#{@id}"
