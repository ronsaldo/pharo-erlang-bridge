Class {
	#name : #ErlProcess,
	#superclass : #Object,
	#instVars : [
		'client',
		'name'
	],
	#category : #'Erlang-Bridge-Process'
}

{ #category : #'instance creation' }
ErlProcess class >> for: aClient named: aProcessName [
	^ self new client: aClient; name: aProcessName
]

{ #category : #accessing }
ErlProcess >> client [
	^ client
]

{ #category : #accessing }
ErlProcess >> client: anObject [
	client := anObject
]

{ #category : #evaluating }
ErlProcess >> evalValue: anErlangCode [
	^ client evalValue: anErlangCode bindings: { { #SelfProcess . name } } asErlangList
]

{ #category : #accessing }
ErlProcess >> name [
	^ name
]

{ #category : #accessing }
ErlProcess >> name: anObject [
	name := anObject
]

{ #category : #printing }
ErlProcess >> printOn: aStream [
	aStream nextPutAll: self class name; nextPutAll: ' named: '; print: name
]

{ #category : #evaluating }
ErlProcess >> state [
	^ self evalValue: 'sys:get_state(SelfProcess).'
]

{ #category : #evaluating }
ErlProcess >> status [
	^ self evalValue: 'sys:get_status(SelfProcess).'
]
