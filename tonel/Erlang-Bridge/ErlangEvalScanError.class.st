"
I represent an Erlang scanning (tokenize) error raised during evaluation.
"
Class {
	#name : #ErlangEvalScanError,
	#superclass : #ErlangEvalError,
	#instVars : [
		'errorInfo',
		'errorLocation'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #'as yet unclassified' }
ErlangEvalScanError >> erlangErrorMessage [
	^ 'Scan error {1}' format: { errorInfo third printString }
]

{ #category : #accessing }
ErlangEvalScanError >> errorInfo [
	^ errorInfo
]

{ #category : #accessing }
ErlangEvalScanError >> errorInfo: anObject [
	errorInfo := anObject
]

{ #category : #accessing }
ErlangEvalScanError >> errorLocation [
	^ errorLocation
]

{ #category : #accessing }
ErlangEvalScanError >> errorLocation: anObject [
	errorLocation := anObject
]
