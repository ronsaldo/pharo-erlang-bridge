Class {
	#name : #ErlangEvalError,
	#superclass : #Error,
	#instVars : [
		'erlangError'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #accessing }
ErlangEvalError >> erlangError [
	^ erlangError
]

{ #category : #accessing }
ErlangEvalError >> erlangError: anObject [
	erlangError := anObject
]

{ #category : #accessing }
ErlangEvalError >> messageText [
	^ messageText ifNil: [messageText := 'Got Erlang error on eval: {1}' format: { erlangError printString }]
]
