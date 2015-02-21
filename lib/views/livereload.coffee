{ View, $ } = require 'atom'

livereload = require 'livereload'

merge = require 'lodash.merge'

module.exports =

  class LiveReloadView extends View

    @content: (options) ->

      @div class: 'status-stats inline-block development-server', =>

        @a outlet: "label", click: "toggle"

    initialize: (@options={}) ->

      @options = merge

        root: atom.project.getPath()

        port: 35729

        timeout: 1000

      , @options

      @attach()

    serialize: ->

      @options

    destroy: ->

      @detach()

    attach: ->

      statusbar = atom.workspaceView.statusBar

      statusbar.prependLeft @

    start: () ->

      @server ?= livereload.createServer(@options)

      @server.config.server.on 'error', (err) =>

        console.error err.message

        if err.code == 'EADDRINUSE'

          ++@options.port

          try @server.server.close () =>

            setTimeout @start.bind(@), @options.timeout

            @options.timeout += 1000

            @server = null


      @server.config.server.on 'listening', () =>

        port = @options.port

        console.info "livereload started on port #{port}!"

        @label.text("livereload: #{port}").

        attr("style", "color: green !important;")

        if root = @options.root

          @server.watch root

    stop: (next) ->

      @server.config.server.close () =>

        console.info "livereload stopped!"

        @label.text('livereload: stopped').

        attr("style", "color: orange !important;").

        removeAttr('href')

        @server = null

        if typeof next == "function" then next()

    restart: () ->

      @stop @start.bind @

    toggle: () ->

      if not @server then @start() else @stop()
