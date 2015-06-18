_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'

module.exports =
class SequentialCommand
  ignoreCommands = new Set([
    'editor:display-updated', 'cursor:moved', 'selection:changed'
  ])

  lastCommand: null
  thisCommand: null
  startPosition: null
  storeCount: 0
  originalDispatchCommandEvent: null

  constructor: ->
    @originalDispatchCommandEvent = atom.keymaps.dispatchCommandEvent
    _.adviseBefore(atom.keymaps, 'dispatchCommandEvent', @dispatchCommandEvent)

  destroy: ->
    @resetCommands()
    @lastCommand = @thisCommand = null
    atom.keymaps.dispatchCommandEvent = @originalDispatchCommandEvent

  dispatchCommandEvent: (command) =>
    @lastCommand = @thisCommand
    @thisCommand = command

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  return: =>
    editor = @getActiveTextEditor()
    editor?.setCursorBufferPosition(@startPosition)

  upcaseBackwardWord: =>
    @replaceBackwardWord (editor) -> editor.upperCase()

  lowerBackwardWord: =>
    @replaceBackwardWord (editor) -> editor.lowerCase()

  replaceBackwardWord: (fn) =>
    editor = @getActiveTextEditor()
    editor?.transact =>
      position = editor.getCursorBufferPosition()
      count = @count() + 1
      editor.moveToBeginningOfWord() for i in [1..count]
      fn(editor)
      editor.setCursorBufferPosition(position)

  count: =>
    if @lastCommand is @thisCommand
      @storeCount += 1
    else
      editor = @getActiveTextEditor()
      @startPosition = editor?.getCursorBufferPosition()
      @storeCount = 0

  addCommand: (name, commands) =>
    @commandSubscriptions ?= new CompositeDisposable
    @commandSubscriptions.add atom.commands.add 'atom-text-editor', name, (event) =>
      command = commands[@count() % commands.length]
      editor = @getActiveTextEditor()
      editorView = atom.views.getView(editor)
      atom.commands.dispatch(editorView, command)

  resetCommands: =>
    @commandSubscriptions?.dispose()
    @commandSubscriptions = null
