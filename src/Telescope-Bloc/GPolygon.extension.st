Extension { #name : 'GPolygon' }

{ #category : '*Telescope-Bloc' }
GPolygon >> asBlocGeometry [
	"The vertices are in the coordinates of the Bloc element which gets the geometry"

	^ BlPolygonGeometry vertices: (self vertices collect: #asPoint)
]

{ #category : '*Telescope-Bloc' }
GPolygon >> translatedCopyBy: aPoint [
	"A new polygon moved by the point. translateBy: moves the polygon itself, and a copy shares the points of the original"

	^ GPolygon vertices: (self vertices collect: [ :vertex | vertex asPoint + aPoint ])
]
