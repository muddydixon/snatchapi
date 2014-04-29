"use strict"

appInfo         = require "../../package.json"
config          = require "config"
deferred        = require "deferred"
uuid            = require "uuid"

dr              = require "../utils/deferred-redis"
Path            = require "./path"

module.exports = class Origin
  @get: (key = "*")->

    dr("keys", "#{config.prefix or 'snatch'}:origin:#{key}")
    .then((keys)->
      keys = [keys] unless keys instanceof Array
      return [] if keys.length is 0
      deferred.apply(deferred, keys.map((key)->
        origin = undefined
        dr("hgetall", key)
        .then((values)->
          origin = values
        )
        .then((origin)->
          Path.get(origin: origin.origin)
        )
        .then((pathes)->
          origin.pathes = pathes
          origin
        )
        .then((origin)->
          return origin
        , (err)->
          return err
        )
      ))
    )
    .then((origins)->
      origins = [origins] unless origins instanceof Array
      origins
    , (err)->
      console.log err
      []
    )

  constructor: (data)->
    @id         = uuid()
    @origin     = data.origin
    @proxy      = data.proxy
    if data.pathes
      @pathes     = data.pathes.map (path)-> new Path(path)

  save: ()->
    deferred(
      dr("hset", @key(), "id",     @id)
      dr("hset", @key(), "origin", @origin)
      dr("hset", @key(), "proxy",  @proxy)
    )
    .then((result)=>
      return @
    , (err)->
      console.log err
      return err
    )
  key: ()->
    "#{config.prefix or 'snatch'}:origin:#{@origin}"
