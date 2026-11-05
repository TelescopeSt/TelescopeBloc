"
I am the route of a connection between two nodes in its simplest form: a straight line which goes from the border of the outline of the source to the border of the outline of the target, along the line which joins their centers. I only use Geometry project shapes, which know their intersections with a line, in the same coordinates, so I know nothing of Bloc. Each end is the intersection of the line with an outline which is the closest to the other node. A route answers its points, the geometry of its line, the direction in which it arrives (for the head), its middle and where a label goes next to it, and the same route moved aside (for a double line). My subclasses are the other routes of the curve styles of Telescope: TLBlocConnectionArc and TLBlocConnectionTaxi.
"
Class {
	#name : 'TLBlocConnectionSegment',
	#superclass : 'Object',
	#instVars : [
		'start',
		'end'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
TLBlocConnectionSegment class >> from: aSourceOutline to: aTargetOutline [
	"The outlines are Geometry project shapes, in the same coordinates"

	^ self new
		  join: aSourceOutline to: aTargetOutline;
		  yourself
]

{ #category : 'computing' }
TLBlocConnectionSegment >> borderPointOf: anOutline on: aLine nearestTo: aPoint orElse: aFallbackPoint [
	"The intersection of the line with the outline which is the closest to the point, or the fallback point when the line does not cross the outline"

	| points |
	points := (anOutline intersectionsWithLine: aLine) collect: [ :each | each asPoint ] as: Array.
	^ points ifEmpty: [ aFallbackPoint ] ifNotEmpty: [ points detectMin: [ :point | point distanceTo: aPoint ] ]
]

{ #category : 'computing' }
TLBlocConnectionSegment >> centerOf: anOutline [

	^ anOutline encompassingRectangle center asPoint
]

{ #category : 'accessing' }
TLBlocConnectionSegment >> end [
	"The point on the border of the target, where the segment ends"

	^ end
]

{ #category : 'route' }
TLBlocConnectionSegment >> endDirection [
	"The unit vector along which the line arrives on the target, which the head follows, or nil when the line is empty"

	^ self unitVectorOf: end - start
]

{ #category : 'route' }
TLBlocConnectionSegment >> geometryRelativeTo: aPoint [
	"The Bloc geometry of the line, in the coordinates of an element which has the point as its top left corner"

	^ BlLineGeometry from: start - aPoint to: end - aPoint
]

{ #category : 'initialization' }
TLBlocConnectionSegment >> join: aSourceOutline to: aTargetOutline [
	"The ends are on the line which joins the centers of the outlines. When the centers are the same there is no line, and the segment is the center"

	| sourceCenter targetCenter line |
	sourceCenter := self centerOf: aSourceOutline.
	targetCenter := self centerOf: aTargetOutline.
	sourceCenter = targetCenter ifTrue: [
			start := sourceCenter.
			end := targetCenter.
			^ self ].
	line := GLine through: sourceCenter asGPoint and: targetCenter asGPoint.
	start := self
		         borderPointOf: aSourceOutline
		         on: line
		         nearestTo: targetCenter
		         orElse: sourceCenter.
	end := self
		       borderPointOf: aTargetOutline
		       on: line
		       nearestTo: sourceCenter
		       orElse: targetCenter
]

{ #category : 'labels' }
TLBlocConnectionSegment >> labelCenterFor: anExtent gap: aGap [
	"The center of a label of the given extent, next to the middle of the line and not on it: the label is pushed away from the line, perpendicularly, by its half extent in that direction and a gap. It is above a horizontal line and on the right of a vertical one, whichever way the line goes"

	| normal distance |
	self middleDirection isZero ifTrue: [ ^ self middlePoint ].
	normal := self upwardNormal.
	distance := normal x abs * anExtent x / 2 + (normal y abs * anExtent y / 2) + aGap.
	^ self middlePoint + (normal * distance)
]

{ #category : 'route' }
TLBlocConnectionSegment >> middleDirection [
	"The direction of the line at its middle, which the label is away from"

	^ end - start
]

{ #category : 'route' }
TLBlocConnectionSegment >> middlePoint [
	"The point of the line which the label is next to"

	^ start + end / 2
]

{ #category : 'route' }
TLBlocConnectionSegment >> points [
	"The points which define the line, from the start to the end: here only both ends. A curve or a line with bends has more"

	^ {
		  start.
		  end }
]

{ #category : 'route' }
TLBlocConnectionSegment >> shiftBy: aVector [

	start := start + aVector.
	end := end + aVector
]

{ #category : 'accessing' }
TLBlocConnectionSegment >> start [
	"The point on the border of the source, where the segment starts"

	^ start
]

{ #category : 'route' }
TLBlocConnectionSegment >> translatedBy: aVector [
	"The same route, moved: the second line of a double line is the first one, moved aside"

	^ self copy
		  shiftBy: aVector;
		  yourself
]

{ #category : 'route' }
TLBlocConnectionSegment >> unitVectorOf: aVector [
	"The vector with a length of 1, or nil for the zero vector, which has no direction"

	^ aVector isZero ifFalse: [ aVector normalized ]
]

{ #category : 'labels' }
TLBlocConnectionSegment >> upwardNormal [
	"The unit vector perpendicular to the line at its middle which points up, or right when the line is vertical"

	| direction normal |
	direction := self middleDirection.
	normal := (direction y negated @ direction x) normalized.
	^ (normal y > 0 or: [ normal y = 0 and: [ normal x < 0 ] ])
		  ifTrue: [ normal negated ]
		  ifFalse: [ normal ]
]
