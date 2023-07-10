module.exports = function(grunt) {

  grunt.initConfig({
      handlebars: {
          all: {
              files: {
                  'js/src/templates.js': ['js/src/templates/*.hbs']
              },
              options: {
                   namespace: 'templates',
                   processName: function(filePath) {
                    var name=filePath.split('/');
                    name=name[name.length-1];
                    name=name.split('.');
                    return name[0].toLowerCase();
                    }
              }
          }
      },
      replace: {
        prevent_templates_example: {
                src: ['js/src/templates.js'],
                dest: 'js/src/templates.js',
                options: {
                  processTemplates: false
                },
                replacements: [{
                      from: 'Handlebars',
                      to: function () {
                        return "window.Mura.Handlebars";
                      }
                }]
            }
        },
    concat: {
          options: {
            separator: ';',
            banner: 'Mura.preInit(function(){',
            footer: 'Mura.DisplayObject.Cta=Mura.DisplayObject.Cta.extend({templates:this.templates});});',
          },
          dist: {
            src: [
            'js/src/templates.js',
            'js/src/mura.displayobject.cta.js'
            ],
            dest: 'js/mura.displayobject.cta.js',
          },
    },
    uglify: {
      my_target: {
        files: {
          'js/mura.displayobject.cta.min.js': ['js/mura.displayobject.cta.js']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-text-replace');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-handlebars');
  grunt.registerTask('default',['handlebars','replace','concat','uglify']);


};
