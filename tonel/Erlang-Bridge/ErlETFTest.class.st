Class {
	#name : #ErlETFTest,
	#superclass : #TestCase,
	#category : #'Erlang-Bridge-Tests'
}

{ #category : #tests }
ErlETFTest >> testParse [
	self assert: #[131 100 0 5 104 101 108 108 111] erlangETFDecoded equals: #hello.
	self assert: #[131 119 5 104 101 108 108 111] erlangETFDecoded equals: #hello.
	self assert: #[131 98 255 255 252 0] erlangETFDecoded equals: -1024.
	self assert: #[131 70 64 69 0 0 0 0 0 0] erlangETFDecoded equals: 42.0.
	self assert: #[131 104 2 100 0 5 104 101 108 108 111 108 0 0 0 4 100 0 4 108 105 115 116 97 1 97 2 100 0 4 108 105 115 116 106] erlangETFDecoded equals: { #hello . { #list . 1 . 2. #list } asErlangList }.
	
]

{ #category : #tests }
ErlETFTest >> testWrite [
	self assert: #[131 119 5 104 101 108 108 111] equals: #hello asErlangETF.
	self assert: #[131 98 255 255 252 0] equals: -1024 asErlangETF.
	self assert: #[131 70 64 69 0 0 0 0 0 0] equals: 42.0 asErlangETF.
	self assert: #[131 104 2 119 5 104 101 108 108 111 108 0 0 0 4 119 4 108 105 115 116 97 1 97 2 119 4 108 105 115 116 106] equals: { #hello . { #list . 1 . 2. #list } asErlangList } asErlangETF.
	
]
