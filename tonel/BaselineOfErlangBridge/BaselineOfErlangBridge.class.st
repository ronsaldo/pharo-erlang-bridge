Class {
	#name : #BaselineOfErlangBridge,
	#superclass : #BaselineOf,
	#category : #BaselineOfErlangBridge
}

{ #category : #baselines }
BaselineOfErlangBridge >> baseline: spec [
	<baseline>

	spec for: #common do: [
		spec baseline: 'Phanide' with: [
				spec
					repository: 'github://ronsaldo/phanide/tonel' ].

		spec
			package: 'Erlang-Bridge' with: [
				spec requires: #(Phanide)
			].
	].
]
