"
I am a client for the Erlang bridge.
"
Class {
	#name : #ErlangBridgeClient,
	#superclass : #Object,
	#instVars : [
		'socket',
		'callStatesMutex',
		'nextCallSerialNumber',
		'pendingCallsDictionary',
		'sendingProcess',
		'receptionProcess',
		'sendingQueue',
		'pendingMessagesToSendSemaphore'
	],
	#category : #'Erlang-Bridge-Client'
}

{ #category : #'connection open/close' }
ErlangBridgeClient class >> connectToHostNamed: hostName port: port [
	^ self new connectToHostNamed: hostName port: port
]

{ #category : #'node communication' }
ErlangBridgeClient >> call: request [
	| callState |
	callState := self newCallRequest.
	self sendMessage: { #call . callState serial . request }.
	^ callState waitResponse
]

{ #category : #'node communication' }
ErlangBridgeClient >> cast: request [
	^ self sendMessage: { #cast . request }
]

{ #category : #'initialize-release' }
ErlangBridgeClient >> close [
	pendingMessagesToSendSemaphore consumeAllSignals.
	sendingProcess terminate.
	receptionProcess terminate.
	socket close.
]

{ #category : #'connection open/close' }
ErlangBridgeClient >> connectToHostNamed: hostName port: port [
	socket := Socket newTCP.
	socket connectToHostNamed: hostName port: port;
		sendData: 'PHRO'.
		
	self
		startSendingProcess;
		startReceptionProcess
	
]

{ #category : #evaluating }
ErlangBridgeClient >> convertEvalResultError: erlangError [
	erlangError second = #exception ifTrue: [
		^ ErlangEvalExceptionError new
			erlangError: erlangError;
			exception: erlangError third;
			yourself
	].

	erlangError second = #parse ifTrue: [
		^ ErlangEvalParseError new
			erlangError: erlangError;
			errorInfo: erlangError third;
			yourself
	].

	erlangError second = #scan ifTrue: [
		^ ErlangEvalScanError new
			erlangError: erlangError;
			errorInfo: erlangError third;
			errorLocation: erlangError fourth;
			yourself
	].

	^ ErlangEvalError new
		erlangError: erlangError;
		yourself
]

{ #category : #evaluating }
ErlangBridgeClient >> eval: aString [
	^ self eval: aString bindings: ErlCons empty
]

{ #category : #evaluating }
ErlangBridgeClient >> eval: aString bindings: bindings [
	^ self call: { #eval . aString . bindings }
]

{ #category : #evaluating }
ErlangBridgeClient >> evalValue: aString [
	^ self processEvalResultValue: (self eval: aString)
]

{ #category : #evaluating }
ErlangBridgeClient >> evalValue: aString bindings: bindings [
	^ self processEvalResultValue: (self eval: aString bindings: bindings)
]

{ #category : #'gt-inspector-extension' }
ErlangBridgeClient >> gtInspectorRegisteredProcessesIn: composite [
	<gtInspectorPresentationOrder: 2> 
	^ composite fastTable
		title: 'Registered Processes';
		display: [ self registeredProcesses ];
		column: 'Process' evaluated: [ :value | GTObjectPrinter asTruncatedTextFrom: value name ]
]

{ #category : #'gt-inspector-extension' }
ErlangBridgeClient >> gtInspectorWorkspace: composite [
	<gtInspectorPresentationOrder: 0> 
	^ composite erlangScript
			title: 'Workspace';
			client: [self];
			display: [ :object | ''];
			installDefaultSelectionActions
]

{ #category : #initialization }
ErlangBridgeClient >> initialize [
	super initialize.
	callStatesMutex := Semaphore forMutualExclusion.
	nextCallSerialNumber := 0.
	pendingCallsDictionary := WeakValueDictionary new.
	sendingQueue := WaitfreeQueue new. 
	pendingMessagesToSendSemaphore := Semaphore new.
]

{ #category : #'instance creation' }
ErlangBridgeClient >> newCallRequest [
	| callState |
	callStatesMutex critical: [ 
		callState := ErlangBridgeCallState new serial: nextCallSerialNumber.
		nextCallSerialNumber := nextCallSerialNumber + 1.		
		pendingCallsDictionary at: callState serial put: callState
	].

	^ callState

]

{ #category : #playground }
ErlangBridgeClient >> playground [
	^ GTErlangPlayground openForClient: self
]

{ #category : #private }
ErlangBridgeClient >> processCallSerial: callSerial response: callResponse [
	| callState |
	callStatesMutex critical: [ 
		callState := pendingCallsDictionary at: callSerial.
		pendingCallsDictionary removeKey: callSerial.
		callState ifNotNil: [
			callState setResponse: callResponse
		]
	]
]

{ #category : #evaluating }
ErlangBridgeClient >> processEvalResult: evalResult [
	| evalResultType |
	self assert: evalResult isArray.
	evalResultType := evalResult first.
	evalResultType == #value ifTrue: [ ^ evalResult ].
	evalResultType == #error ifTrue: [ ^ (self convertEvalResultError: evalResult) signal ].
	self error: 'Unsupported eval result.'
]

{ #category : #evaluating }
ErlangBridgeClient >> processEvalResultValue: evalResult [
	^ (self processEvalResult: evalResult) second
]

{ #category : #private }
ErlangBridgeClient >> processReceivedMessage: message [
	(message isArray and: [message size = 3 and: [message first == #callResponse]]) ifTrue: [ 
		self processCallSerial: message second response: message third
	].

]

{ #category : #private }
ErlangBridgeClient >> receptionProcessIteration [
	| messageSize encodedMessage message messageSizeBuffer |
	"Receive the message size"
	messageSizeBuffer := ByteArray new: 4.
	socket receiveDataInto: messageSizeBuffer.
	messageSize := messageSizeBuffer unsignedLongAt: 1 bigEndian: true.

	"Receive the message"
	encodedMessage := ByteArray new: messageSize.
	socket receiveDataInto: encodedMessage.

	message := encodedMessage erlangETFDecoded.
	self processReceivedMessage: message.
]

{ #category : #'system debugging' }
ErlangBridgeClient >> registeredProcesses [
	^ (self evalValue: 'registered().')
		collect: [ :name | ErlProcess for: self named: name ] as: Array
]

{ #category : #'node communication' }
ErlangBridgeClient >> sendEncodedMessage: encodedMessage [
	sendingQueue nextPut: encodedMessage.
	pendingMessagesToSendSemaphore signal
]

{ #category : #'node communication' }
ErlangBridgeClient >> sendMessage: content [
	^ self sendEncodedMessage: content asErlangETF
]

{ #category : #private }
ErlangBridgeClient >> sendingProcessIteration [
	| nextMessage size |
	size := ByteArray new: 4.
	pendingMessagesToSendSemaphore consumeAllSignals.
	[nextMessage := sendingQueue nextOrNil] whileNotNil: [ 
		size unsignedLongAt: 1 put: nextMessage size bigEndian: true.
		socket sendData: size; sendData: nextMessage.
	].
  
	pendingMessagesToSendSemaphore wait
]

{ #category : #private }
ErlangBridgeClient >> startReceptionProcess [
	| session |
	session := Smalltalk session.
	sendingProcess := [ 
		[socket isNotNil and: [session == Smalltalk session]] whileTrue: [
			self receptionProcessIteration
		]
	] fork
]

{ #category : #private }
ErlangBridgeClient >> startSendingProcess [
	| session |
	session := Smalltalk session.
	sendingProcess := [ 
		[socket isNotNil and: [session == Smalltalk session]] whileTrue: [
			self sendingProcessIteration
		]
	] fork
]
