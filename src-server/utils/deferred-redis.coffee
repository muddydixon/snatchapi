"use strict"

config          = require "config"
Redis           = require "redis"
deferred        = require "deferred"

redis = Redis.createClient(
  config.redis?.port or 6379
  config.redis?.host or "localhost"
)
redis.on "error", (err)->
  console.log "require redis server"
  process.exit -1

module.exports = dr = (method, args...)->
  d = deferred()
  args.push (err, res)->
    if err then d.reject(err) else d.resolve(res)

  redis[method].apply(redis, args)
  d.promise
