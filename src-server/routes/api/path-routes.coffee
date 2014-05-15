"use strict"

config          = require "config"
deferred        = require "deferred"
Series          = require "series.js"
qs              = require "qs"

Origin          = require "../../model/origin"
Path            = require "../../model/path"

{err2json}      = require "../../utils"

module.exports =
  "/api/path":
    get: (req, res)->
    post: (req, res)->
      path = undefined
      header    = qs.parse req.body.request.header.split("\n").join("&")
      body      = qs.parse req.body.request.body.split("\n").join("&")

      request =
        header: header
        body:   body

      Origin.get(req.body.origin)
      .then(([origin])->
        path = new Path(origin, {
          path:           req.body.path
          method:         req.body.method
          status:         req.body.status
          comment:        req.body.comment
          request:        {header, body}
        })
        path
      )
      .then((path)->
        path.exec()
      )
      .then(([header, body])->
        path.response = {header, body}
        path.save()
      )
      .then((data)->
        res.json {data: path}
      , (err)->
        console.log "route:path.post", err
        res.json {error: err2json err}
      )
  "/api/path/:pathId":
    get: (req, res)->
    put: (req, res)->
    delete: (req, res)->
      Path.get({id: req.params.pathId})
      .then(([path])->
        unless path
          err = new Error("path not found for #{req.params.id}")
          err.status = 404
          return err
        path.destroy()
      )
      .then((result)->
        res.json {data: req.params.pathId}
      , (err)->
        console.log "route:path/:pathId.delete", err
        res.json {error: err2json err}
      )
