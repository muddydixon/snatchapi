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
        <a href='#'><li class='fa fa-pencil'></li></a>&nbsp;
        <a href='#'><li class='fa fa-trash-o'></li></a>
      </td>
      """
    render: ->
      $(@el).html @template @model
