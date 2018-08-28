Class {
	#name : #GLMMorphicErlangCodeRenderer,
	#superclass : #GLMMorphicRubricTextRenderer,
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #callbacks }
GLMMorphicErlangCodeRenderer >> actOnEvaluateSelection: ann [ 

	"We get here as a result of an announcement.
	If we do not defer the execution and an exception is triggered by the execution of the code
	then resuming the execution in the debugger will trigger an error when unwinding the stack."
	ann isSyncronous ifTrue: [ 
		textMorph textArea editor evaluateSelectionAndDo: ann action.
		^ self ]. 
	UIManager default defer: [ 
		textMorph textArea editor evaluateSelectionAndDo: ann action ]
	
]

{ #category : #callbacks }
GLMMorphicErlangCodeRenderer >> actOnHighlightAndEvaluate: ann [ 

	"We get here as a result of an announcement.
	If we do not defer the execution and an exception is triggered by the execution of the code
	then resuming the execution in the debugger will trigger an error when unwinding the stack."
	UIManager default defer: [ 
		textMorph textArea handleEdit: [
			textMorph textArea editor highlightEvaluateAndDo: ann action .
			"textMorph shoutStyler style: textMorph text." ] ]
]

{ #category : #callbacks }
GLMMorphicErlangCodeRenderer >> evaluateAndPopPrintHighlight [

	GLMPrintPopper
		installAlarm: #popupPrint
		for: self
]

{ #category : #callbacks }
GLMMorphicErlangCodeRenderer >> evaluateAndPrintSelection [

	UIManager default defer: [ 
		textMorph textArea editor printIt ]
	
]

{ #category : #rendering }
GLMMorphicErlangCodeRenderer >> modelFor: aPresentation [
	| highlightContext |
	highlightContext := aPresentation highlightErlangContext. 
	^ GLMRubricErlangTextModel new
		glamourPresentation: aPresentation;
		client: aPresentation client;
		highlightErlang: highlightContext notNil;
		highlightErlangContext: highlightContext;
		yourself
]

{ #category : #'events-alarms' }
GLMMorphicErlangCodeRenderer >> popupPrint [
	"Evaluates selected code and prints it in a popper"
	textMorph textArea editor highlightEvaluateAndDo: [ :result | 
		"textMorph shoutStyler style: textMorph text."
		GLMPrintPopper new 
			openFromRubric: textMorph textArea withResult: result ]
]

{ #category : #private }
GLMMorphicErlangCodeRenderer >> registerEventsForPresentation: aPresentation [
	super registerEventsForPresentation: aPresentation.
	aPresentation when: GLMSelectCurrentLine send: #selectLine to: self.
	aPresentation when: GLMEvaluateSelection send: #actOnEvaluateSelection: to: self.
	aPresentation when: GLMHighlightAndEvaluate send: #actOnHighlightAndEvaluate: to: self.
	"aPresentation when: GLMCompileText send: #actOnCompileText: to: self.
	aPresentation when: GLMDebugSelection send: #debugHighlightedText to: self.
	aPresentation when: GLMProfileSelection send: #profileHighlightedText to: self."
	aPresentation when: GLMPrintSelection send: #evaluateAndPopPrintHighlight to: self
]

{ #category : #callbacks }
GLMMorphicErlangCodeRenderer >> selectLine [
	
	textMorph textArea editor lineSelectAndEmptyCheck: [^ nil]
]
