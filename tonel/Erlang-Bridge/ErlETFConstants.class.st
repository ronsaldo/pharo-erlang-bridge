Class {
	#name : #ErlETFConstants,
	#superclass : #SharedPool,
	#classVars : [
		'ATOM_CACHE_REF',
		'ATOM_EXT_DEPRECATED',
		'ATOM_UTF8_EXT',
		'BINARY_EXT',
		'BIT_BINARY_EXT',
		'ETFCompressedTermTag',
		'EXPORT_EXT',
		'ErlETFTags',
		'ErlangETFVersion',
		'FLOAT_EXT',
		'FUN_EXT',
		'INTEGER_EXT',
		'LARGE_BIG_EXT',
		'LARGE_TUPLE_EXT',
		'LIST_EXT',
		'MAP_EXT',
		'NEW_FLOAT_EXT',
		'NEW_FUN_EXT',
		'NEW_REFERENCE_EXT',
		'NIL_EXT',
		'PID_EXT',
		'PORT_EXT',
		'REFERENCE_EXT',
		'SMALL_ATOM_EXT_DEPRECATED',
		'SMALL_ATOM_UTF8_EXT',
		'SMALL_BIG_EXT',
		'SMALL_INTEGER_EXT',
		'SMALL_TUPLE_EXT',
		'STRING_EXT'
	],
	#category : #'Erlang-Bridge-ETF'
}

{ #category : #initialization }
ErlETFConstants class >> initialize [
	"http://erlang.org/doc/apps/erts/erl_ext_dist.html"
	
	ErlangETFVersion := 131.
	ETFCompressedTermTag := 80.

	ErlETFTags := #(
		ATOM_CACHE_REF  82
		SMALL_INTEGER_EXT  97 "UInt8"
		INTEGER_EXT  98 "SInt32 BE"
		FLOAT_EXT  99 "Float string %.20e"
		REFERENCE_EXT  101 "erlang:make_ref/0"
		PORT_EXT  102 "erlang:open_port/2"
		PID_EXT  103 "erlang:spawn/3"
		SMALL_TUPLE_EXT  104
		LARGE_TUPLE_EXT  105
		MAP_EXT  116
		NIL_EXT  106
		STRING_EXT  107
		LIST_EXT  108
		BINARY_EXT  109
		SMALL_BIG_EXT  110
		LARGE_BIG_EXT  111
		NEW_REFERENCE_EXT  114
		FUN_EXT  117
		NEW_FUN_EXT  112
		EXPORT_EXT  113
		BIT_BINARY_EXT  77
		NEW_FLOAT_EXT 70
		ATOM_UTF8_EXT  118
		SMALL_ATOM_UTF8_EXT  119
		ATOM_EXT_DEPRECATED  100
		SMALL_ATOM_EXT_DEPRECATED  115
	).
	
	ErlETFTags pairsDo: [ :tagName :tagValue |
		(self hasClassVarNamed: tagName) ifFalse: [ self addClassVarNamed: tagName ].
		self writeClassVariableNamed: tagName value: tagValue
	].

]
