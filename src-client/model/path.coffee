define (require)->
  "use strict"

  class Path extends Backbone.Model
    default:
      path:     ""
      method:   "GET"
      status:   "Normal"
      comment:  ""
      request:
        header: undefined
        body:   undefined
      response:
        header: undefined
        body:   undefined
    urlRoot:  "/api/path"
