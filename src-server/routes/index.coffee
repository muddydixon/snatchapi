"use strict"

appInfo         = require "../../package.json"
config          = require "config"
Url             = require "url"
deferred        = require "deferred"
Series          = require "series.js"

Origin          = require "../model/origin"
Path            = require "../model/path"

{overwrite}     = require "../utils"

#
# ## index
#
index =
  get: (req, res) ->
    res.sendfile "public/index.html"

# routes
routes = overwrite(
  {"/":         index}
  {"/testapi":  require "./testapi"}
  require "./api/path-routes"
  require "./api/origin-routes"
)

# routing
module.exports = (app) ->
  for route, methods of routes
    for method, handler of methods
      app[method] route, handler
