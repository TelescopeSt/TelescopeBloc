Extension { #name : 'TLNoShape' }

{ #category : '*Telescope-Bloc' }
TLNoShape class >> outlineOfExtent: anExtent [
	"A node without a shape has no outline: it only has a label"

	^ nil
]
