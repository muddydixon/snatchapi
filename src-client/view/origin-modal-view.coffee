define (require)->
  "use strict"

  Origin        = require "../model/origin"

  class OriginModalView extends Backbone.View
    container:          "#body"
    tagName:            "div"
    attributes:
      class:            "modal fade"
      id:               "create-origin"
    template: (model)->
      """
        <div class='modal-dialog'>
          <div class='modal-content'>
            <div class='modal-header'>
              <button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button>
              <h4 class='modal-title'>Add Origin</h4>
            </div>
            <form>
              <div class='modal-body'>
                <div class='input-group'>
                  <span class='input-group-addon'>origin</span>
                  <input type='text' class='form-control' name='origin' placeholder='http://example.com'>
                </div>
                <br/>
                <div class='input-group'>
                  <span class='input-group-addon'>proxy</span>
                  <input type='text' class='form-control' name='proxy' placeholder='http://proxy.example.com:8080'>
                </div>
              </div>
              <div class='modal-footer'>
                <button type='button' class='btn submit btn-default' data-dismiss='modal'>Close</button>
                <input type='submit' class='submit btn btn-primary' value='Save changes'/>
              </div>
            </form>
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
      origin = $(@el).find("form [name=origin]").val()
      proxy  = $(@el).find("form [name=proxy]").val()

      origin = new Origin(origin: origin, proxy: proxy)
      origin.save().then (res)=>
        @collection.add new @Model(res.data)
        $(@el).modal("hide")
      , (err)->
        console.log err
