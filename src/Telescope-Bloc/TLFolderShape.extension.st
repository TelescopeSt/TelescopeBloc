Extension { #name : 'TLFolderShape' }

{ #category : '*Telescope-Bloc' }
TLFolderShape class >> headPolygonPoints [
	"The folder of a node is upright, as a head it is turned to have its top forward"

	^ self polygonPointsTurnedByAQuarter
]
