"
I am the route of a connection with the curve style segments of Telescope: segments with right angles, drawn with a BlPolylineGeometry. The line goes out of the source along the axis on which the nodes are the most apart, to the middle, along the other axis, then to the target, so it has two turns. The label is next to the middle segment and the head follows the last one.
"
Class {
	#name : 'TLBlocConnectionTaxi',
	#superclass : 'TLBlocConnectionSegment',
	#instVars : [
		'points'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'route' }
TLBlocConnectionTaxi >> endDirection [
	"The direction of the last segment which is not empty"

	points size to: 2 by: -1 do: [ :index | (self unitVectorOf: (points at: index) - (points at: index - 1)) ifNotNil: [ :direction | ^ direction ] ].
	^ nil
]

{ #category : 'route' }
TLBlocConnectionTaxi >> geometryRelativeTo: aPoint [

	^ BlPolylineGeometry vertices: (points collect: [ :point | point - aPoint ])
]

{ #category : 'route' }
TLBlocConnectionTaxi >> join: aSourceOutline to: aTargetOutline [
	"The line goes out of the border of the source along the axis on which the nodes are the most apart, to the middle, then along the other axis, then along the first axis to the border of the target: it only has right angles. Each end is where the line along the axis from the center of its node leaves the node"

	| sourceCenter targetCenter delta axis middle |
	sourceCenter := self centerOf: aSourceOutline.
	targetCenter := self centerOf: aTargetOutline.
	sourceCenter = targetCenter ifTrue: [
			start := end := sourceCenter.
			points := {
				          start.
				          start.
				          end.
				          end }.
			^ self ].
	delta := targetCenter - sourceCenter.
	axis := delta x abs >= delta y abs
		        ifTrue: [ 1 @ 0 ]
		        ifFalse: [ 0 @ 1 ].
	start := self
		         borderPointOf: aSourceOutline
		         on: (GLine through: sourceCenter asGPoint and: (sourceCenter + axis) asGPoint)
		         nearestTo: targetCenter
		         orElse: sourceCenter.
	end := self
		       borderPointOf: aTargetOutline
		       on: (GLine through: targetCenter asGPoint and: (targetCenter + axis) asGPoint)
		       nearestTo: sourceCenter
		       orElse: targetCenter.
	middle := start + end / 2.
	points := axis x = 1
		          ifTrue: [
				          {
					          start.
					          (middle x @ start y).
					          (middle x @ end y).
					          end } ]
		          ifFalse: [
				          {
					          start.
					          (start x @ middle y).
					          (end x @ middle y).
					          end } ]
]

{ #category : 'route' }
TLBlocConnectionTaxi >> middleDirection [
	"The direction of the middle segment, or the one of the whole line when it is empty, which is the case when the nodes are aligned"

	| direction |
	direction := points third - points second.
	^ direction isZero
		  ifTrue: [ end - start ]
		  ifFalse: [ direction ]
]

{ #category : 'route' }
TLBlocConnectionTaxi >> middlePoint [
	"The middle of the middle segment, which is the one between the two turns"

	^ points second + points third / 2
]

{ #category : 'route' }
TLBlocConnectionTaxi >> points [
	"The ends, and the two points where the line turns"

	^ points
]

{ #category : 'route' }
TLBlocConnectionTaxi >> shiftBy: aVector [

	super shiftBy: aVector.
	points := points collect: [ :point | point + aVector ]
]
