define (require)->
  "use strict"

  Pathes = require "./pathes"

  class Origin extends Backbone.Model
    default:
      origin: ""
      pathes: []
      port:   8031
    urlRoot:  "/api/origin"
    initialize: ->
      @set 'pathes', new Pathes(@get 'pathes') if @get 'pathes'
