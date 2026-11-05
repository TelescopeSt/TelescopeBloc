Extension { #name : 'TLCurveStyle' }

{ #category : '*Telescope-Bloc' }
TLCurveStyle class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"The route of a connection, which goes around the rectangles of the other nodes when its style can: only the segments do by default"

	^ self blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset
]
