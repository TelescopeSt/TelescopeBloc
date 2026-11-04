Extension { #name : 'TLSimpleShape' }

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> circleHeadOutlineAt: aTip direction: aDirection length: aLength [
	"A circle of the diameter of the length, which touches the tip with its border"

	| center radius |
	radius := aLength / 2.
	center := aTip - (aDirection * radius).
	^ GEllipse center: center asGPoint vertex: (center + (radius @ 0)) asGPoint coVertex: (center - (0 @ radius)) asGPoint
]

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> headOutlineAt: aTip direction: aDirection length: aLength width: aWidth [
	"Answers the Geometry project shape of the shape as the head of a connection, or nil when the shape draws nothing. The tip of the head, the top of the polygon points, is on aTip, and the head points along aDirection, a unit vector. The head is aLength long and aWidth wide"

	| normal |
	normal := aDirection y negated @ aDirection x.
	^ GPolygon vertices: (self headPolygonPoints collect: [ :point | aTip + (aDirection * (point y - 1 * aLength / 2)) + (normal * (point x * aWidth / 2)) ])
]

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> headPolygonPoints [
	"The polygon points of the shape as a head, whose top, y of 1, is the tip"

	^ self polygonPoints
]

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

{ #category : '*Telescope-Bloc' }
TLSimpleShape class >> polygonPointsTurnedByAQuarter [
	"The polygon points of the shape turned by 90 degrees counterclockwise, the y axis going up"

	^ self polygonPoints collect: [ :point | point y negated @ point x ]
]
