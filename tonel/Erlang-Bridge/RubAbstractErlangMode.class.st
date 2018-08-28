Class {
	#name : #RubAbstractErlangMode,
	#superclass : #RubEditingMode,
	#instVars : [
		'stylerDecorator'
	],
	#category : #'Erlang-Bridge-Editor'
}

{ #category : #'initialize-release' }
RubAbstractErlangMode >> createStyleDecorator [
	^ self phanideStyler ifNotNil: [:styler | styler newStyleDecorator]
]

{ #category : #accessing }
RubAbstractErlangMode >> editorClass [
	^ RubErlangTextEditor
]

{ #category : #accessing }
RubAbstractErlangMode >> phanideStyler [
	^ (Smalltalk globals at: #PhanideStyler ifAbsent: [ ^ nil ]) forExtension: 'erl'
]

{ #category : #'initialize-release' }
RubAbstractErlangMode >> stylerDecorator [
	^ stylerDecorator ifNil: [ stylerDecorator := self createStyleDecorator ]
]

{ #category : #'initialize-release' }
RubAbstractErlangMode >> updateTextAreaWhenPlugged [
	self withStyler.
	super updateTextAreaWhenPlugged
]

{ #category : #'initialize-release' }
RubAbstractErlangMode >> updateTextAreaWhenUnplugged [
	self withoutStyler.
	super updateTextAreaWhenUnplugged


]

{ #category : #'initialize-release' }
RubAbstractErlangMode >> withStyler [
	self textArea withDecorator: self stylerDecorator
]

{ #category : #'initialize-release' }
RubAbstractErlangMode >> withoutStyler [
	self textArea withoutDecorator: self stylerDecorator
]
