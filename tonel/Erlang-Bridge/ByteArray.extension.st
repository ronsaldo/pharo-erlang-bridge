Extension { #name : #ByteArray }

{ #category : #'*Erlang-Bridge' }
ByteArray >> erlangETFDecoded [
	^ ErlETFParser parse: self
]
