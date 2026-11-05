Extension { #name : 'TLSegmentsCurve' }

{ #category : '*Telescope-Bloc' }
TLSegmentsCurve class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset [
	"Segments with right angles, whatever the other connections between the same nodes"

	^ TLBlocConnectionTaxi from: aSourceOutline to: aTargetOutline
]
