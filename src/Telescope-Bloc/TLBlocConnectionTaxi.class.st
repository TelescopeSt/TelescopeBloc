"
I am the route of a connection with the curve style segments of Telescope: segments with right angles, drawn with a BlPolylineGeometry. The line goes out of the source along the axis on which the nodes are the most apart, to the middle, along the other axis, then to the target, so it has two turns. It is shifted to the left of its direction by the offset which the connector gives to the connections between the same nodes, so that they do not overlap. It goes around the other nodes (the obstacles, with their labels): first its middle segment moves beside an obstacle, then it leaves along the other axis, and when four points are not enough a TLBlocOrthogonalRouter finds a line with more bends. When nothing avoids the obstacles it is the first line. The label is next to the middle segment (the one between the two turns with four points, else where half of the length is reached) and the head follows the last one.
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

{ #category : 'instance creation' }
TLBlocConnectionTaxi class >> from: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"The offset spreads the connections between the same nodes, and the obstacles are the rectangles, in the same coordinates, of the other nodes: the line goes around them when it can"

	^ self new
		  join: aSourceOutline
		  to: aTargetOutline
		  offset: anOffset
		  obstacles: someRectangles;
		  yourself
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> bestOf: someRoutes avoiding: someRectangles [
	"The first route of the axis which avoids all the obstacles, the shortest when several do, or nil. The routes are in two groups of the same size, one for each axis: the first axis is the one of the nodes which are the most apart, and it is kept when it works"

	| half |
	half := someRoutes size // 2.
	^ (self shortestOf: (someRoutes first: half) avoiding: someRectangles) ifNil: [ self shortestOf: (someRoutes allButFirst: half) avoiding: someRectangles ]
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> does: aRoute avoid: someRectangles [

	^ (1 to: aRoute size - 1) noneSatisfy: [ :index |
			  | from to segment |
			  from := aRoute at: index.
			  to := aRoute at: index + 1.
			  segment := (from min: to) - 0.5 corner: (from max: to) + 0.5.
			  someRectangles anySatisfy: [ :rectangle | segment intersects: rectangle ] ]
]

{ #category : 'route' }
TLBlocConnectionTaxi >> endDirection [
	"The direction of the last segment which is not empty"

	points size to: 2 by: -1 do: [ :index | (self unitVectorOf: (points at: index) - (points at: index - 1)) ifNotNil: [ :direction | ^ direction ] ].
	^ nil
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> endsAlong: anAxis from: aSourceOutline to: aTargetOutline offset: anOffset [
	"The point where the line leaves the source and the one where it arrives on the target, when it goes along the axis, shifted by the offset"

	| sourceCenter targetCenter left across shift |
	sourceCenter := self centerOf: aSourceOutline.
	targetCenter := self centerOf: aTargetOutline.
	left := (targetCenter - sourceCenter) y @ (targetCenter - sourceCenter) x negated.
	across := anAxis y @ anAxis x.
	shift := across * ((left dotProduct: across) sign * anOffset).
	^ {
		  (self
			   borderPointOf: aSourceOutline
			   on: (GLine through: (sourceCenter + shift) asGPoint and: (sourceCenter + shift + anAxis) asGPoint)
			   nearestTo: targetCenter
			   orElse: sourceCenter + shift).
		  (self
			   borderPointOf: aTargetOutline
			   on: (GLine through: (targetCenter + shift) asGPoint and: (targetCenter + shift + anAxis) asGPoint)
			   nearestTo: sourceCenter
			   orElse: targetCenter + shift) }
]

{ #category : 'route' }
TLBlocConnectionTaxi >> geometryRelativeTo: aPoint [

	^ BlPolylineGeometry vertices: (points collect: [ :point | point - aPoint ])
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> join: aSourceOutline to: aTargetOutline [
	"A line which does not avoid anything and is not spread"

	self
		join: aSourceOutline
		to: aTargetOutline
		offset: 0
		obstacles: #(  )
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> join: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"The line goes out of the border of the source along the axis on which the nodes are the most apart, to the middle, then along the other axis, then along the first axis to the border of the target: it only has right angles. Each end is where the line along the axis from the center of its node leaves the node. The line is shifted to the left of its direction by the offset, so that the connections between the same nodes do not overlap. When the middle segment, or the others, would cross one of the obstacles, the middle segment is moved aside, along the borders of the obstacles, and when it does not help the line leaves the other way. When four points are not enough to go around the obstacles, the line is the route which a router finds on a grid, with more bends. When nothing avoids the obstacles the line is the first one"

	| sourceCenter targetCenter delta preferred other routes |
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
	preferred := delta x abs >= delta y abs
		             ifTrue: [ 1 @ 0 ]
		             ifFalse: [ 0 @ 1 ].
	other := preferred y @ preferred x.
	routes := (self
		           routesAlong: preferred
		           from: aSourceOutline
		           to: aTargetOutline
		           offset: anOffset
		           obstacles: someRectangles) , (self
		           routesAlong: other
		           from: aSourceOutline
		           to: aTargetOutline
		           offset: anOffset
		           obstacles: someRectangles).
	points := (self bestOf: routes avoiding: someRectangles) ifNil: [
			          (self
				           routeAroundOn: {
						           preferred.
						           other }
				           from: aSourceOutline
				           to: aTargetOutline
				           offset: anOffset
				           obstacles: someRectangles) ifNil: [ routes first ] ].
	start := points first.
	end := points last
]

{ #category : 'accessing' }
TLBlocConnectionTaxi >> length [
	"The length of the line"

	| total |
	total := 0.
	points overlappingPairsDo: [ :from :to | total := total + (from distanceTo: to) ].
	^ total
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> lengthOf: aRoute [

	^ (1 to: aRoute size - 1) inject: 0 into: [ :sum :index | sum + ((aRoute at: index) distanceTo: (aRoute at: index + 1)) ]
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> margin [
	"The distance in pixels between a line and the nodes it goes around"

	^ 8
]

{ #category : 'accessing' }
TLBlocConnectionTaxi >> middleDirection [
	"The direction of the middle segment, or the one of the whole line when it is empty, which is the case when the nodes are aligned"

	| segment direction |
	segment := self middleSegment.
	direction := segment last - segment first.
	^ direction isZero
		  ifTrue: [ end - start ]
		  ifFalse: [ direction ]
]

{ #category : 'accessing' }
TLBlocConnectionTaxi >> middlePoint [
	"The middle of the middle segment of a line with four points, which is the one between the two turns, and the point which is half way along the line when it has more"

	| segment half walked |
	points size = 4 ifTrue: [ ^ points second + points third / 2 ].
	half := self length / 2.
	walked := 0.
	points overlappingPairsDo: [ :from :to |
			| segmentLength |
			segmentLength := from distanceTo: to.
			walked + segmentLength >= half ifTrue: [
					^ segmentLength isZero
						  ifTrue: [ from ]
						  ifFalse: [ from + (to - from * (half - walked / segmentLength)) ] ].
			walked := walked + segmentLength ].
	^ points last
]

{ #category : 'accessing' }
TLBlocConnectionTaxi >> middleSegment [
	"The two points of the segment which has the middle of the line: the one between the two turns of a line with four points, otherwise the one where half of the length of the line is reached"

	^ points size = 4
		  ifTrue: [
				  {
					  points second.
					  points third } ]
		  ifFalse: [ self segmentWithHalfTheLength ]
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> outwardAlong: anAxis from: aCenter of: aBorderPoint [
	"The unit vector along the axis which goes from the center of a node to a point of its border"

	^ anAxis * (aBorderPoint - aCenter dotProduct: anAxis) sign
]

{ #category : 'route' }
TLBlocConnectionTaxi >> points [
	"The ends, and the two points where the line turns"

	^ points
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> routeAroundOn: someAxes from: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"The points of a line found by the router, which leaves the source and arrives on the target along one of the axes, or nil when there is none"

	someAxes do: [ :axis |
			| ends sourceCenter targetCenter startOutside endOutside inner |
			ends := self
				        endsAlong: axis
				        from: aSourceOutline
				        to: aTargetOutline
				        offset: anOffset.
			sourceCenter := self centerOf: aSourceOutline.
			targetCenter := self centerOf: aTargetOutline.
			startOutside := ends first + ((self outwardAlong: axis from: sourceCenter of: ends first) * self margin).
			endOutside := ends last + ((self outwardAlong: axis from: targetCenter of: ends last) * self margin).
			inner := (TLBlocOrthogonalRouter obstacles: someRectangles) routeFrom: startOutside to: endOutside.
			inner ifNotNil: [ ^ TLBlocOrthogonalRouter new withoutPointsOnALine: { ends first } , inner , { ends last } ] ].
	^ nil
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> routeFrom: aStart to: anEnd along: anAxis through: aChannel [
	"The four points of a line which leaves along the axis, turns at the channel, which is a coordinate on the axis, goes along the other axis, and turns again"

	^ anAxis x = 1
		  ifTrue: [
				  {
					  aStart.
					  (aChannel @ aStart y).
					  (aChannel @ anEnd y).
					  anEnd } ]
		  ifFalse: [
				  {
					  aStart.
					  (aStart x @ aChannel).
					  (anEnd x @ aChannel).
					  anEnd } ]
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> routesAlong: anAxis from: aSourceOutline to: aTargetOutline offset: anOffset obstacles: someRectangles [
	"The lines which leave the source along the axis: the first one has its middle segment halfway, the others have it beside an obstacle. The offset puts the line to the left of the direction of the connection: it shifts the line and its middle segment, on the sides where the left of the connection is. Two connections in opposite directions are not on the same side"

	| delta left ends middle channels |
	delta := (self centerOf: aTargetOutline) - (self centerOf: aSourceOutline).
	left := delta y @ delta x negated.
	ends := self
		        endsAlong: anAxis
		        from: aSourceOutline
		        to: aTargetOutline
		        offset: anOffset.
	middle := ends first + ends last / 2.
	channels := OrderedCollection with: (middle dotProduct: anAxis) + ((left dotProduct: anAxis) sign * anOffset).
	someRectangles do: [ :rectangle |
			channels
				add: (rectangle origin dotProduct: anAxis) - self margin;
				add: (rectangle corner dotProduct: anAxis) + self margin ].
	^ channels collect: [ :channel |
			  self
				  routeFrom: ends first
				  to: ends last
				  along: anAxis
				  through: channel ]
]

{ #category : 'accessing' }
TLBlocConnectionTaxi >> segmentWithHalfTheLength [
	"The two points of the segment where half of the length of the line is reached"

	| half walked |
	half := self length / 2.
	walked := 0.
	points overlappingPairsDo: [ :from :to |
			walked + (from distanceTo: to) >= half ifTrue: [
					^ {
						  from.
						  to } ].
			walked := walked + (from distanceTo: to) ].
	^ {
		  points first.
		  points last }
]

{ #category : 'route' }
TLBlocConnectionTaxi >> shiftBy: aVector [

	super shiftBy: aVector.
	points := points collect: [ :point | point + aVector ]
]

{ #category : 'initialization' }
TLBlocConnectionTaxi >> shortestOf: someRoutes avoiding: someRectangles [

	| valid |
	valid := someRoutes select: [ :route | self does: route avoid: someRectangles ].
	^ valid ifEmpty: [ nil ] ifNotEmpty: [ valid detectMin: [ :route | self lengthOf: route ] ]
]
