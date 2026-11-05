Extension { #name : 'TLEllipse' }

{ #category : '*Telescope-Bloc' }
TLEllipse class >> headOutlineAt: aTip direction: aDirection length: aLength width: aWidth [

	^ self circleHeadOutlineAt: aTip direction: aDirection length: aLength
]

{ #category : '*Telescope-Bloc' }
TLEllipse class >> outlineOfExtent: anExtent [
	"The vertex is the right end of the horizontal axis, and the co-vertex the top end of the vertical one. Geometry works with its own points"

	^ GEllipse center: (anExtent / 2) asGPoint vertex: (anExtent x @ (anExtent y / 2)) asGPoint coVertex: (anExtent x / 2 @ 0) asGPoint
]
