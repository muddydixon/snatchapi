define (require)->
  "use strict"

  Pathes        = require "../model/pathes"
  PathView      = require "./path-view"
  View          = require "./base-view"

  class OriginView extends View
    container: ".origins"
    tagName: "div"
    attributes:
      class: "origin"
    template: (origin)->
      """
      <div class='row header'>
        <div class='col-md-1'>
          <a href='http://localhost:#{origin.get('port')}'>dummy</a>
        </div>
        <div class='col-md-8'>
          <h1>#{origin.get 'origin'}</h1>
        </div>
        <div class='col-md-2 text-right'>
          <a href='#' data-toggle='modal' data-target='#create-path'>
            <i class='fa fa-plus-square fa-lg'></i>
          </a>&nbsp;
          <a href='#' data-toggle='modal' data-target='#edit-origin'>
            <i class='fa fa-gear fa-lg'></i>
          </a>&nbsp;
          <a href='#' class='delete-origin'>
            <i class='fa fa-trash-o fa-lg'></i>
          </a>
        </div>
      </div>
      <div class='pathes'></div>
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
      @$().append @$el.html(@template @model).attr(id: @model.id)
      @el

    events:
      "click [data-target='#create-path']":   "callPathModal"
      "click [data-target='#edit-origin']":      "callOriginModal"
      "click .delete-origin":    ()->

        @model.destroy()
        .then((res)=>
          @$el.remove()
        , (err)->
          console.log err
        )

    callPathModal: ()=>
      $("#create-path [name='origin']").val(@model.get "origin")
      @pathModalView.collection = @collection

    callOriginModal: ()->
      $("#create-origin")
        .find("[name='origin']").val(@model.get "origin")
        .end()
        .find("[name='proxy']").val(@model.get "proxy")
        .end()
        .find("[name='port']").val(@model.get "port")
        .end()
        .modal("show")

    appendItem: (path)=>
      setTimeout ()=>
        pathEl = new PathView(model: path).render()
        @$(".pathes").append new PathView(model: path).render()
      , 1
