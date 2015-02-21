{ createPane } = require './utils'

{ View, ScrollView, $ } = require 'atom'

class BrowserFrame extends ScrollView

  @content: (options) ->

    @iframe outlet: "frame", class: "browser-frame", src: options.uri, width: "100%", height: "100%"

module.exports =

  class BrowserView extends View

    @content: (options) ->

      @div class: 'status-stats inline-block development-server', =>

    initialize: (@options={}) ->

      self = @

      @options.tabs ?= []

      @start()

      @options.tabs.map (tab, idx) =>

        $anchor = $ document.createElement "a"

        $anchor.attr "idx", idx

        $anchor.text tab.title

        $anchor.css "padding-right", "5px"

        $anchor.click (e) ->

          idx = $(e.target).closest("[idx]").attr("idx")

          if typeof self.tabs[idx] is "function"

            self.tabs[idx] = self.tabs[idx]()

          else

            self.tabs[idx]

        @append $anchor

      @attach()

      @toggle()

    serialize: ->

      delete @options.view

      @options

    destroy: ->

      @detach()

    attach: ->

      statusbar = atom.workspaceView.statusBar

      statusbar.appendLeft @

    start: ->

      @tabs ?= []

      @options.tabs.map (tab, idx) =>

        tab.view ?= BrowserFrame

        @tabs.push ( () => createPane( tab, (err, el) =>

          if !err

            @find("[idx=#{idx}]").text tab.url

        , @stop.bind(@) ) )

    stop: ->

      @options.tabs.map (tab, idx) =>

        tab?.remove()
        tab?.destroy()
        tab = null

      delete @tabs
