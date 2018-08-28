Extension { #name : #Dictionary }

{ #category : #'*Erlang-Bridge' }
Dictionary >> encodeErlangETFWith: writer [
	writer encodeMap: self
]
