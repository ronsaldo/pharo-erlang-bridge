Extension { #name : #Number }

{ #category : #'*Erlang-Bridge' }
Number >> encodeErlangETFWith: writer [
	writer encodeFloat: self asFloat
]
