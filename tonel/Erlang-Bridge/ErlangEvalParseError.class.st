"
I represent an Erlang parsing error raised during evaluation.
"
Class {
	#name : #ErlangEvalParseError,
	#superclass : #ErlangEvalError,
	#instVars : [
		'errorInfo'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #'as yet unclassified' }
ErlangEvalParseError >> erlangErrorMessage [
	^ errorInfo third first
]

{ #category : #accessing }
ErlangEvalParseError >> errorInfo [
	^ errorInfo
]

{ #category : #accessing }
ErlangEvalParseError >> errorInfo: anObject [
	errorInfo := anObject
]

{ #category : #'as yet unclassified' }
ErlangEvalParseError >> errorLocation [
	^ errorInfo first
]
