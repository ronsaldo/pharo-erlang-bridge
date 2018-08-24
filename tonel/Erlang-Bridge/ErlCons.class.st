Class {
	#name : #ErlCons,
	#superclass : #SequenceableCollection,
	#instVars : [
		'head',
		'tail'
	],
	#classVars : [
		'EmptyCons'
	],
	#category : #'Erlang-Bridge-Term'
}

{ #category : #requirements }
ErlCons class >> empty [
	^ EmptyCons
]

{ #category : #initialization }
ErlCons class >> initialize [
	super initialize.
	EmptyCons := self new beReadOnlyObject; yourself
]

{ #category : #comparing }
ErlCons >> = o [
	^ self class == o class and:
	[ head = o head and:
	[ tail = o tail ] ]
]

{ #category : #printing }
ErlCons >> at: index [
	self ifEmpty: [ self errorSubscriptBounds: index ].
	index = 1 ifTrue: [ ^ head ].
	^ tail at: index - 1
]

{ #category : #'as yet unclassified' }
ErlCons >> encodeErlangETFWith: writer [
	writer encodeList: self
]

{ #category : #comparing }
ErlCons >> hash [
	^ self class identityHash bitXor: (head hash bitXor: tail hash)
]

{ #category : #accessing }
ErlCons >> head [
	^ head
]

{ #category : #accessing }
ErlCons >> head: anObject [
	head := anObject
]

{ #category : #testing }
ErlCons >> isEmpty [
	^ head isNil and: [ tail isNil ]
]

{ #category : #testing }
ErlCons >> isEmptyErlCons [
	^ self isEmpty
]

{ #category : #testing }
ErlCons >> isErlCons [
	^ true
]

{ #category : #printing }
ErlCons >> printOn: aStream [
	| position |
	self isEmpty ifTrue: [
		aStream nextPutAll: '[]'.
		^ self
	].

	aStream nextPutAll: '[ '; print: head.
	position := tail.
	[ position isErlCons and: [ position isEmpty not ] ] whileTrue: [
		aStream nextPutAll: ', '; print: position head.
		position := position tail
	].

	position isEmptyErlCons ifFalse: [
		aStream nextPutAll: ' | '; print: position
	].

	aStream nextPutAll: ' ]'
]

{ #category : #printing }
ErlCons >> size [
	| size position |
	self isEmpty ifTrue: [ ^ 0 ].
	
	size := 1.
	position := tail.
	[ position isErlCons and: [ position isEmpty not ] ] whileTrue: [
		size := size + 1.
		position := position tail
	].

	^ size
]

{ #category : #accessing }
ErlCons >> tail [
	^ tail
]

{ #category : #accessing }
ErlCons >> tail: anObject [
	tail := anObject
]
