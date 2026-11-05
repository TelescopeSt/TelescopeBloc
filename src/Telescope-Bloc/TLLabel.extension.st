Extension { #name : 'TLLabel' }

{ #category : '*Telescope-Bloc' }
TLLabel class >> headPolygonPoints [
	"The label of a node points to the right, as a head it is turned to point forward"

	^ self polygonPointsTurnedByAQuarter
]
