{ resolve } = require 'path'

module.exports =

  NotifyView: require resolve __dirname, "notify"

  HttpServerView: require resolve __dirname, "http"

  LiveReloadView: require resolve __dirname, "livereload"

  BrowserView: require resolve __dirname, "browser"

  TerminalView: require resolve __dirname, "terminal"

  ShortcutsView: require resolve __dirname, "shortcuts"
