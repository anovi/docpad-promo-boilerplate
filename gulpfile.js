var gulp       = require("gulp");
var rev        = require("gulp-rev");
var revReplace = require("gulp-rev-replace");
var useref     = require("gulp-useref");
var uglify     = require("gulp-uglify");
var minifyCss  = require("gulp-minify-css");
var gulpif     = require("gulp-if");
var htmlmin    = require("gulp-htmlmin");

var opt = {
  src: "out",
  dist: "out"
};



gulp.task("useref", function () {
  return gulp.src(opt.src + "/**/*.html")
    .pipe(useref({
      searchPath: './out'
    }))
    .pipe(gulpif("*.js", uglify()))
    .pipe(gulpif("*.css", minifyCss()))
    .pipe(gulp.dest(opt.dist));
});

gulp.task("revision", ["useref"], function(){
  return gulp.src([opt.src + "/**/*.css", opt.src + "/**/*.js"])
    .pipe(rev())
    .pipe(gulp.dest(opt.dist))
    .pipe(rev.manifest())
    .pipe(gulp.dest(opt.dist))
});

gulp.task("default", ["revision"], function(){
  var manifest = gulp.src("./" + opt.src + "/rev-manifest.json");

  return gulp.src(opt.src + "/**/*.html")
    .pipe(revReplace({manifest: manifest}))
    .pipe(htmlmin({collapseWhitespace: true}))
    .pipe(gulp.dest(opt.dist));
});