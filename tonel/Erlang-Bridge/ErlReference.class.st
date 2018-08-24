"
I represent an Erlang opaque object created by erlang:make_ref/0.
"
Class {
	#name : #ErlReference,
	#superclass : #Object,
	#instVars : [
		'node',
		'id',
		'creation'
	],
	#category : #'Erlang-Bridge-Term'
}

{ #category : #accessing }
ErlReference >> creation [
	^ creation
]

{ #category : #accessing }
ErlReference >> creation: anObject [
	creation := anObject
]

{ #category : #'as yet unclassified' }
ErlReference >> encodeErlangETFWith: writer [
	^ writer encodeReference: self
]

{ #category : #accessing }
ErlReference >> id [
	^ id
]

{ #category : #accessing }
ErlReference >> id: anObject [
	id := anObject
]

{ #category : #accessing }
ErlReference >> node [
	^ node
]

{ #category : #accessing }
ErlReference >> node: anObject [
	node := anObject
]
