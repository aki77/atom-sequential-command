path = require 'path'
{hasCommand, keydown} = require './spec-helper'

describe "SequentialCommand", ->
  [workspaceElement, activationPromise, editor, editorElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('sequential-command')

    atom.keymaps.add('atom-text-editor',
      'atom-text-editor':
        'ctrl-a': 'seq:home'
        'ctrl-e': 'seq:end'
    )

    waitsForPromise ->
      url = path.join(__dirname, 'fixtures', 'sample.coffee')
      atom.workspace.open(url).then((_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)
      )

  describe "activate", ->
    beforeEach ->
      waitsForPromise ->
        activationPromise

    it "seq:home", ->
      expect(hasCommand(editorElement, 'seq:home')).toBeTruthy()
      editor.setCursorBufferPosition([1, 13])
      keydown('a', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [1, 2]
      keydown('a', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [1, 0]
      keydown('a', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [0, 0]
      keydown('a', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [1, 13]

    it "seq:end", ->
      expect(hasCommand(editorElement, 'seq:end')).toBeTruthy()
      editor.setCursorBufferPosition([1, 13])
      keydown('e', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [1, 21]
      keydown('e', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [3, 0]
      keydown('e', {ctrl: true})
      expect(editor.getCursorBufferPosition()).toEqual [1, 13]
