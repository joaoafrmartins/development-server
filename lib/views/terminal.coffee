{ ScrollView, View, $ } = require 'atom'

{ createPane } = require './utils'

debounce = require 'lodash.debounce'

pty = require 'pty.js'

TermJS = require 'term.js'

class TerminalFrame extends ScrollView

  @content: (uri) ->

    @div outlet: "terminal"

  initialize: (@options={}) ->

    @start()

  getDimensions: () ->

    colSize = (if @term then @find('.terminal').width() / @term.cols else 7) # default is 7

    rowSize = (if @term then @find('.terminal').height() / @term.rows else 15) # default is 15

    @dims =

      cols: @width() / colSize | 0

      rows: @height() / rowSize | 0

  resizeToPane: () =>

    @getDimensions()

    if @term.rows is @dims.rows and @term.cols is @dims.cols then return

    @pty.resize @dims.cols, @dims.rows

    @term.resize @dims.cols, @dims.rows

  attachEvents: () ->

    @resizeToPane = @resizeToPane.bind @

    @attachResizeEvents()

  attachResizeEvents: () ->

    setTimeout @resizeToPane, 20

    @on "focus", @resizeToPane

    @resizeInterval = setInterval @resizeToPane, 100

    window.onresize = debounce(@resizeToPane, 20)

  detachResizeEvents: () ->

    @off "focus", @resizeToPane

    clearInterval @resizeInterval

  start: () ->

    @getDimensions()

    @pty = pty.spawn @options.shell, [],

      name: "xterm-color"

      cols: @dims.cols

      rows: @dims.rows

      cwd: @options.cwd

      env: process.env

    @term = new TermJS

      cols: @dims.cols

      rows: @dims.rows

      useStyle: true

      screenKeys: true

    @term.on "data", @pty.write.bind(@pty)

    @term.open @[0]

    @pty.pipe @term

    @term.end = @stop.bind @

    @term.focus()

    @attachEvents()

    window.term = @term

    window.pty = @pty

  stop: () ->

    @detachResizeEvents()

    @pty.destroy()

    @pty = null

    @term.destroy()

    @term = null

    @detach()

class TerminalView extends View

  @content: (options) ->

    @div class: 'status-stats inline-block development-server', =>

      @a outlet: "label", click: "start"

  uuid: ->

    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r & 0x3|0x8)
      v.toString(16)
    )

  initialize: (@options={}) ->

    @label.text "terminal"

    @options.view = TerminalFrame

    @terminals = []

    { defineProperty, keys } = Object

    if !@hasOwnProperty "terminal"

      defineProperty @, "terminal",

        get: ->

          if @terminals.length > 0

            return @terminals[@terminals.length - 1]

          return false

    @attach()

  serialize: ->

    delete @options.view

    delete @options.env

    @options

  destroy: ->

    @detach()

  attach: ->

    statusbar = atom.workspaceView.statusBar

    statusbar.appendLeft @

  start: ->

    createPane @options, (err, el) =>

      if !err

        #@label.text @options.uri

        @terminals.push el

    , @stop.bind(@)

  stop: ->

  toggle: ->


module.exports = TerminalView
