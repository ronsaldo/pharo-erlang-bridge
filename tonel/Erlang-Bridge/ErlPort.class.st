"
I represent an Erlang port.
"
Class {
	#name : #ErlPort,
	#superclass : #Object,
	#instVars : [
		'node',
		'id',
		'creation'
	],
	#category : #'Erlang-Bridge-Term'
}

{ #category : #accessing }
ErlPort >> creation [
	^ creation
]

{ #category : #accessing }
ErlPort >> creation: anObject [
	creation := anObject
]

{ #category : #'as yet unclassified' }
ErlPort >> encodeErlangETFWith: writer [
	^ writer encodePort: self
]

{ #category : #accessing }
ErlPort >> id [
	^ id
]

{ #category : #accessing }
ErlPort >> id: anObject [
	id := anObject
]

{ #category : #accessing }
ErlPort >> node [
	^ node
]

{ #category : #accessing }
ErlPort >> node: anObject [
	node := anObject
]
