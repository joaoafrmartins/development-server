{ ScrollView } = require 'atom'

url = require 'url'

generateTargetURI = ->
  "generated-atom-panel://" + Math.random().toString(36) + Date.now().toString(36)


cache = {}
uris = undefined

exports.createPane = (opts, ready, done) ->
  if typeof opts is "function"
    done = ready
    ready = opts

  opts ?= {
    title: undefined,
    uri: undefined,
    split: undefined,
    searchAllPanes: undefined,
    changeFocus: undefined,
    view: ScrollView.extend({
      content: -> @div target: false
    })
  }

  done = done or ->

  uris ?= {}

  atom.workspace.subscribe atom.workspace.getActivePane(), "item-removed", (editor) ->
    uri = editor.targetURI
    if uris[uri]
      done = uris[uri]
      delete uris[uri]

      done editor
    return

  target = (if opts.uri then opts.uri else generateTargetURI())
  target = "generated-atom-panel://" + target  unless url.parse(target).protocol
  unless cache[target]

    PanelView = cache[target] = opts.view

    cache[target] = PanelView
    atom.workspace.registerOpener (uri) ->
      return null  if uri isnt target
      view = new PanelView opts
      view.targetURI = target
      view.getTitle = ->
        opts.title or target

      view

  else

    PanelView = cache[target]

  uris[target] = done

  atom.workspace.open(target,
    split: opts.split
    searchAllPanes: !!opts.searchAllPanes
    changeFocus: opts.changeFocus isnt false
  ).done (node) ->
    ready null, node, PanelView
    return

  target
