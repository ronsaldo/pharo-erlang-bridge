Class {
	#name : #GLMRubricErlangCodePresentation,
	#superclass : #GLMRubricTextPresentation,
	#instVars : [
		'client',
		'highlightErlangContext',
		'variableBindingsBlock'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #accessing }
GLMRubricErlangCodePresentation >> client [
	^ client glamourValue: self entity
]

{ #category : #accessing }
GLMRubricErlangCodePresentation >> client: aBlock [
	^ client := aBlock
]

{ #category : #rendering }
GLMRubricErlangCodePresentation >> defaultSelectionActions [

	^ self executionSelectionActions,
		self codeEditingSelectionActions
]

{ #category : #actions }
GLMRubricErlangCodePresentation >> evaluateSelection [

	self announce: (GLMEvaluateSelection new 
		action: [ :result | result ];
		makeSyncronous)
]

{ #category : #actions }
GLMRubricErlangCodePresentation >> evaluateSelectionAndDo: aBlock [

	self announce: (GLMEvaluateSelection new action: aBlock)
]

{ #category : #accessing }
GLMRubricErlangCodePresentation >> executionSelectionActions [

	^ { 
		(GLMGenericAction new) 
				title: 'Do it';
				action: [ :aPresentation |
					aPresentation highlightEvaluateAndDo: [ :result | ] ]; 
				keymap: PharoShortcuts current doItShortcut; 
				icon: GLMUIThemeExtraIcons glamorousSpawn;
				yourself.
		(GLMGenericAction new) 
				title: 'Print it';
				action: [ :aPresentation |
					aPresentation printSelection ]; 
				keymap: PharoShortcuts current printItShortcut; 
				yourself.
		(GLMGenericAction new) 
				title: 'Inspect it'; 
				action: [ :aPresentation |
					aPresentation highlightEvaluateAndDo: [ :result | result inspect ] ]; 
				keymap: PharoShortcuts current inspectItShortcut; 
				icon: GLMUIThemeExtraIcons glamorousInspect;
				yourself.
		(GLMGenericAction new) 
				title: 'Basic Inspect it'; 
				action: [ :aPresentation |
					aPresentation highlightEvaluateAndDo: [ :result | result basicInspect ] ]; 
				shortcut: $I; 
				icon: GLMUIThemeExtraIcons glamorousInspect;
				yourself.
		(GLMGenericAction new) 
				title: 'Debug it'; 
				action: [ :aPresentation |
					aPresentation debugSelection ]; 
				shortcut: $D;
				yourself.
		 }
]

{ #category : #accessing }
GLMRubricErlangCodePresentation >> highlightErlangContext [
	^ highlightErlangContext isNil 
		ifTrue: [nil] 
		ifFalse: [highlightErlangContext glamourValue: self entity]
]

{ #category : #actions }
GLMRubricErlangCodePresentation >> highlightEvaluateAndDo: aBlock [

	self announce: (GLMHighlightAndEvaluate new action: aBlock)
]

{ #category : #rendering }
GLMRubricErlangCodePresentation >> installDefaultSelectionActions [

	self defaultSelectionActions do: [ :anAction |
		self addSelectionAction: anAction ]
]

{ #category : #actions }
GLMRubricErlangCodePresentation >> printSelection [

	self announce: GLMPrintSelection
]

{ #category : #accessing }
GLMRubricErlangCodePresentation >> variableBindings [
	^ (variableBindingsBlock glamourValue: self entity) ifNil: [OrderedCollection new]
]

{ #category : #accessing }
GLMRubricErlangCodePresentation >> variableBindings: aBlock [
	^ variableBindingsBlock := aBlock
]
