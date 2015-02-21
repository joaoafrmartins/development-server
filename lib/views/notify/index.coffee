{ View, $ } = require 'atom'

Note = require './note'

Model = require './models/notify'

merge = require 'lodash.merge'

module.exports = class Notify extends View

  @content: ->

    @div notify: true, vertical: false, horizontal: false, =>

      @div notes: true, outlet: "notes", =>

  @uuid: ->

    uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    uuid.replace(/[xy]/g,

        (c) ->
          r = Math.random() * 16 | 0
          v = if c is 'x' then r else (r & 0x3|0x8)
          v.toString(16)
    )

  destroy: ->

    delete @model

    @detach()

  serialize: ->

    global: @model.global

    uuid: @model.uuid

    alias: @model.alias

    vertical: @model.vertical

    horizontal: @model.horizontal

    animation: @model.animation

    timeout: @model.timeout

    timelapse: @model.timelapse

    notes: @model.notes.map (n) -> n.serialize()

    levels: @model.levels

  initialize: (state={}) ->

    Object.defineProperty @, "uuid", value: Notify.uuid()

    state.timeout ?= 5000

    state.timelapse ?= 750

    state.animation ?= "notify"

    state.uuid ?= @uuid

    state.vertical ?= "top"

    state.horizontal ?= "right"

    state.global ?= false

    state.alias ?= "console"

    state.levels ?= ["error", "warning", "info", "success"]

    @model = new Model state

    Model.eventHandler @, @model

    @attr "notify", @uuid

    @attr "vertical", @model.vertical

    @attr "horizontal", @model.horizontal

    @attach()

    printer = undefined

    if @model.global

      alias = @model.alias or "notify"

      printer = global[alias]

    printer ?= @

    @model.levels.map (l) =>

      if state.debug and l of printer

        _l = printer[l].bind printer

      printer[l] = (

        (m, o={}) ->

          o.message = m

          o.level ?= @level

          @notify o

          if state.debug and @log then @log m

      ).bind(level: l, log: _l, notify: @notify.bind(@))

  attach: ->

    @parentElement ?= atom.workspaceView

    @parentElement = $ @parentElement

    @parentElement.prepend @

    Object.defineProperty @, "queue", value: []

  notify: (note) ->

    @queue.push note

    return unless @queue.length is 1

    @interval = setInterval () =>

      if n = @queue.shift()

        $note = new Note n

        @notes.prepend $note.hide().

          fadeIn(@model.timeout * 0.1).

          delay(@model.timeout * 0.7).

          fadeOut(@model.timeout * 0.2).destroy()

        setTimeout () ->

          $note.remove()

        , @model.timeout

      if not @queue.length then clearInterval @interval

    , @model.timelapse
