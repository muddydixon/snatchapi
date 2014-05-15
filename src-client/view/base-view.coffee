define (require)->
  "use strict"

  class View extends Backbone.View
    $: (query)-> if query then $(@el).find query else $(@container)
    $el: $(@el)
