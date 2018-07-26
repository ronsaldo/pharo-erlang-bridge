Class {
	#name : #ErlangEvalExceptionError,
	#superclass : #ErlangEvalError,
	#instVars : [
		'exception'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #accessing }
ErlangEvalExceptionError >> exception [
	^ exception
]

{ #category : #accessing }
ErlangEvalExceptionError >> exception: anObject [
	exception := anObject
]

{ #category : #accessing }
ErlangEvalExceptionError >> messageText [
	^ messageText ifNil: [messageText := 'Got Erlang exception on eval: {1}' format: { erlangError printString }]
]
