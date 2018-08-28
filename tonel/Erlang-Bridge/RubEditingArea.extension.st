Extension { #name : #RubEditingArea }

{ #category : #'*Erlang-Bridge' }
RubEditingArea >> beForErlangScripting [
	self editingMode: RubErlangScriptingMode new
]
