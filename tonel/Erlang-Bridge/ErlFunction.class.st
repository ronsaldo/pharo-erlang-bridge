Class {
	#name : #ErlFunction,
	#superclass : #Object,
	#instVars : [
		'encodedData'
	],
	#category : #'Erlang-Bridge-Term'
}

{ #category : #'as yet unclassified' }
ErlFunction >> encodeErlangETFWith: writer [
	writer encodeFunction: self
]

{ #category : #accessing }
ErlFunction >> encodedData [
	^ encodedData
]

{ #category : #accessing }
ErlFunction >> encodedData: anObject [
	encodedData := anObject
]
