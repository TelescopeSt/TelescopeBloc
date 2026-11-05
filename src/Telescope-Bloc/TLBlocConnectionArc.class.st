"
I am the route of a connection which is an arc: a quadratic Bezier curve, drawn with a BlBezierCurveGeometry. My control point is away from the middle of the chord, to the left of the direction of the connection when the offset is positive, and my ends are where the lines from the centers of the nodes to the control point leave them, so that the curve is tangent to them. A Bezier curve of Telescope is an arc when other connections join the same two nodes: the connector gives each of them an offset, so that they do not overlap.
"
Class {
	#name : 'TLBlocConnectionArc',
	#superclass : 'TLBlocConnectionSegment',
	#instVars : [
		'control',
		'offset'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
TLBlocConnectionArc class >> from: aSourceOutline to: aTargetOutline offset: anOffset [
	"The outlines are Geometry project shapes, in the same coordinates"

	^ self new
		  join: aSourceOutline to: aTargetOutline offset: anOffset;
		  yourself
]

{ #category : 'route' }
TLBlocConnectionArc >> control [
	"The control point of the Bezier curve"

	^ control
]

{ #category : 'route' }
TLBlocConnectionArc >> endDirection [
	"The tangent of the curve at its end, from the control point"

	^ (self unitVectorOf: end - control) ifNil: [ self unitVectorOf: end - start ]
]

{ #category : 'route' }
TLBlocConnectionArc >> geometryRelativeTo: aPoint [

	^ BlBezierCurveGeometry new
		  controlPoints: (self points collect: [ :point | point - aPoint ]);
		  yourself
]

{ #category : 'route' }
TLBlocConnectionArc >> join: aSourceOutline to: aTargetOutline offset: anOffset [
	"The line is a quadratic Bezier curve whose control point is away from the middle of the chord by the offset, to the left of the direction of the line when it is positive. Each end is where the line from the center of its node to the control point leaves the node: the curve is tangent to it"

	| sourceCenter targetCenter middle direction |
	offset := anOffset.
	sourceCenter := self centerOf: aSourceOutline.
	targetCenter := self centerOf: aTargetOutline.
	sourceCenter = targetCenter ifTrue: [
			start := end := control := sourceCenter.
			^ self ].
	middle := sourceCenter + targetCenter / 2.
	direction := targetCenter - sourceCenter.
	control := middle + ((direction y @ direction x negated) normalized * anOffset).
	start := self
		         borderPointOf: aSourceOutline
		         on: (GLine through: sourceCenter asGPoint and: control asGPoint)
		         nearestTo: control
		         orElse: sourceCenter.
	end := self
		       borderPointOf: aTargetOutline
		       on: (GLine through: targetCenter asGPoint and: control asGPoint)
		       nearestTo: control
		       orElse: targetCenter
]

{ #category : 'route' }
TLBlocConnectionArc >> middlePoint [
	"The curve at half of its way"

	^ start + (control * 2) + end / 4
]

{ #category : 'route' }
TLBlocConnectionArc >> points [

	^ {
		  start.
		  control.
		  end }
]

{ #category : 'route' }
TLBlocConnectionArc >> shiftBy: aVector [

	super shiftBy: aVector.
	control := control + aVector
]
