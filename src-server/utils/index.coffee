"use strict"

module.exports =
  err2json: (err)->
    code:         err.status or 500
    message:      err.message

  overwrite: (opts...)->
    option = {}
    for opt in opts
      for k, v of opt
        option[k] = v
    option
