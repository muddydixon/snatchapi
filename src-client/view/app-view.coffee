define (require)->
  Origin        = require "./../model/origin"
  Origins       = require "./../model/origins"
  Path          = require "./../model/path"
  Pathes        = require "./../model/pathes"

  PathView              = require "./path-view"
  OriginView            = require "./origin-view"
  OriginModalView       = require "./origin-modal-view"
  PathModalView         = require "./path-modal-view"

  class AppView extends Backbone.View
    el: $ "#app"
    Collection: Origins
    initialize: ->
      @collection = new @Collection
      @collection.bind "add", @appendItem

      @collection.fetch()

      @originModalView = new OriginModalView(Origin, @collection)
      @pathModalView   = new PathModalView(Path)

    render: ->
      pathModalView = @pathModalView
      @originModalView.render()
      @pathModalView.render()
      $(@el).append '<div class="container origins"></div>'

    appendItem: (origin)=>
      $(@container).append new OriginView(model: origin, pathModalView: @pathModalView).render()
