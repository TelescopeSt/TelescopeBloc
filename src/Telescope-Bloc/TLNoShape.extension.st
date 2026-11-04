Extension { #name : 'TLNoShape' }

{ #category : '*Telescope-Bloc' }
TLNoShape class >> headOutlineAt: aTip direction: aDirection length: aLength width: aWidth [
	"A connection without a head shape draws nothing"

	^ nil
]

{ #category : '*Telescope-Bloc' }
TLNoShape class >> outlineOfExtent: anExtent [
	"A node without a shape has no outline: it only has a label"

	^ nil
]
