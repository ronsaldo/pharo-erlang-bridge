Extension { #name : #GLMMorphicRenderer }

{ #category : #'*Erlang-Bridge' }
GLMMorphicRenderer >> renderErlangScriptPresentation: anErlangScriptPresentation [ 
	^ GLMMorphicErlangScriptRenderer render: anErlangScriptPresentation from: self
]
