# Atom Development Server

https://github.com/joaoafrmartins/atom-development-server/

![A screenshot of your spankin' package](https://github.com/joaoafrmartins/atom-development-server/raw/master/screenshot.png)

### Features

#### Static Http Server

  - a static file http server

#### Live Reload Server

  - livereload html changes in the browser or the preview tab

#### Terminal

  - execute a terminal session from inside atom editor

        Notes:

            - If you start atom using a terminal window you migth have to close
        the terminal you used to launch atom

            - If you clone the git repository and are having trouble with pty.js
          try running apm install atom-development-server and copy pty.js
          from the node_modules folder.

        [pty.js#83](https://github.com/chjj/pty.js/issues/83)


#### Browser Tabs

  - html preview inside atom panes

  Note: the browser config section allows you to embed multiple iframes inside atom

        "browser": {
          "tabs": [
            {
              "split": "right",
              "title": "Preview",
              "changeFocus": false,
              "searchAllPanes": true,
              "uri": "http://localhost:8080"
            },
            {
              "split": "right",
              "title": "Specs",
              "changeFocus": false,
              "searchAllPanes": true,
              "uri": "http://localhost:8080/specs.html"
            }
          ]
        }

#### Custom Shortcuts

  - subscribe to events and execute custom actions

  - each action will be mapped to a button wich trigger the specified action

  - the action value should be a bash command (ex: npm run test)

  - you can subscribe to one or more atom core events:

    Note: the autobuild option allows you to toggle the subscriptions on or off.

        "shortcuts": {
          "subscriptions": {
            "core:save": ["build"]
          },
          "actions": {
            "build": "npm run build"
          }
        }
