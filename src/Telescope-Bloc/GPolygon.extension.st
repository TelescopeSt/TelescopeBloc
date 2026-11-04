Extension { #name : 'GPolygon' }

{ #category : '*Telescope-Bloc' }
GPolygon >> asBlocGeometry [
	"The vertices are in the coordinates of the Bloc element which gets the geometry"

	^ BlPolygonGeometry vertices: (self vertices collect: #asPoint)
]
