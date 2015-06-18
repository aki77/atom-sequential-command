# sequential-command package

Many commands into one command

![A screenshot of your package](http://i.gyazo.com/58329aae666e84ffc8bd08b7ceb8c6ef.gif)

Inspired by [sequential-command.el](http://emacswiki.org/emacs/sequential-command.el).

## Keymap

No keymap by default.

edit `~/.atom/keymap.cson`

```coffeescript
'atom-text-editor':
  'ctrl-e': 'seq:end'
  'ctrl-a': 'seq:home'
  'alt-u': 'seq:upcase-backward-word'
  'alt-l': 'seq:lower-backward-word'
```

## Settings

edit `~/.atom/config.cson`

```coffeescript
# default settings
"*":
  "sequential-command":
    "commands": [
      {
        "name": "seq:end",
        "commands": [
          "editor:move-to-end-of-screen-line",
          "core:move-to-bottom",
          "seq:return"
        ]
      },
      {
        "name": "seq:home",
        "commands": [
          "editor:move-to-first-character-of-line",
          "editor:move-to-beginning-of-line",
          "core:move-to-top",
          "seq:return"
        ]
      }
    ]
```
