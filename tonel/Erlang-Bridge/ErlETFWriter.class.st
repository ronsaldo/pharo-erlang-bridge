Class {
	#name : #ErlETFWriter,
	#superclass : #Object,
	#instVars : [
		'out'
	],
	#pools : [
		'ErlETFConstants'
	],
	#category : #'Erlang-Bridge-ETF'
}

{ #category : #'as yet unclassified' }
ErlETFWriter class >> encodeObject: anObject [
	^ ByteArray streamContents: [ :out |
		(self on: out)
			encodeObject: anObject
	]
]

{ #category : #'instance creation' }
ErlETFWriter class >> on: aStream [
	^ self basicNew initializeWithStream: aStream
]

{ #category : #encoding }
ErlETFWriter >> encodeAtom: aSymbol [
	| value |
	value := aSymbol utf8Encoded.
	value size <= 255 ifTrue: [
		self nextPut: SMALL_ATOM_UTF8_EXT; nextPut: value size.
	] ifFalse: [
		self assert: value size < (1<<16).
		self nextPut: ATOM_UTF8_EXT; nextPutUInt16: value size.
	].
	out nextPutAll: value
]

{ #category : #encoding }
ErlETFWriter >> encodeFloat: value [
	| word1 word2 |
	word1 := value basicAt: 1.
	word2 := value basicAt: 2.
	self nextPut: NEW_FLOAT_EXT; nextPutUInt64: (word1 << 32) | word2
]

{ #category : #encoding }
ErlETFWriter >> encodeFunction: anErlFunction [
	self
		nextPut: NEW_FUN_EXT;
		nextPutUInt32: anErlFunction encodedData size;
		nextPutAll: anErlFunction encodedData
]

{ #category : #encoding }
ErlETFWriter >> encodeInteger: value [
	(0 <= value and: [ value <= 255 ]) ifTrue: [
		self nextPut: SMALL_INTEGER_EXT; nextPut: value
	] ifFalse: [ 
		self nextPut: INTEGER_EXT; nextPutUInt32: value
	].
]

{ #category : #encoding }
ErlETFWriter >> encodeList: anErlangList [
	| size position |
	anErlangList isEmpty ifTrue: [
		self nextPut: NIL_EXT.
		^ self
	].

	size := anErlangList size.
	self nextPut: LIST_EXT; nextPutUInt32: size.
	
	position := anErlangList.
	[ position isErlCons and: [position isEmpty not ] ] whileTrue: [
		self encodeObject: position head.
		position := position tail
	].

	self encodeObject: position
]

{ #category : #encoding }
ErlETFWriter >> encodeObject: anObject [
	anObject encodeErlangETFWith: self
]

{ #category : #encoding }
ErlETFWriter >> encodeString: aSymbol [
	| value |
	value := aSymbol utf8Encoded.
	value size < (1<<16) ifTrue: [ 
		self nextPut: STRING_EXT; nextPutUInt16: value size; nextPutAll: value.
	] ifFalse: [
		self halt
	]
]

{ #category : #encoding }
ErlETFWriter >> encodeTuple: aSequenceableCollection [
	| size |
	size := aSequenceableCollection size.
	size < 256 ifTrue: [ 
		self nextPut: SMALL_TUPLE_EXT; nextPut: size
	] ifFalse: [ 
		self nextPut: LARGE_TUPLE_EXT; nextPutUInt32: size
	].

	aSequenceableCollection do: [ :element |
		self encodeObject: element
	]
]

{ #category : #initialization }
ErlETFWriter >> initializeWithStream: aStream [
	out := aStream.
	out nextPut: ErlangETFVersion.
	
]

{ #category : #encoding }
ErlETFWriter >> nextPut: value [
	out nextPut: value
]

{ #category : #encoding }
ErlETFWriter >> nextPutAll: aByteArray [
	out nextPutAll: aByteArray
]

{ #category : #encoding }
ErlETFWriter >> nextPutUInt16: value [
	out
		nextPut: (value >> 8) & 16rff;
		nextPut: value & 16rff
]

{ #category : #encoding }
ErlETFWriter >> nextPutUInt32: value [
	out
		nextPut: (value >> 24) & 16rff;
		nextPut: (value >> 16) & 16rff;
		nextPut: (value >> 8) & 16rff;
		nextPut: value & 16rff
]

{ #category : #encoding }
ErlETFWriter >> nextPutUInt64: value [
	out
		nextPut: (value >> 56) & 16rff;
		nextPut: (value >> 48) & 16rff;
		nextPut: (value >> 40) & 16rff;
		nextPut: (value >> 32) & 16rff;
		nextPut: (value >> 24) & 16rff;
		nextPut: (value >> 16) & 16rff;
		nextPut: (value >> 8) & 16rff;
		nextPut: value & 16rff
]
