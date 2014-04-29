define (require)->
  "use strict"

  class PathView extends Backbone.View
    tagName: "tr"
    className: "path"
    template: (path)->
      """
      <td>#{path.get 'path'}</td>
      <td>#{path.get 'method'}</td>
      <td>
        <span class='label #{if path.get('status') is 'Normal' then 'label-success' else 'label-danger'}'>#{path.get 'status'}</span></td>
      <td>#{path.get('comment') or ''}</td>
      <td class='text-right'>
        <a href='#' class='detail'><i class='fa fa-table'></i></a>&nbsp;
        <a href='#' class='edit'><i class='fa fa-gear'></i></a>&nbsp;
        <a href='#' class='delete'><i class='fa fa-trash-o'></i></a>
      </td>
      """
    render: ->
      $(@el).html @template @model
      $(@el)

    events:
      "click .delete": ()->
        @model.destroy()
        .then((res)=>
          $(@el).remove()
        , (err)->
          console.log err
        )
      "click .detail": ()->
        console.log @model
      "click .edit": ()->
