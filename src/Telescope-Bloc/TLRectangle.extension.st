Extension { #name : 'TLRectangle' }

{ #category : '*Telescope-Bloc' }
TLRectangle class >> outlineOfExtent: anExtent [

	^ GRectangle origin: 0 @ 0 corner: anExtent
]
