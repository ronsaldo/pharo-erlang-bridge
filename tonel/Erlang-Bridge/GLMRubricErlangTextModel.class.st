Class {
	#name : #GLMRubricErlangTextModel,
	#superclass : #GLMRubricTextModel,
	#instVars : [
		'client',
		'highlightErlang',
		'highlightErlangContext',
		'bindingsStrategy',
		'variableBindings'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #bindings }
GLMRubricErlangTextModel >> appendVariableBinding: anAssociationList [

	anAssociationList ifNotNil: [
		anAssociationList do: [ :anAssociation | 
			self variableBindings add: anAssociation
		]
	]
]

{ #category : #'do-it' }
GLMRubricErlangTextModel >> applyNewBindings: newBindings [
	variableBindings := Dictionary new.
	newBindings do: [ :binding |
		variableBindings at: binding first put: binding second
	].

]

{ #category : #bindings }
GLMRubricErlangTextModel >> bindingOf: aSymbol [

	^ self bindingsStrategy cull: self variableBindings cull: aSymbol cull: self
]

{ #category : #bindings }
GLMRubricErlangTextModel >> bindingsStrategy [

	^ bindingsStrategy
]

{ #category : #bindings }
GLMRubricErlangTextModel >> bindingsStrategy: aBlock [

	bindingsStrategy := aBlock
]

{ #category : #accessing }
GLMRubricErlangTextModel >> client [
	^ client
]

{ #category : #accessing }
GLMRubricErlangTextModel >> client: anObject [
	client := anObject
]

{ #category : #'do-it' }
GLMRubricErlangTextModel >> erlangBindingList [
	self variableBindings ifEmpty: [ ErlCons empty ].
	^ (Array streamContents: [ :out |
		self variableBindings keysAndValuesDo: [ :k :v |
			out nextPut: { k . v }
		]
	]) asErlangList
]

{ #category : #'do-it' }
GLMRubricErlangTextModel >> erlangDoIt: aStream requestor: requestor onFail: onFailBlock [
	| erlangBindings result status |
	erlangBindings := self erlangBindingList.
	result := client eval: aStream contents bindings: erlangBindings.
	status := result first.
	status = #error ifTrue: [
		self notifyError: result toRequestor: requestor.
		^ onFailBlock value
	].

	status = #value ifTrue: [
		self applyNewBindings: result third.
		^ result second
	]
]

{ #category : #bindings }
GLMRubricErlangTextModel >> hasBindingOf: aSymbol [

	^ self variableBindings includesKey: aSymbol
]

{ #category : #bindings }
GLMRubricErlangTextModel >> hasBindingThatBeginsWith: aString [
	^ self variableBindings keys anySatisfy: [:each | each beginsWith: aString]
]

{ #category : #accessing }
GLMRubricErlangTextModel >> highlightErlang [
	^ highlightErlang
]

{ #category : #accessing }
GLMRubricErlangTextModel >> highlightErlang: anObject [
	highlightErlang := anObject
]

{ #category : #accessing }
GLMRubricErlangTextModel >> highlightErlangContext [
	^ highlightErlangContext
]

{ #category : #accessing }
GLMRubricErlangTextModel >> highlightErlangContext: anObject [
	highlightErlangContext := anObject
]

{ #category : #'do-it' }
GLMRubricErlangTextModel >> notifyError: error toRequestor: requestor [
	| convertedError |
	convertedError := client convertEvalResultError: error.
	convertedError notifyToRequestor: requestor
]

{ #category : #bindings }
GLMRubricErlangTextModel >> variableBindings [
	^ variableBindings ifNil: [variableBindings := Dictionary new]
]

{ #category : #bindings }
GLMRubricErlangTextModel >> variableBindings: aDictionary [
	variableBindings := aDictionary
]
