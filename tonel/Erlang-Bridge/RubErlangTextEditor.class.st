Class {
	#name : #RubErlangTextEditor,
	#superclass : #RubTextEditor,
	#instVars : [
		'notificationStrategy'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #'do-its' }
RubErlangTextEditor >> evaluate: aStream andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	| result |
	result := self model erlangDoIt: aStream requestor: self morph onFail: [ self morph flash. ^ nil ].
			
	^ aBlock value: result
]

{ #category : #'do-its' }
RubErlangTextEditor >> highlightEvaluateAndDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	
	self highlightAndEmptyCheck: [ ^ '' ].
	^ self 
		evaluate: self highlightedTextAsStream
		andDo: [:result | aBlock value: result]
]

{ #category : #accessing }
RubErlangTextEditor >> notificationStrategy [
	^ notificationStrategy
]

{ #category : #accessing }
RubErlangTextEditor >> notificationStrategy: aStrategy [
	notificationStrategy := aStrategy.
	aStrategy editor: self
]

{ #category : #'interactive error protocol' }
RubErlangTextEditor >> notify: aString at: anInteger in: aStream [ 
	^ self notificationStrategy 
		notify: aString 
		at: anInteger 
		in: aStream 

]
