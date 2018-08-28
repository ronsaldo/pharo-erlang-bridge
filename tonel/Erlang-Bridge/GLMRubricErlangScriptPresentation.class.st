Class {
	#name : #GLMRubricErlangScriptPresentation,
	#superclass : #GLMRubricErlangCodePresentation,
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #'accessing-dynamic' }
GLMRubricErlangScriptPresentation >> currentBindings [

	self withBindingsDo: [ :bingings | ^ bingings copy ]
]

{ #category : #rendering }
GLMRubricErlangScriptPresentation >> defaultSelectionActions [

	^ {self goAction}, super defaultSelectionActions
]

{ #category : #rendering }
GLMRubricErlangScriptPresentation >> goAction [
	^ GLMGenericAction new
				title: 'Do it and go';
				action: [ :t :entity |
					t highlightEvaluateAndDo: [ :result | t selection: result ] ]; 
				shortcut: $g; 
				yourself.
]

{ #category : #rendering }
GLMRubricErlangScriptPresentation >> renderGlamorouslyOn: aRenderer [ 
	self registerAnnouncements.
	^ aRenderer renderErlangScriptPresentation: self
]

{ #category : #'accessing-dynamic' }
GLMRubricErlangScriptPresentation >> resetBindings [

	self withBindingsDo: [ :bindings | bindings removeAll ]
]

{ #category : #actions }
GLMRubricErlangScriptPresentation >> updateVariableBindings [

	self announce: (GLMVariableBindingsChanged new presentation: self).
]

{ #category : #actions }
GLMRubricErlangScriptPresentation >> withBindingsDo: aBlock [

	self announce: (GLMVariableBindingsAccessRequest new action: aBlock)
]
