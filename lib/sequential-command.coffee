{CompositeDisposable} = require 'atom'

module.exports = SequentialCommand =
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
            'editor:move-to-first-character-of-line', 'core:move-to-top',
            'seq:return'
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

  lastCommand: null
  thisCommand: null
  startPosition: null
  storeCount: 0
  commands: []

  activate: (state) ->
    @disposables = new CompositeDisposable()
    @disposables.add atom.keymaps.onDidMatchBinding ({binding}) =>
      command = binding.command
      return if command.indexOf(':') < 1
      return if @commands.indexOf(command) > -1
      @updateCommandHistory command

    atom.commands.add 'atom-text-editor', 'seq:return', =>
      editor = atom.workspace.getActiveTextEditor()
      editor.setCursorBufferPosition @startPosition

    for config in atom.config.get('sequential-command.commands')
      @addCommand config.name, config.commands

  deactivate: ->
    @disposables.dispose()
    @lastCommand = @thisCommand = null

  count: ->
    if @lastCommand is @thisCommand
      @storeCount += 1
    else
      editor = atom.workspace.getActiveTextEditor()
      @startPosition = editor.getCursorBufferPosition()
      @storeCount = 0

  updateCommandHistory: (command) ->
    @lastCommand = @thisCommand
    @thisCommand = command

  addCommand: (name, commands) ->
    atom.commands.add 'atom-text-editor', name, (event) =>
      @updateCommandHistory event.type

      command = commands[@count() % commands.length]
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor
      atom.commands.dispatch editorView, command

    @commands.push name
