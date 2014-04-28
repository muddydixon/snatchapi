define (require)->
  "use strict"

  Origin = require "./origin"

  class Origins extends Backbone.Collection
    model:      Origin
    url:        "/api/origin"
    parse:      (res)->
      res.data
