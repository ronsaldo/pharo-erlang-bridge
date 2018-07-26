"
An ErlConsTest is a test class for testing the behavior of ErlCons
"
Class {
	#name : #ErlConsTest,
	#superclass : #TestCase,
	#category : #'Erlang-Bridge-Tests'
}

{ #category : #tests }
ErlConsTest >> testAsErlangList [
	| list |
	list := #(1 2) asErlangList.
	self assert: list head equals: 1.
	self assert: list tail head equals: 2.
	self assert: list tail tail equals: ErlCons empty.
]

{ #category : #tests }
ErlConsTest >> testEmptyAsErlangList [
	self assert: #() asErlangList equals: ErlCons empty.
]

{ #category : #tests }
ErlConsTest >> testEmptySize [
	self assert: ErlCons empty size equals: 0.
]

{ #category : #tests }
ErlConsTest >> testNonEmptySize [
	self assert: #(1 2 3) asErlangList size equals: 3.
]
