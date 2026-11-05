Extension { #name : 'TLSegmentsCurve' }

{ #category : '*Telescope-Bloc' }
TLSegmentsCurve class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset [
	"Segments with right angles, spread when other connections join the same nodes"

	^ self
		  blocRouteFrom: aSourceOutline
		  to: aTargetOutline
		  offset: anOffset
		  obstacles: #(  )
]

{ #category : '*Telescope-Bloc' }
TLSegmentsCurve class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"Segments with right angles, spread when other connections join the same nodes, and around the other nodes when they are in the way"

	^ TLBlocConnectionTaxi
		  from: aSourceOutline
		  to: aTargetOutline
		  offset: anOffset
		  obstacles: someRectangles
]
