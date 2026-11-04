Extension { #name : 'GEllipse' }

{ #category : '*Telescope-Bloc' }
GEllipse >> asBlocGeometry [
	"The ellipse is as large as the Bloc element which gets the geometry"

	^ BlEllipseGeometry new
]
