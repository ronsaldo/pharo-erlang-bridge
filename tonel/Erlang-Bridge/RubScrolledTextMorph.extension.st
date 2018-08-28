Extension { #name : #RubScrolledTextMorph }

{ #category : #'*Erlang-Bridge' }
RubScrolledTextMorph >> beForErlangScripting [
    self textArea beForErlangScripting.
    self textArea font: StandardFonts codeFont

]
