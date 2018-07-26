Extension { #name : #Object }

{ #category : #'*Erlang-Bridge' }
Object >> asErlangETF [
	^ ErlETFWriter encodeObject: self
]

{ #category : #'*Erlang-Bridge' }
Object >> encodeErlangETFWith: writer [
	self subclassResponsibility
]

{ #category : #'*Erlang-Bridge' }
Object >> isEmptyErlCons [
	^ false
]

{ #category : #'*Erlang-Bridge' }
Object >> isErlCons [
	^ false
]
