Class {
	#name : #GLMMorphicErlangScriptRenderer,
	#superclass : #GLMMorphicErlangCodeRenderer,
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #callbacks }
GLMMorphicErlangScriptRenderer >> actOnVariableBindingsAccessRequest: ann [ 

	ann action ifNotNil: [ :aBlock |
		aBlock cull: textModel variableBindings ]
]

{ #category : #callbacks }
GLMMorphicErlangScriptRenderer >> actOnVariableBindingsUpdated: ann [ 

	textModel variableBindings: nil.
	textModel appendVariableBinding: ann presentation variableBindings.
	"textMorph shoutStyler style: textMorph text."
]

{ #category : #rendering }
GLMMorphicErlangScriptRenderer >> modelFor: aPresentation [

	^ (super modelFor: aPresentation)
		highlightErlang: true;
		bindingsStrategy: self workspaceBindingsStrategy;
		appendVariableBinding: aPresentation variableBindings;
		yourself
]

{ #category : #rendering }
GLMMorphicErlangScriptRenderer >> morph [
	|morph|
	morph := RubScrolledTextMorph new
		getSelectionSelector: #primarySelectionInterval;
		model: textModel;
		beForErlangScripting;
		textFont: StandardFonts codeFont;
		color: Smalltalk ui theme backgroundColor;
		notificationStrategy: GLMPopperNotificationStrategy new;
		yourself.
	"Without forcing styling explicitly the first time the presentation is opened with some text on it the styling is wrong."
	"(morph textArea decoratorNamed: #shoutStyler) ifNotNil: [ :styler | styler refreshStyling ]."
	^ morph
]

{ #category : #private }
GLMMorphicErlangScriptRenderer >> registerEventsForPresentation: aPresentation [

	super registerEventsForPresentation: aPresentation.
	
	aPresentation when: GLMVariableBindingsChanged send: #actOnVariableBindingsUpdated: to: self.
	aPresentation when: GLMVariableBindingsAccessRequest send: #actOnVariableBindingsAccessRequest: to: self.
	
]

{ #category : #private }
GLMMorphicErlangScriptRenderer >> workspaceBindingsStrategy [

	^ [ :currentBindings :aString :aTextModel |
			(currentBindings includesKey: aString)
					ifFalse: [currentBindings add: (Association key: aString asSymbol) ].
			currentBindings associationAt: aString
		]
]
