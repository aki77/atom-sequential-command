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
  disableLogging = false

  constructor: ->
    @commandDispatchSubscription = atom.commands.onWillDispatch(@logCommand)

  destroy: ->
    @commandDispatchSubscription?.dispose()
    @lastCommand = @thisCommand = null

  logCommand: ({type: command}) =>
    return if @disableLogging
    return if command.indexOf(':') is -1
    return if ignoreCommands.has(command)
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

  addCommand: (name, commands, {undo} = {}) =>
    atom.commands.add 'atom-text-editor', name, (event) =>
      count = @count()
      command = commands[count % commands.length]
      editor = @getActiveTextEditor()

      undo ?= false
      editor.undo() if undo and count > 0

      editorView = atom.views.getView(editor)
      @disableLogging = true
      atom.commands.dispatch(editorView, command)
      @disableLogging = false
