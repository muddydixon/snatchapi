define (require)->
  "use strict"

  Path = require "./path"

  class Pathes extends Backbone.Collection
    model: Path
