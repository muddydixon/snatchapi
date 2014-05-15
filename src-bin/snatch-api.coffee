#!/usr/bin/env coffee
"use strict"

appInfo         = require "../package.json"
process.title   = "#{appInfo.name.toLowerCase()}"

config          = require "config"
commander       = require "commander"
deferred        = require "deferred"

Origin          = require "../src-server/model/origin"
Path            = require "../src-server/model/path"

Dummy           = require "../src-server/dummy"
DashBoard       = require "../src-server/dashboard"

program = commander.version(appInfo.version)
  .option("-o, --origin <origin>", "start only a origin server", String)
  .option("-p, --port <port>", "start only a origin port", Number)
  .parse(process.argv)

# start all server
unless program.origin
  return new DashBoard(config.port)
  # start dashboard
  .run()
  .then((dashboard)->
    console.log "#{process.title} server listening on port " + dashboard.port
    dashboard
  )
  # start dummyServers
  .then((dashboard)->
    Origin.get()
    .then((origins)->
      origins = [origins] unless origins instanceof Array
      origins.forEach (origin)->
        Dummy.servers[origin.id] = new Dummy(origin)

      deferred.apply deferred, ( dummy.run() for id, dummy of Dummy.servers )
    )
    .then((results)->
      results = [results] unless results instanceof Array
      results.map (result)->
        console.log "\tstart #{result.origin.origin} dummy server on #{result.origin.port}"

    , (err)->
      console.log err
    )
  )

# start specific dummy server
Origin.get(origin: program.origin)
.then(([origin])->
  origin.port = program.port or origin.port
  new Dummy(origin).run()
)
.then((dummy)->
  console.log "start #{dummy.origin.origin} dummy server on #{dummy.origin.port}"
  dummy
, (err)->
  console.log err
  err
)
