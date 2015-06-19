{CompositeDisposable} = require 'atom'
SequentialCommand = require './sequential-command'

module.exports =
  config:
    commands:
      type: 'array'
      default: [
        {
          name: 'seq:end'
          commands: [
            'editor:move-to-end-of-screen-line', 'core:move-to-bottom',
            'seq:return'
          ]
        }
        {
          name: 'seq:home'
          commands: [
            'editor:move-to-first-character-of-line',
            'editor:move-to-beginning-of-line',
            'core:move-to-top', 'seq:return'
          ]
        }
      ]
      items:
        type: 'object'
        properties:
          name:
            type: 'string'
          commands:
            type: 'array'
            items:
              type: 'string'

  activate: (state) ->
    @disposables = new CompositeDisposable
    @sequentialCommand = new SequentialCommand

    @disposables.add atom.commands.add 'atom-text-editor',
      'seq:return': @sequentialCommand.return
      'seq:upcase-backward-word': @sequentialCommand.upcaseBackwardWord
      'seq:lower-backward-word': @sequentialCommand.lowerBackwardWord

    @disposables.add atom.config.observe 'sequential-command.commands', (seqCommands) =>
      @customCommandsSubscriptions?.dispose()
      @customCommandsSubscriptions = new CompositeDisposable

      for {name, commands} in seqCommands
        @customCommandsSubscriptions.add(@sequentialCommand.addCommand(name, commands))

  deactivate: ->
    @sequentialCommand.destroy()
    @disposables.dispose()
    @customCommandsSubscriptions?.dispose()
    @customCommandsSubscriptions = null

  provide: ->
    replaceBackwardWord: @sequentialCommand.replaceBackwardWord.bind(@sequentialCommand)
    addCommand: @sequentialCommand.addCommand.bind(@sequentialCommand)
    count: @sequentialCommand.count.bind(@sequentialCommand)
