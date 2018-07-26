Extension { #name : #Integer }

{ #category : #'*Erlang-Bridge' }
Integer >> encodeErlangETFWith: writer [
	writer encodeInteger: self
]
