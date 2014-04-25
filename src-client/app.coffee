define (require)->
  "use strict"

  class Origin extends Backbone.Model
    default:
      origin: ""
      pathes: []
    initialize: ->
      @set 'pathes', new Pathes(@get 'pathes')

  class Origins extends Backbone.Collection
    model:      Origin
    url:        "/data"
    parse:      (res)->
      res.data

  class Path extends Backbone.Model
    default:
      path:     ""
      method:   "GET"
      status:   "Normal"
      comment:  ""
      request:  undefined
      response: undefined
    initialize: ->

  class Pathes extends Backbone.Collection
    model: Path

  class PathView extends Backbone.View
    tagName: "tr"
    className: "path"
    template: (path)->
      """
      <td>#{path.get 'path'}</td>
      <td>#{path.get 'method'}</td>
      <td>
        <span class='label #{if path.get('status') is 'Normal' then 'label-success' else 'label-danger'}'>#{path.get 'status'}</span></td>
      <td>#{path.get 'comment'}</td>
      <td class='text-right'>
        <a href='#'><li class='fa fa-pencil'></li></a>&nbsp;
        <a href='#'><li class='fa fa-trash-o'></li></a>
      </td>
      """
    render: ->
      $(@el).html @template @model

  class OriginView extends Backbone.View
    template: (origin)->
      """
      <div class='row text-origin'>
        <div class='col-md-11'>
          <h1>#{origin.get 'origin'}</h1>
        </div>
        <div class='col-md-1 text-right'>
          <a href='#'><i class='fa fa-plus-square fa-lg'></i></a>
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
    tagName: "div"
    className: "origin"
    initialize: ->
      # @collection.bind "add", @appendItem

    render: ->
      $(@el).html @template @model
      @model.get("pathes").each (path)=>
        $(@el).find(".pathes").append new PathView(model: path).render()
      @el

  class AppView extends Backbone.View
    el: $ "#app"
    container: '.origins'
    Collection: Origins
    initialize: ->
      @collection = new @Collection
      @collection.bind "add", @appendItem

      @collection.fetch()

      @render()

    render: ->
      $(@el).append '<div class="container origins"></div>'
      @collection.each (origin)=>
        $(@container).append new OriginView(model: origin).render()

    appendItem: (origin)=>
      $(@container).append new OriginView(model: origin).render()



  appView = new AppView()
