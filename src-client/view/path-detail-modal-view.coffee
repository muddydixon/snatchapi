define (require)->
  "use strict"

  Path = require "../model/path"

  class PathDetailModalView extends Backbone.View
    container:          "#body"
    tagName:            "div"
    attributes:
      class:            "modal fade"
      id:               "detail-request"
    template: (model)->
      """
        <div class='modal-dialog'>
          <div class='modal-content large'>
            <div class='modal-header'>
              <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
              <h4 class='modal-title'>Request Detail</h4>
            </div>
            <input type='hidden' name='origin'>
            <div class='modal-body'>
              <div class='row'>
                <div class='col-md-2'>
                  <select name='status' class='form-control'>
                    <option>Normal</option>
                    <option>Abnormal</option>
                  </select>
                </div>
                <div class='col-md-2'>
                  <select name='method' class='form-control'>
                    <option>GET</option>
                    <option>POST</option>
                    <option>PUT</option>
                    <option>DELETE</option>
                  </select>
                </div>
                <div class='col-md-8'>
                  <div class='input-group'>
                    <span class='input-group-addon'>path</span>
                    <input type='text' class='form-control' name='path' placeholder='/api'>
                  </div>
                </div>
              </div>
              <br/>
              <div class='row'>
                <div class='col-md-6'>
                  <textarea class='form-control' rows='6' name='header' placeholder='request header'></textarea>
                </div>
                <div class='col-md-6'>
                  <textarea class='form-control' rows='6' name='body' placeholder='request body'></textarea>
                </div>
                <br/>
              </div>
              <br/>
              <textarea class='form-control' rows='3' name='comment' placeholder='comment'></textarea>
            </div>
            <div class='modal-footer'>
              <button type='button' class='btn btn-default' data-dismiss='modal'>Close</button>
              <input type='submit' class='submit btn btn-primary' value='Save Request'/>
            </div>
          </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
      """

    initialize: (@Model, @collection)->

    render: ()->
      $(@container).append $(@el).html @template()

    events:
      "submit form": "submit"

    submit: (ev)->
      ev.preventDefault()
      origin    = $(@el).find("form [name=origin]").val()
      path      = $(@el).find("form [name=path]").val()
      method    = $(@el).find("form [name=method]").val()
      status    = $(@el).find("form [name=status]").val()
      header    = $(@el).find("form [name=header]").val()
      body      = $(@el).find("form [name=body]").val()
      comment   = $(@el).find("form [name=comment]").val()

      path      = new Path({origin, path, method, status, request: {header, body}, comment})
      console.log path
      console.log @collection
      console.log @el
      path.save().then (res)=>
        @collection.add new @Model(res.data)
        $(@el).modal("hide")
      , (err)->
        console.log err
