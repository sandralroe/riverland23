// var path = require('path');
var gulp = require('gulp');
var sass = require('gulp-sass')(require('sass'));
var autoprefixer = require('gulp-autoprefixer');
var cssnano = require('gulp-cssnano');
var rename = require('gulp-rename');

gulp.task('default', function(done) {
    gulp.series('matrix_selector');
    done();
});

// gulp.task('watch', function() {
// 	gulp.watch('scss/**/*.scss', ['scss-theme']);
// });

gulp.task('matrix_selector', function(done) {
	gulp.src('./assets/scss/matrix_selector.scss')
		.pipe(sass().on('error', sass.logError))
		.pipe(autoprefixer({
			browsers: ['last 2 versions'],
			cascade: false
		}))
		.pipe(cssnano({zindex: false}))
		.pipe(rename('matrix_selector.min.css'))
		.pipe(gulp.dest('./assets/css/'));
        done();
});

function swallowError (error) {
	console.log(error.toString());
	this.emit('end');
}
