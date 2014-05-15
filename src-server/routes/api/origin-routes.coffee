"use strict"

config          = require "config"
deferred        = require "deferred"
Series          = require "series.js"
http            = require "http"

Dummy           = require "../../dummy"
Origin          = require "../../model/origin"
Path            = require "../../model/path"

{err2json}      = require "../../utils"

module.exports =
  "/api/origin":
    get: (req, res)->
      Origin.get()
      .then((origins)->
        res.json {data: origins}
      , (err)->
        res.json {error: err2json err}
      )

    post: (req, res)->
      origin = undefined
      deferred(do ()->
        try
          origin = new Origin(
            origin:     req.body.origin
            proxy:      req.body.proxy
            port:       req.body.port
          )
        catch err
          return err
      )
      .then((origin)->
        origin.save()
      )
      .then((origin)->
        Dummy.servers[origin.id]?.close() or undefined
      )
      .then(->
        (Dummy.servers[origin.id] = new Dummy(origin)).run()
      )
      .then((server)->
        console.log "\tstart #{origin.origin} dummy server on #{origin.port}"
        res.json {data: origin}
      , (err)->
        console.log err
        res.json {error: err2json err}
      )


  "/api/origin/:originId":
    get: (req, res)->
    post: (req, res)->
    put: (req, res)->
    delete: (req, res)->
      Origin.get(req.params.originId)
      .then(([origin])->
        origin.destroy()
      )
      .then(()->
        res.json {data: req.params.originId}
      , (err)->
        res.json {error: err2json err}
      )
