Class {
	#name : #GTErlangPlayground,
	#superclass : #GTPlayground,
	#instVars : [
		'client'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #opening }
GTErlangPlayground class >> openForClient: aClient [
	"self open"
	| page |
	page := GTErlangPlayPage new client: aClient.
	^ self openOn: page
]

{ #category : #'instance creation' }
GTErlangPlayground class >> title [
	^ 'Erlang Playground'
]

{ #category : #building }
GTErlangPlayground >> codePresentationIn: composite [
	^ composite erlangScript
		client: self entity client;
		yourself
]
