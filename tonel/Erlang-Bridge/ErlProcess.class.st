"
I am a wrapper around an Erlang process.
"
Class {
	#name : #ErlProcess,
	#superclass : #ErlWrapperObject,
	#instVars : [
		'name',
		'pid'
	],
	#category : #'Erlang-Bridge-Process'
}

{ #category : #'instance creation' }
ErlProcess class >> for: aClient named: aProcessName [
	^ self new client: aClient; name: aProcessName
]

{ #category : #evaluating }
ErlProcess >> erlangDoItBindings [
	^ {#SelfProcess -> name}
]

{ #category : #evaluating }
ErlProcess >> evalValue: anErlangCode [
	^ client evalValue: anErlangCode bindings: { { #SelfProcess . name } } asErlangList
]

{ #category : #evaluating }
ErlProcess >> evalValueWithPID: anErlangCode [
	^ client evalValue: anErlangCode bindings: { { #SelfProcess . self pid } } asErlangList
]

{ #category : #'as yet unclassified' }
ErlProcess >> gtInspectorStateIn: composite [
	<gtInspectorPresentationOrder: -10> 
	(self respondsTo: #decodedState) ifFalse: [ ^ self ].
	
	^ composite fastTable
		title: 'State';
		display: [ self decodedState ];
		column: 'Name' evaluated: [ :assoc | assoc key ];
		column: 'Value' evaluated: [ :assoc | GTObjectPrinter asTruncatedTextFrom: assoc value ];
		send: [ :assoc | assoc value ]
]

{ #category : #accessing }
ErlProcess >> name [
	^ name
]

{ #category : #accessing }
ErlProcess >> name: anObject [
	name := anObject
]

{ #category : #evaluating }
ErlProcess >> pid [
	^ pid ifNil: [
		pid := name isErlPID ifTrue: [
			name
		] ifFalse: [
			self evalValue: 'whereis(SelfProcess).'
		]
	]
]

{ #category : #printing }
ErlProcess >> printOn: aStream [
	aStream nextPutAll: self class name; nextPutAll: ' named: '; print: name
]

{ #category : #evaluating }
ErlProcess >> processInfo [
	^ self evalValueWithPID: 'process_info(SelfProcess).'
]

{ #category : #evaluating }
ErlProcess >> state [
	^ self evalValue: 'sys:get_state(SelfProcess).'
]

{ #category : #evaluating }
ErlProcess >> status [
	^ self evalValue: 'sys:get_status(SelfProcess).'
]

{ #category : #accessing }
ErlProcess >> wrappedObject [
	^ name
]
