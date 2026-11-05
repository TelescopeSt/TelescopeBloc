Extension { #name : 'TLBezierCurve' }

{ #category : '*Telescope-Bloc' }
TLBezierCurve class >> blocRouteFrom: aSourceOutline to: aTargetOutline offset: anOffset [
	"A Bezier curve is a straight line for a connection which is alone between its nodes, and an arc when there are other connections between them: the offset spreads them, so that they do not overlap"

	^ anOffset = 0
		  ifTrue: [ TLBlocConnectionSegment from: aSourceOutline to: aTargetOutline ]
		  ifFalse: [ TLBlocConnectionArc from: aSourceOutline to: aTargetOutline offset: anOffset ]
]
