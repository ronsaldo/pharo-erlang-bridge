Extension { #name : #String }

{ #category : #'*Erlang-Bridge' }
String >> encodeErlangETFWith: writer [
	writer encodeString: self
]
