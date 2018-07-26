"
I represent the state of a Erlang call message. I am conceptually similar to gen_server:call.

"
Class {
	#name : #ErlangBridgeCallState,
	#superclass : #Object,
	#instVars : [
		'serial',
		'semaphore',
		'response'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #initialization }
ErlangBridgeCallState >> initialize [
	semaphore := Semaphore new.
]

{ #category : #accessing }
ErlangBridgeCallState >> serial [
	^ serial
]

{ #category : #accessing }
ErlangBridgeCallState >> serial: anObject [
	serial := anObject
]

{ #category : #signalling }
ErlangBridgeCallState >> setResponse: aResponse [
	response := aResponse.
	semaphore signal
]

{ #category : #signalling }
ErlangBridgeCallState >> signalResponse [
	semaphore signal
]

{ #category : #signalling }
ErlangBridgeCallState >> waitResponse [
	semaphore wait.
	^ response
]
