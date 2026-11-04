Extension { #name : 'TLSimpleShape' }

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> isAvailableForBlocNode [
	"Some shapes, such as the circle, the square or the arrow, are only for connections"

	^ [
		  self outlineOfExtent: 1 @ 1.
		  true ]
		  on: TLNotSupportedFunctionalityException
		  do: [ false ]
]

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> nodePointFrom: aPolygonPoint extent: anExtent [
	"Converts a point of polygonPoints, in [-1, 1] with the y axis going up, to the coordinates of a node of the given extent"

	^ aPolygonPoint x + 1 / 2 * anExtent x @ (1 - aPolygonPoint y / 2 * anExtent y)
]

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> outlineOfExtent: anExtent [
	"Answers the Geometry project shape of the shape in a node of the given extent, in the coordinates of the node: its origin is the top left corner and the y axis goes down. A shape defining polygonPoints, in [-1, 1] with the y axis going up, is a polygon"

	^ GPolygon vertices: (self polygonPoints collect: [ :point | self nodePointFrom: point extent: anExtent ])
]
