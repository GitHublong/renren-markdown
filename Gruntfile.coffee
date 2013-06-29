module.exports = (grunt) ->
  'use strict'


  ############
  # plugins

  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'


  ############
  # iced-coffee-script

  grunt.registerMultiTask 'iced', 'Compile IcedCoffeeScript files into JavaScript', ->
    path = require('path')
    options = @options(
      bare: false
      separator: grunt.util.linefeed
    )
    grunt.fail.warn 'Experimental destination wildcards are no longer supported. please refer to README.'   if options.basePath or options.flatten
    grunt.verbose.writeflags options, 'Options'
    @files.forEach (f) ->
      output = f.src.filter((filepath) ->
        if grunt.file.exists(filepath)
          true
        else
          grunt.log.warn 'Source file \'' + filepath + '\' not found.'
          false
      ).map((filepath) ->
        compileCoffee filepath, options
      ).join(grunt.util.normalizelf(options.separator))
      if output.length < 1
        grunt.log.warn 'Destination not written because compiled files were empty.'
      else
        grunt.file.write f.dest, output
        grunt.log.writeln 'File ' + f.dest + ' created.'

  compileCoffee = (srcFile, options) ->
    options = grunt.util._.extend filename: srcFile, options
    srcCode = grunt.file.read srcFile
    try
      return require('iced-coffee-script').compile srcCode, options
    catch e
      grunt.log.error e
      grunt.fail.warn 'CoffeeScript failed to compile.'


  ############
  # css2js

  grunt.registerMultiTask 'css2js', 'wrap css into js', ->
    css=grunt.file.read(@data.src, encoding: 'utf-8')
    js=";var #{@data.name}=#{JSON.stringify(css)};\n"
    grunt.file.write(@data.dest, js, encoding: 'utf-8')

  grunt.registerMultiTask 'pack', 'pack text files into JSON', ->
    path = require 'path'
    for x in @files
      o = {}
      for f in x.src
        name = path.basename f
        cont = grunt.file.read f, encoding: 'utf-8'
        o[name] = cont
      grunt.file.write x.dest, JSON.stringify(o), encoding: 'utf-8'

  ############
  # template

  grunt.registerMultiTask 'template', ->
    for file in @files
      src=file.src[0]
      dest=file.dest
      cont=grunt.template.process grunt.file.read(src, encoding: 'utf-8')
      cont=cont.replace(/\r\n/g, '\n')
      grunt.file.write(dest, cont, encoding: 'utf-8')


  ############
  # setenv
  grunt.registerMultiTask 'setenv', ->
    grunt.config.set 'window', @data


  ############
  # main config

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    iced:
      all:
        options:
          runtime: 'inline'
        files: [
          {
            expand: true
            cwd: 'src'
            src: ['**/*.iced']
            dest: 'build/iced'
            ext: '.js'
          }
        ]

    uglify:
      options:
        preserveComments: 'some'
      lib:
        files: [
          {
            expand: true
            cwd: 'lib/'
            src: ['*.js']
            dest: 'build/lib/'
            ext: '.min.js'
          }
        ]

    cssmin:
      markdown:
        files:
          'build/markdown.min.css': ['src/markdown.css']

    css2js:
      markdown:
        name: 'MARKDOWN_CSS'
        src: 'build/markdown.min.css'
        dest: 'build/markdown.min.css.js'

    pack:
      test:
        files: [
          {
            src: 'src/chrome/*'
            dest: 'build/pack.js'
          }
        ]

    concat:
      lib: # all minified libraries
        src: 'build/lib/*.js'
        dest: 'build/lib.js'
      main: # common code (without compatibility layer)
        src: [
          'build/lib.js'
          'build/markdown.min.css.js'
          'src/emoticon.js' # TODO: auto emoticon.js
          'build/iced/renren-markdown.js'
        ]
        dest: 'build/renren-markdown.main.js'
      chrome:
        src: [
          'build/iced/chrome/env.js'
          'build/renren-markdown.main.js'
        ]
        dest: 'dist/chrome/js/renren-markdown.chrome.js'
      gm:
        src: [
          'build/metadata.js'
          'build/iced/gm/env.js'
          'build/renren-markdown.main.js'
        ]
        dest: 'dist/gm/renren-markdown.user.js'

    copy:
      chrome:
        files: [
          {src: 'build/iced/chrome/inject.js', dest: 'dist/chrome/js/inject.js'}
          {src: 'assets/icon.png', dest: 'dist/chrome/img/icon.png'}
        ]

    template: # for metadata
      chrome:
        files: [
          {src: 'src/chrome/manifest.json', dest: 'dist/chrome/manifest.json'}
        ]
      gm:
        files: [
          {src: 'src/gm/metadata.js', dest: 'build/metadata.js'}
        ]

    clean:
      build: ['build/*']
      release: ['dist/*']


  grunt.registerTask 'lib', [
    'uglify:lib'
    'concat:lib'
  ]

  grunt.registerTask 'css', [
    'cssmin:markdown'
    'css2js:markdown'
  ]

  grunt.registerTask 'prepare', [
    'lib'
    'css'
  ]

  grunt.registerTask 'compile', [
    'iced:all'
    'concat:main'
  ]

  grunt.registerTask 'chrome', [
    'template:chrome'
    'copy:chrome'
    'concat:chrome'
  ]

  grunt.registerTask 'gm', [
    'template:gm'
    'concat:gm'
  ]

  grunt.registerTask 'default', [
    'compile'
    'chrome'
    'gm'
  ]
