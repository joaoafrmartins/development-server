{ View, $ } = require 'atom'

debounce = require 'lodash.debounce'

class Autobuild extends View

  @content: () ->

    @div class: 'status-stats inline-block development-server', =>

      @div class: 'btn-group btn-group-sm', =>

        @a outlet: "label", click: "toggleBuild", "autobuild"

  toggleBuild: ->

    @enabled = !!!@enabled

    if @enabled

      @label.attr "style", "color: green !important;"

    else

      @label.attr "style", "color: orange !important;"

  initialize: ->

    statusbar = atom.workspaceView.statusBar

    statusbar.appendLeft @

module.exports = class ShortcutsView extends View

  @content: (options) ->

    { keys } = Object

    actions = keys options.actions || {}

    @div class: 'status-stats inline-block development-server', =>

      @div class: 'btn-group btn-group-sm', =>

        if actions.length > 0

          actions.map (action) => @a(

            class: "btn btn-primary",

            action: action,

            outlet: action,

            click: "exec",

            action

          )

  serialize: ->

    @options

  initialize: (@options={}) ->

    @attach()

    { keys } = Object

    { subscriptions } = @options

    keys(subscriptions).map (e) =>

      atom.workspaceView.command e, =>

        subscriptions[e].map (a) =>

          if @autobuild.enabled

            @find("[action='#{a}']").trigger "click"

  destroy: ->

    @autobuild.detach()

    @detach()

  attach: ->

    statusbar = atom.workspaceView.statusBar

    statusbar.prependRight @

    @autobuild = new Autobuild

    @autobuild.enabled = @options?.autobuild

    @autobuild.enabled ?= false

    @autobuild.toggleBuild()

  exec: (e) ->

    action = $(e.target).attr("action")

    command = @options.actions[action]

    _exec = debounce () =>

      terminal = @package.TerminalView.terminal.term

      terminal.emit "data", command + "\n"

    , 250

    if not @package.TerminalView.terminal

      @package.TerminalView.label.trigger "click"

      @package.BrowserView.label.trigger "click"

      return setTimeout _exec.bind(@), 250

    _exec()

  toggle: ->
