Class {
	#name : #ErlETFParser,
	#superclass : #Object,
	#instVars : [
		'in'
	],
	#classVars : [
		'TagDispatchTable'
	],
	#pools : [
		'ErlETFConstants'
	],
	#category : #'Erlang-Bridge-ETF'
}

{ #category : #initialization }
ErlETFParser class >> generateDispatchTableMethod [
	<script>
	
	| code |
	code := ByteString streamContents: [ :out |
		out nextPutAll: 'initializeDispatchTable
		
	TagDispatchTable := Array new: 256.
'.
		out tab << 'TagDispatchTable'; cr.
		ErlETFTags pairsDo: [ :tagName :tagValue |
			out tab tab << 'at: ' << (tagValue + 1) << ' put: [:this | this parse_' << tagName << ' ];'; cr
		].
	
		out tab tab << 'yourself'; cr.
	].

	self class compile: code classified: 'term parse dispatch table'
]

{ #category : #initialization }
ErlETFParser class >> initialize [
	self initializeDispatchTable
]

{ #category : #'term parse dispatch table' }
ErlETFParser class >> initializeDispatchTable [
		
	TagDispatchTable := Array new: 256.
	TagDispatchTable
		at: 83 put: [:this | this parse_ATOM_CACHE_REF ];
		at: 98 put: [:this | this parse_SMALL_INTEGER_EXT ];
		at: 99 put: [:this | this parse_INTEGER_EXT ];
		at: 100 put: [:this | this parse_FLOAT_EXT ];
		at: 102 put: [:this | this parse_REFERENCE_EXT ];
		at: 103 put: [:this | this parse_PORT_EXT ];
		at: 104 put: [:this | this parse_PID_EXT ];
		at: 105 put: [:this | this parse_SMALL_TUPLE_EXT ];
		at: 106 put: [:this | this parse_LARGE_TUPLE_EXT ];
		at: 117 put: [:this | this parse_MAP_EXT ];
		at: 107 put: [:this | this parse_NIL_EXT ];
		at: 108 put: [:this | this parse_STRING_EXT ];
		at: 109 put: [:this | this parse_LIST_EXT ];
		at: 110 put: [:this | this parse_BINARY_EXT ];
		at: 111 put: [:this | this parse_SMALL_BIG_EXT ];
		at: 112 put: [:this | this parse_LARGE_BIG_EXT ];
		at: 115 put: [:this | this parse_NEW_REFERENCE_EXT ];
		at: 118 put: [:this | this parse_FUN_EXT ];
		at: 113 put: [:this | this parse_NEW_FUN_EXT ];
		at: 114 put: [:this | this parse_EXPORT_EXT ];
		at: 78 put: [:this | this parse_BIT_BINARY_EXT ];
		at: 71 put: [:this | this parse_NEW_FLOAT_EXT ];
		at: 119 put: [:this | this parse_ATOM_UTF8_EXT ];
		at: 120 put: [:this | this parse_SMALL_ATOM_UTF8_EXT ];
		at: 101 put: [:this | this parse_ATOM_EXT_DEPRECATED ];
		at: 116 put: [:this | this parse_SMALL_ATOM_EXT_DEPRECATED ];
		yourself

]

{ #category : #parsing }
ErlETFParser class >> on: aStream [
	^ self basicNew initializeWithStream: aStream
]

{ #category : #parsing }
ErlETFParser class >> parse: aByteArray [
	^ (self on: aByteArray readStream) parse
]

{ #category : #parsing }
ErlETFParser class >> parseFileNamed: aFileName [
	^ aFileName asFileReference readStreamDo: [ :in |
			in binary.
			(self on: in) parse
	]
]

{ #category : #initialization }
ErlETFParser >> initializeWithStream: aStream [
	in := aStream
]

{ #category : #parsing }
ErlETFParser >> nextInt32 [
	| value |
	value := self nextUInt32.
	^ (value & 16r7FFFFFFF) - (value & 16r80000000)
]

{ #category : #parsing }
ErlETFParser >> nextUInt16 [
	^ (in next << 8) | in next
]

{ #category : #parsing }
ErlETFParser >> nextUInt32 [
	^ (in next << 24) | (in next << 16) | (in next << 8) | in next
]

{ #category : #parsing }
ErlETFParser >> nextUInt64 [
	^ 
		(in next << 56) |
		(in next << 48) |
		(in next << 40) |
		(in next << 32) |
		(in next << 24) |
		(in next << 16) |
		(in next << 8) |
		in next
]

{ #category : #parsing }
ErlETFParser >> nextUInt8 [
	^ in next
]

{ #category : #parsing }
ErlETFParser >> parse [
	| version |
	version := in next.
	^ self parseTerm
]

{ #category : #parsing }
ErlETFParser >> parseTerm [
	| tag |
	tag := in next.
	^ (TagDispatchTable at: tag + 1) value: self
]

{ #category : #parsing }
ErlETFParser >> parse_ATOM_EXT_DEPRECATED [
	| length atomData |
	length := self nextUInt16.
	atomData := in next: length.
	^ atomData asString asSymbol
]

{ #category : #parsing }
ErlETFParser >> parse_ATOM_UTF8_EXT [
	| length atomData |
	length := self nextUInt16.
	atomData := in next: length.
	^ atomData utf8Decoded asString asSymbol
]

{ #category : #parsing }
ErlETFParser >> parse_BINARY_EXT [
	| length |
	length := self nextUInt32.
	^ in next: length
]

{ #category : #parsing }
ErlETFParser >> parse_INTEGER_EXT [
	^ self nextInt32
]

{ #category : #parsing }
ErlETFParser >> parse_LARGE_TUPLE_EXT [
	| arity |
	arity := self nextUInt32.
	^ (1 to: arity) collect: [:i | self parseTerm ]
]

{ #category : #parsing }
ErlETFParser >> parse_LIST_EXT [
	| elements position head newCons |
	elements := self nextUInt32.
	head := position := nil.
	(1 to: elements) do: [ :element |
		newCons := ErlCons new head: self parseTerm.
		position ifNil: [
			head := position := newCons
		] ifNotNil: [
			position tail: newCons.
			position := newCons
		].
	].

	^ position ifNil: [
		self parseTerm
	] ifNotNil: [ 
		position tail: self parseTerm.
		head
	]
]

{ #category : #parsing }
ErlETFParser >> parse_MAP_EXT [
	| arity result |
	arity := self nextUInt32.
	result := Dictionary new.
	1 to: arity do: [ :i |
		result at: self parseTerm put: self parseTerm
	].

	^ result
]

{ #category : #parsing }
ErlETFParser >> parse_NEW_FLOAT_EXT [
	^ Float fromIEEE64Bit: self nextUInt64
]

{ #category : #parsing }
ErlETFParser >> parse_NEW_FUN_EXT [
	| size encodedData |
	size := self nextUInt32  - 4.
	encodedData := in next: size.
	^ ErlFunction new encodedData: encodedData
]

{ #category : #parsing }
ErlETFParser >> parse_NEW_REFERENCE_EXT [
	| length |
	length := self nextUInt16.
	^ ErlReference new
		node: self parseTerm;
		creation: self nextUInt8;
		id: ((1 to: length) collect: [:i | self nextUInt32]);
		yourself
]

{ #category : #parsing }
ErlETFParser >> parse_NIL_EXT [
	^ ErlCons empty
]

{ #category : #parsing }
ErlETFParser >> parse_PID_EXT [
	^ ErlPID new
		node: self parseTerm;
		id: self nextUInt32;
		serial: self nextUInt32;
		creation: self nextUInt8;
		yourself
]

{ #category : #parsing }
ErlETFParser >> parse_PORT_EXT [
	^ ErlPort new
		node: self parseTerm;
		id: self nextUInt32;
		creation: self nextUInt8;
		yourself
]

{ #category : #parsing }
ErlETFParser >> parse_REFERENCE_EXT [
	^ ErlReference new
		node: self parseTerm;
		id: self nextUInt32;
		creation: self nextUInt8;
		yourself
]

{ #category : #parsing }
ErlETFParser >> parse_SMALL_ATOM_EXT_DEPRECATED [
	| length atomData |
	length := in next.
	atomData := in next: length.
	^ atomData asString asSymbol
]

{ #category : #parsing }
ErlETFParser >> parse_SMALL_ATOM_UTF8_EXT [
	| length atomData |
	length := in next.
	atomData := in next: length.
	^ atomData utf8Decoded asSymbol
]

{ #category : #parsing }
ErlETFParser >> parse_SMALL_INTEGER_EXT [
	^ in next
]

{ #category : #parsing }
ErlETFParser >> parse_SMALL_TUPLE_EXT [
	| arity |
	arity := in next.
	^ (1 to: arity) collect: [:i | self parseTerm ]
]

{ #category : #parsing }
ErlETFParser >> parse_STRING_EXT [
	| length |
	length := self nextUInt16.
	^ (in next: length) asString
]
