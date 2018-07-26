Extension { #name : #SequenceableCollection }

{ #category : #'*Erlang-Bridge' }
SequenceableCollection >> asErlangList [
	| position head newCons |
	head := position := nil.
	self do: [ :element |
		newCons := ErlCons new head: element.
		position ifNil: [
			head := position := newCons
		] ifNotNil: [
			position tail: newCons.
			position := newCons
		].
	].

	^ position ifNil: [
		ErlCons empty
	] ifNotNil: [ 
		position tail: ErlCons empty.
		head
	]
]

{ #category : #'*Erlang-Bridge' }
SequenceableCollection >> encodeErlangETFWith: writer [
	writer encodeTuple: self
]
