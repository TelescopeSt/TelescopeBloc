Extension { #name : 'GRectangle' }

{ #category : '*Telescope-Bloc' }
GRectangle >> asBlocGeometry [
	"The rectangle is as large as the Bloc element which gets the geometry"

	^ BlRectangleGeometry new
]
