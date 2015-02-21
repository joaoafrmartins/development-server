{ createPane } = require './utils'

{ View, ScrollView, $ } = require 'atom'

class TestRunnerFrame extends ScrollView

  @content: (options) ->

    @iframe outlet: "frame", class: "browser-frame", src: options.uri, width: "100%", height: "100%"

module.exports =

  class TestRunnerView extends View

    @content: (options) ->

      @div class: 'status-stats inline-block', =>

        @a outlet: "label", click: "toggle"

    initialize: (@options={}) ->

      @attach()

      @options.view ?= TestRunnerFrame

    serialize: ->

      delete @options.view

      @options

    destroy: ->

      @detach()

    attach: ->

      @label.text "specs"

      statusbar = atom.workspaceView.statusBar

      statusbar.appendLeft @

    start: ->

      @browser = createPane @options, (err, el) =>

        if !err

          @label.text @options.uri

      , @stop.bind(@)

    stop: ->

      @browser = null

    toggle: () ->

      if arguments.length > 0

        if @browser

          @stop()

        else

          @start()
