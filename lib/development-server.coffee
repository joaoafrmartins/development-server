Views = require './views'

{ keys } = Object

{ ScrollView } = require 'atom'

require 'shelljs/global'

merge = require 'lodash.merge'

{ join, resolve } = require 'path'

module.exports =

  activate: (state={}) ->

    state.root ?= atom.project.getPath() or process.env.HOME

    state.rcfile ?= join state.root, ".developmentserverrc"

    state.views ?=

      NotifyView: "notify"

      HttpServerView: "http"

      LiveReloadView: "livereload"

      BrowserView: "browser"

      TerminalView: "terminal"

      ShortcutsView: "shortcuts"

    state.livereload ?=

        root: atom.project.getPath()

        port: 35729

        timeout: 1000

    state.http ?=

        root: atom.project.getPath()

        port: 8080

        timeout: 1000

        snippet: """

          <!-- livereload snippet -->

          <script src="http://localhost:#{state.livereload.port}/livereload.js"></script>

        """

    state.specs ?=

      root: 'specs.html'

    state.browser ?=

      tabs: [
        {
          split: "right",
          title: "Preview",
          changeFocus: false,
          searchAllPanes: true,
          uri: "http://localhost:#{state.http.port}"
        },
        {
          split: "right",
          title: "Specs",
          changeFocus: false,
          searchAllPanes: true,
          uri: "http://localhost:#{state.http.port}/#{state.specs.root}"
        }
      ]

    state.terminal ?=

      title: "Terminal"

      split: "right"

      searchAllPanes: true

      changeFocus: false

      cwd: atom.project.getPath() or process.env.HOME

      shell: process.env.SHELL or "bash"

    pkg = resolve state.terminal.cwd, "package.json"


    save = undefined

    actions = undefined

    if test "-f", pkg

      pkg = JSON.parse cat pkg

      { scripts } = pkg

      { keys } = Object

      actions = {}

      npm = keys(scripts or {})

      npm.map (script) ->

        actions[script] = "npm run #{script}"

    state.shortcuts ?=

      subscriptions:

        "core:save": []

      actions: actions or build: "npm run build"

    state.notify ?=

      timeout: 5000

      timelapse: 750

      animation: "notify"

      vertical: "top"

      horizontal: "right"

      global: true

      alias: "console"

      levels: ["error", "warning", "info", "success"]

    if not test "-e", state.rcfile

      JSON.stringify(state, null, 2).to state.rcfile

    try

      @state = JSON.parse cat state.rcfile

      @state = merge state, @state

      keys(Views).map (view) =>

        name = @state.views[view]

        if not @state[name].disabled

          @[view] = new Views[view] @state[name] || { root: atom.project.getPath() }

          @[view].package = @

      @toggle()

    catch err

      console.log err.message, err.stack

  deactivate: ->

    keys(Views).map (view) =>

      @[view].destroy()

  serialize: ->

    state = {}

    #keys(Views).map (name) =>

    #  state[name] = @[name].serialize()

    #return state

  toggle: ->

    keys(Views).map (view) =>

      @[view]?.toggle()
