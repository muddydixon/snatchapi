"use strict"

path            = require "path"

gulp            = require "gulp"
coffee          = require "gulp-coffee"
plumber         = require "gulp-plumber"
util            = require "gulp-util"
less            = require "gulp-less"
connect         = require "gulp-connect"


# each task
gulp.task "coffee:server", ->
  gulp.src("./src-server/**/*.coffee")
  .pipe(plumber())
  .pipe(coffee({bare: true})).on("error", util.log)
  .pipe(gulp.dest("./server"))

gulp.task "coffee:client", ->
  gulp.src("./src-client/**/*.coffee")
  .pipe(plumber())
  .pipe(coffee({bare: true})).on("error", util.log)
  .pipe(gulp.dest("./public/js"))

gulp.task "coffee:bin", ->
  gulp.src("./src-bin/**/*.coffee")
  .pipe(plumber())
  .pipe(coffee({bare: true})).on("error", util.log)
  .pipe(gulp.dest("./bin"))

gulp.task "less", ->
  gulp.src("./src-client/asset/less/*.less")
  .pipe(plumber())
  .pipe(less()).on("error", util.log)
  .pipe(gulp.dest("./public/stylesheets"))

# watch task
gulp.task "watch:server", ->
  gulp.watch("./src-server/**/*.coffee", [ "coffee:server" ])

gulp.task "watch:client", ->
  gulp.watch(["./src-client/**/*.coffee", "./src-client/asset/less/*.less"], [ "coffee:client" , "less"])

gulp.task "watch", [ "watch:server", "watch:client" ]

# test
gulp.task "test" , ->

# default
gulp.task "build", [ "coffee:server", "coffee:client", "coffee:bin", "less" ]

gulp.task "default", ["build", "test"]
