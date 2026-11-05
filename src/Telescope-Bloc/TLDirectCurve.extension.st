Extension { #name : 'TLDirectCurve' }

{ #category : '*Telescope-Bloc' }
TLDirectCurve class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset [
	"A direct curve is a straight line, whatever the other connections between the same nodes"

	^ TLBlocConnectionSegment from: aSourceOutline to: aTargetOutline
]
