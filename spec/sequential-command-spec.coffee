path = require 'path'
{hasCommand, keydown} = require './spec-helper'

describe "SequentialCommand", ->
  [workspaceElement, activationPromise, editor, editorElement, sequentialCommand] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('sequential-command')

    atom.keymaps.add('sequential-command-spec1',
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

    waitsForPromise ->
      activationPromise.then (pack) ->
        sequentialCommand = pack.mainModule

  describe "activate", ->
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

  describe 'provide',  ->
    [service] = []
    beforeEach ->
      service = sequentialCommand.provide()
      editor.selectAll()
      editor.delete()
      editor.insertText('ABCabc')
      editor.selectAll()
      #spyOn(editor, 'undo')
      atom.config.set('editor.undoGroupingInterval', 0)

    it 'addCommand', ->
      expect(hasCommand(editorElement, 'seq:upper-lower')).toBeFalsy()
      commands = ['editor:upper-case', 'editor:lower-case']
      service.addCommand('seq:upper-lower', commands, {undo: true})
      expect(hasCommand(editorElement, 'seq:upper-lower')).toBeTruthy()

      atom.keymaps.add('sequential-command-spec2',
        'atom-text-editor':
          'ctrl-u': 'seq:upper-lower'
      )

      expect(editor.getText()).toBe('ABCabc')

      keydown('u', {ctrl: true})

      expect(editor.getText()).toBe('ABCABC')

      keydown('u', {ctrl: true})
      expect(editor.getText()).toBe('abcabc')

      keydown('u', {ctrl: true})
      expect(editor.getText()).toBe('ABCABC')

      editor.undo()
      expect(editor.getText()).toBe('ABCabc')
