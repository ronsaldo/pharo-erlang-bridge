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

{ #category : #evaluating }
ErlWrapperObject >> erlangDoItBindings [
	^ { #Self -> self wrappedObject }
]

{ #category : #evaluating }
ErlWrapperObject >> evalValue: anErlangCode [
	^ client evalValue: anErlangCode bindings: { { #Self . self wrappedObject } } asErlangList
]

{ #category : #'gt-inspector-extension' }
ErlWrapperObject >> gtInspectorWorkspace: composite [
	<gtInspectorPresentationOrder: 0> 
	^ composite erlangScript
			title: 'Workspace';
			client: [self client];
			variableBindings: [ self erlangDoItBindings ];
			display: [ :object | ''];
			installDefaultSelectionActions
]

{ #category : #accessing }
ErlWrapperObject >> wrappedObject [
	^ ErlCons empty
]
