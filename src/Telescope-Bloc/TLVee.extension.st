Extension { #name : 'TLVee' }

{ #category : '*Telescope-Bloc' }
TLVee class >> headPolygonPoints [
	"The vee of a node points down, and the vee of a head points forward"

	^ self polygonPoints collect: [ :point | point x @ point y negated ]
]
