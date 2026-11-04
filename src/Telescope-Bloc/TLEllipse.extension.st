Extension { #name : 'TLEllipse' }

{ #category : '*Telescope-Bloc' }
TLEllipse class >> outlineOfExtent: anExtent [
	"The vertex is the right end of the horizontal axis, and the co-vertex the top end of the vertical one"

	^ GEllipse center: anExtent / 2 vertex: anExtent x @ (anExtent y / 2) coVertex: anExtent x / 2 @ 0
]
