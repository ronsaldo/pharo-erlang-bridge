"
I represent an erlang process object created by erlang:spawn and family.
"
Class {
	#name : #ErlPID,
	#superclass : #Object,
	#instVars : [
		'node',
		'id',
		'serial',
		'creation'
	],
	#category : #'Erlang-Bridge-Term'
}

{ #category : #accessing }
ErlPID >> creation [
	^ creation
]

{ #category : #accessing }
ErlPID >> creation: anObject [
	creation := anObject
]

{ #category : #'as yet unclassified' }
ErlPID >> encodeErlangETFWith: writer [
	^ writer encodePID: self
]

{ #category : #accessing }
ErlPID >> id [
	^ id
]

{ #category : #accessing }
ErlPID >> id: anObject [
	id := anObject
]

{ #category : #testing }
ErlPID >> isErlPID [
	^ true
]

{ #category : #accessing }
ErlPID >> node [
	^ node
]

{ #category : #accessing }
ErlPID >> node: anObject [
	node := anObject
]

{ #category : #printing }
ErlPID >> printOn: aStream [
	aStream << '<' << node << '.' << serial << '.' << id << '.' << creation << '>'
]

{ #category : #accessing }
ErlPID >> serial [
	^ serial
]

{ #category : #accessing }
ErlPID >> serial: anObject [
	serial := anObject
]
