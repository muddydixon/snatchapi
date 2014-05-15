define (require)->
  "use strict"

  class PathView extends Backbone.View
    tagName: "div"
    container: "pathes"
    className: "path"
    template: (path)->
      """
      <div class='row'>
        <div class='col-md-1'>
          <a href='#' class='detail'><i class='fa fa-chevron-down'></i></a>&nbsp;
        </div>
        <div class='col-md-4'>#{path.get 'path'}</div>
        <div class='col-md-1'>#{path.get 'method'}</div>
        <div class='col-md-1'>
          <span class='label #{if path.get('status') is 'Normal' then 'label-success' else 'label-danger'}'>#{path.get 'status'}</span>
        </div>
        <div class='col-md-4'>#{path.get('comment') or ''}</div>
        <div class='col-md-1 text-right'>
          <a href='#' class='edit'><i class='fa fa-gear'></i></a>&nbsp;
          <a href='#' class='delete'><i class='fa fa-trash-o'></i></a>
        </div>
      </div>

      <div class='detail' style='margin-top: 5px; display: none;'>
        <div class='row headers'>
          <div class='col-md-6'>
            <table class='table'>
              <tr><th class='text-center' colspan='2'>request header</th></tr>
              """ +
              (for k, v of (path.get('request').header or {})
                "<tr><td>#{k}</td><td class='word-break'>#{v}</td></tr>"
              ).join("\n") +
              """
           </table>
         </div>
         <div class='col-md-6'>
           <table class='table'>
             <tr><th class='text-center' colspan='2'>response header</th></tr>
              """ +
              (for k, v of (path.get('response').header or {})
                "<tr><td>#{k}</td><td class='word-break'>#{v}</td></tr>"
              ).join("\n") +
              """
            </table>
          </div>
        </div>
        <div class='row bodies'>
          <div class='col-md-6'>
            <h5 class='text-center'>request body</h5>
            <textarea class='col-md-12' rows='6'>""" +
              (try
                JSON.stringify(path.get('request').body)
              catch err
                path.get('request').body
              ).replace(/^[\s]*|[\s]*$/mg, '') +
            """
            </textarea>
          </div>
          <div class='col-md-6'>
            <h5 class='text-center'>response body</h5>
            <textarea class='col-md-12' rows='6'>""" +
              (try
                JSON.stringify(path.get('response').body)
              catch err
                path.get('response').body
              ).replace(/^[\s]*|[\s]*$/mg, '') +
            """
            </textarea>
          </div>
        </div>
      </div>
      """
    render: ->
      $(@el).html @template @model
      $(@el)

    events:
      "click a.delete": ()->
        @model.destroy()
        .then((res)=>
          @$el.remove()
        , (err)->
          console.log err
        )
      "click a.detail": ()->
        $(@el).find("a.detail i").toggleClass("fa-chevron-down").toggleClass("fa-chevron-up")
        $(@el).find("div.detail").slideToggle()
      "click a.edit": ()->
