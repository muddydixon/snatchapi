gulp            = require "gulp"
gutil           = require "gulp-util"
coffee          = require "gulp-coffee"
watch           = require "gulp-watch"

gulp.task "coffee", ->
  gulp.src("./src-server/**/*.coffee")
  .pipe(coffee({bare: true})).on("error", gutil.log)
  .pipe(gulp.dest("./server"))

  gulp.src("./src-client/**/*.coffee")
  .pipe(coffee({bare: true})).on("error", gutil.log)
  .pipe(gulp.dest("./public/js"))


gulp.task "default", ["coffee"]
gulp.task "watch", ->
  watch({glob: "./src-server/**/*.coffee"}, (files)->
    files.pipe(coffee({bare: true}))
      .pipe(gulp.dest("./server"))
  )
  watch({glob: "./src-client/**/*.coffee"}, (files)->
    files.pipe(coffee({bare: true}))
      .pipe(gulp.dest("./public/js"))
  )
