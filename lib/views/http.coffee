{ View, $ } = require 'atom'

{ join } = require 'path'

{ createServer } = require 'http'

{ parse } = require 'url'

{ exists, statSync, readFile} = require 'fs'

merge = require 'lodash.merge'

module.exports =

  class HttpServerView extends View

    @content: (options) ->

      @div class: 'status-stats inline-block development-server', =>

        @a outlet: "label", click: "toggle"

    initialize: (@options={}) ->

      @attach()

    serialize: ->

      @options

    destroy: ->

      @detach()

    attach: ->

      statusbar = atom.workspaceView.statusBar

      statusbar.prependLeft @

    start: () ->

      { root, port } = @options

      @server = createServer (req, res) =>

        uri = parse(req.url).pathname

        filename = join root, uri

        headers =

          "Access-Control-Allow-Origin": "*",

          "Access-Control-Allow-Headers": "X-Requested-With"

        exists filename, (exists) =>

          if !exists
            res.writeHead 404, headers
            res.write("404 Not Found\n")
            res.end()

            return

          if statSync(filename).isDirectory()

            filename += 'index.html';

          readFile filename, "binary", (err, file) =>

            if err
              res.writeHead 500, headers
              res.write(err + "\n")
              res.end()
              return

            if filename.match /\.html$/

              headers["Content-Type"] = "text/html"

              res.writeHead 200, headers

              html = file.toString("utf-8").replace /<\/body>/, (w) =>

                return @options.snippet + w;

              res.end html

            else

              res.write(file, "binary")

              res.end()

      @server.on 'error', (err) =>

        if err.code == 'EADDRINUSE'

          ++@options.port

          try @server.close()

          @server = null

          setTimeout @start.bind(@), @options.timeout

          @options.timeout += 1000

      @server.on 'listening', () =>

        root = @options.root

        port = @options.port

        href = "http://localhost:#{port}"

        console.info "http started on port #{port}!"

        @label.text(href).

        attr("style", "color: green !important;")

      .listen port

    stop: (next) ->

      @server.close () =>

        console.info "http stopped!"

        @label.text('http: stopped').

        removeAttr('href').

        attr("style", "color: orange !important;")

        @server = null

        if typeof next == "function" then next()

    restart: () ->

      @stop @start.bind @

    toggle: () ->

      if not @server

        @start()

      else

        @stop()
