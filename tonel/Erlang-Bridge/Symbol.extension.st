Extension { #name : #Symbol }

{ #category : #'*Erlang-Bridge' }
Symbol >> encodeErlangETFWith: writer [
	writer encodeAtom: self
]
