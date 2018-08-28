Extension { #name : #GLMCompositePresentation }

{ #category : #'*Erlang-Bridge' }
GLMCompositePresentation >> erlangScript [
	^ self custom: GLMRubricErlangScriptPresentation new
]
