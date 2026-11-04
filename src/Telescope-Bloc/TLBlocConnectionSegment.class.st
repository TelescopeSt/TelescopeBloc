"
I am the segment which joins two nodes: it goes from the border of the outline of the source to the border of the outline of the target, along the line which joins their centers. I only use Geometry project shapes, which know their intersections with a line, in the same coordinates, so I know nothing of Bloc. Each end is the intersection of the line with an outline which is the closest to the other node.
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

{ #category : 'accessing' }
TLBlocConnectionSegment >> start [
	"The point on the border of the source, where the segment starts"

	^ start
]
