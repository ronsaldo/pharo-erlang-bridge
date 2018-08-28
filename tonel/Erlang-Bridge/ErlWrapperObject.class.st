"
I am a generic wrapper around an Erlang object.
"
Class {
	#name : #ErlWrapperObject,
	#superclass : #Object,
	#instVars : [
		'client'
	],
	#category : #'Erlang-Bridge-Wrapper'
}

{ #category : #accessing }
ErlWrapperObject >> client [
	^ client
]

{ #category : #accessing }
ErlWrapperObject >> client: anObject [
	client := anObject
]

{ #category : #accessing }
ErlWrapperObject >> wrappedObject [
	^ ErlCons empty
]
