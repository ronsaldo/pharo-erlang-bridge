Class {
	#name : #GTErlangPlayPage,
	#superclass : #GTPlayPage,
	#instVars : [
		'client'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #accessing }
GTErlangPlayPage >> client [
	^ client
]

{ #category : #accessing }
GTErlangPlayPage >> client: anObject [
	client := anObject
]
