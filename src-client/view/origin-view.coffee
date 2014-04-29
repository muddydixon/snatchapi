define (require)->
  "use strict"

  Pathes        = require "../model/pathes"
  PathView      = require "./path-view"

  class OriginView extends Backbone.View
    container: ".origins"
    tagName: "div"
    attributes:
      class: "origin"
    template: (origin)->
      """
      <div class='row text-origin'>
        <div class='col-md-11'>
          <h1>#{origin.get 'origin'}</h1>
        </div>
        <div class='col-md-1 text-right'>
          <a href='#' data-toggle='modal' data-target='#create-request'>
            <i class='fa fa-plus-square fa-lg'></i>
          </a>&nbsp;
          <a href='#' data-toggle='modal' data-target='#delete-origin'>
            <i class='fa fa-trash-o fa-lg'></i>
          </a>
        </div>
      </div>
      <table class='table'>
        <colgroup>
          <col width='30%'>
          <col width='10%'>
          <col width='10%'>
          <col width='40%'>
          <col width='10%'>
        </colgroup>
        <tbody class='pathes'></tbody>
      </table>
      """
    Collection: Pathes
    initialize: (options)->
      @pathModalView = options.pathModalView if options.pathModalView

      @collection = new @Collection
      @collection.bind "add", @appendItem

      if @model.get("pathes")
        @model.get("pathes").each (path)=>
          @collection.add path

    render: ->
      $(@container).append $(@el).html(@template @model).attr(id: @model.id)
      @el

    events:
      "click [data-toggle='modal']": "callPathModal"

    callPathModal: ()->
      $("#create-request [name='origin']").val(@model.get "origin")
      @pathModalView.collection = @collection

    appendItem: (path)=>
      setTimeout ()=>
        pathEl = new PathView(model: path).render()
        $(@el).find(".pathes").append new PathView(model: path).render()
      , 1
