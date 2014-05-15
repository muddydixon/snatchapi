"use strict"

appInfo         = require "../../package.json"
config          = require "config"
deferred        = require "deferred"
uuid            = require "uuid"
Url             = require "url"

Dummy           = require "../dummy"
dr              = require "../utils/deferred-redis"
Path            = require "./path"

module.exports = class Origin
  @key: (origin = {})->
    "#{config.prefix or 'snatch'}:origin:#{origin.origin or '*'}"

  @get: (cond = {})->
    # get all origin keys
    dr("keys", @key(cond))
    .then((keys)->
      keys = [keys] unless keys instanceof Array
      return [] if keys.length is 0

      deferred.apply(deferred, keys.map((key)->
        origin = undefined

        dr("hgetall", key)
        .then((data)->          origin = new Origin(data))
        .then((origin)->        Path.get({origin}))
        .then((pathes)->
          pathes = [pathes] unless pathes instanceof Array
          origin.pathes = pathes
          origin
        )
        .then((origin)->
          return origin
        , (err)->
          console.log "Origin.get", err
          return
        )
      ))
    )
    .then((origins)->
      origins = [origins] unless origins instanceof Array
      origins.filter((d)-> d)
    , (err)->
      console.log "Origin.get", err
      []
    )

  constructor: (data = {})->
    unless data.origin
      err = new Error("Origin requires `origin`")
      err.status = 400
      throw err

    url = Url.parse(data.origin)

    @id         = data.id or uuid()
    @port       = data.port or 8031
    @origin     = "#{url.protocol}//#{url.auth or ''}@#{url.host}"
    @proxy      = data.proxy
    @pathes     = data.pathes?.map((path)-> new Path(@, path)) or []

  save: ()->
    deferred.apply(deferred,
      (dr("hset", @key(), k, @[k]) for k in ["id", "origin", "proxy", "port"])
    )
    .then((result)=>
      return @
    , (err)->
      console.log "Origin#save", err
      return err
    )
  destroy: ()->
    Dummy.servers[@id]?.close()
    console.log "\tstop #{@origin} on #{@port}"
    dr("del", @key())

  key: ()-> Origin.key(@)
