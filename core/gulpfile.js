'use strict';

var gulp = require('gulp');
var autoprefixer = require('gulp-autoprefixer');
var cssnano = require('gulp-cssnano');
var debug  = require('gulp-debug');
var less = require('gulp-less');
var rename = require('gulp-rename');
var browserSync = require('browser-sync').create();

var path = {
	css: [
		'modules/v1/core_assets/css/mura.10.min.css'
	],
	less: [
		'modules/v1/core_assets/css/less/mura.10.less'
	],
	watch: "modules/v1/core_assets/css/less/**/*.less"
}

// Compile LESS task
gulp.task('less:compile', function () {
	return gulp
		.src(path.less, { sourcemaps: true })
		.pipe(debug({ title: 'Compiling:' }))
		.pipe(less())
		.pipe(rename({ suffix: '.min' }))
		.pipe(gulp.dest('modules/v1/core_assets/css/', { sourcemaps: '.' }))
		.pipe(browserSync.stream());
});

// Minify CSS task
gulp.task('css:minify', function () {
	return gulp
		.src(path.css)
		.pipe(debug({ title: 'Minifying:' }))
		.pipe(autoprefixer())
		.pipe(cssnano({ zindex: false }))
		.pipe(gulp.dest('modules/v1/core_assets/css/'));
});

// LESS task
gulp.task('less', gulp.series('less:compile', 'css:minify'));

// Watch task
gulp.task('watch', gulp.series('less:compile', function () {
	browserSync.init({ proxy: "localhost:8888" });
	gulp.watch(path.watch, { usePolling: true }, gulp.series('less:compile'));
}));

// Default task
gulp.task('default', gulp.series('watch'));
