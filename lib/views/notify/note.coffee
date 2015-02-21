Model = require './models/note'

{ View, $ } = require 'atom'

module.exports = class Note extends View

  @content: ->

    @article note: true, level: true, =>

      @legend title: true, =>

        @i outlet: "title", =>

        @i icon: true, =>

        @i close: true, =>

      @div envelope: true, =>

        @a message: true, outlet: "message", =>

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

    level: @model.level

    title: @model.title

    message: @model.message

    href: @model.href

    target: @model.target

  initialize: (state) ->

    Object.defineProperty @, "uuid", value: Note.uuid()

    state.uuid ?= @uuid

    state.target ?= "_blank"

    @model = new Model state

    Model.eventHandler @, @model

    @attr "note", @uuid

    { level, title, message, href, target } = @model

    level ?= "info"

    title ?= level

    if level then @attr "level", level

    if title then @title.text title

    if message then @message.text message

    if href then @message.attr "href", href

    if target then @message.attr "target", target
