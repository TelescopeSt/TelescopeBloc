Extension { #name : 'TLCircle' }

{ #category : '*Telescope-Bloc' }
TLCircle class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Circle is only for connections; use Ellipse'
]
