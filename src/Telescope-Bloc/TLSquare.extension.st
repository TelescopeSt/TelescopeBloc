Extension { #name : 'TLSquare' }

{ #category : '*Telescope-Bloc' }
TLSquare class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Square is only for connections; use Rectangle'
]
