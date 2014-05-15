"use strict"

config          = require "config"

#
# ## testapi
#
# self host for testing
#
module.exports =
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
