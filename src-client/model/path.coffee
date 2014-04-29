define (require)->
  "use strict"

  class Path extends Backbone.Model
    default:
      path:     ""
      method:   "GET"
      status:   "Normal"
      comment:  ""
      request:  undefined
      response: undefined
    urlRoot:  "/api/path"
    initialize: (options)->
      console.log @, options
