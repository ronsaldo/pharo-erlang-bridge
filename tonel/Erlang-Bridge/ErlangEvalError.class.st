"
I am an Erlang evaluation error.
"
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

{ #category : #'as yet unclassified' }
ErlangEvalError >> erlangErrorMessage [
	^ erlangError printString
]

{ #category : #'as yet unclassified' }
ErlangEvalError >> errorLocation [
	^ 0
]

{ #category : #accessing }
ErlangEvalError >> messageText [
	^ messageText ifNil: [messageText := 'Got Erlang error on eval: {1}' format: { self erlangErrorMessage }]
]

{ #category : #'as yet unclassified' }
ErlangEvalError >> notifyToRequestor: requestor [
	^ self requestor: requestor notify: self erlangErrorMessage at: self errorLocation
]

{ #category : #'as yet unclassified' }
ErlangEvalError >> requestor: requestor notify: aString at: location [
	"Refer to the comment in Object|notify:."

	^ requestor
		ifNil: [SyntaxErrorNotification
					inClass: self methodClass 
					withCode: self methodNode source
					doitFlag: false
					errorMessage: aString
					location: location]
		ifNotNil: [requestor
					notify: aString , ' ->'
					at: location
					in: requestor text]
]
