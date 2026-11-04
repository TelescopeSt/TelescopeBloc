Extension { #name : 'TLSquare' }

{ #category : '*Telescope-Bloc' }
TLSquare class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Square is only for connections; use Rectangle'
]

{ #category : '*Telescope-Bloc' }
TLSquare class >> polygonPoints [

	^ {
		  (-1 @ 1).
		  (1 @ 1).
		  (1 @ -1).
		  (-1 @ -1) }
]
