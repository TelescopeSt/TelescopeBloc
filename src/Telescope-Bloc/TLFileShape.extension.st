Extension { #name : 'TLFileShape' }

{ #category : '*Telescope-Bloc' }
TLFileShape class >> headPolygonPoints [
	"The file of a node is upright, as a head it is turned to have its top forward"

	^ self polygonPointsTurnedByAQuarter
]
