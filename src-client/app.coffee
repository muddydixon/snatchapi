define (require)->
  "use strict"

  AppView = require "./view/app-view"
  window.appView = new AppView().render()
