Class {
	#name : 'TLBlocConnectionCurveTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'tests' }
TLBlocConnectionCurveTest >> arcFrom: aSourceTopLeft to: aTargetTopLeft offset: anOffset [

	^ TLBlocConnectionArc from: (self square: aSourceTopLeft) to: (self square: aTargetTopLeft) offset: anOffset
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> assertPoint: aPoint isCloseTo: anExpectedPoint [

	self assert: (aPoint - anExpectedPoint) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> assertTaxi: aTaxi avoids: aRectangle [
	"No segment of the taxi enters the rectangle"

	aTaxi points overlappingPairsDo: [ :from :to | self deny: (((from min: to) - 0.5 corner: (from max: to) + 0.5) intersects: aRectangle) ]
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> assertTaxiHasOnlyRightAngles: aTaxi [

	aTaxi points overlappingPairsDo: [ :from :to | self assert: (from x = to x or: [ from y = to y ]) ]
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> circle: aTopLeft [
	"A circle of 40 pixels of diameter"

	| center |
	center := aTopLeft + (20 @ 20).
	^ GEllipse center: center asGPoint vertex: (center + (20 @ 0)) asGPoint coVertex: (center - (0 @ 20)) asGPoint
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> gridOfNodesWithoutTheCorners [
	"Three rows of three squares at 120 pixels from each other, without the first and the last"

	| squares |
	squares := (0 to: 2) flatCollect: [ :row | (0 to: 2) collect: [ :column | column * 120 @ (row * 120) extent: 40 @ 40 ] ].
	^ squares copyWithoutAll: {
			  squares first.
			  squares last }
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> lengthAlong: somePoints upTo: aPoint [
	"The length of the line from its first point to the point, which is on it"

	| walked |
	walked := 0.
	somePoints overlappingPairsDo: [ :from :to |
			(((from min: to) - 0.01 corner: (from max: to) + 0.01) containsPoint: aPoint) ifTrue: [ ^ walked + (from distanceTo: aPoint) ].
			walked := walked + (from distanceTo: to) ].
	^ walked
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> loopAround: aTopLeft offset: anOffset [

	^ TLBlocConnectionLoop around: (self square: aTopLeft) offset: anOffset
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> square: aTopLeft [
	"A square of 40 pixels"

	^ GRectangle origin: aTopLeft corner: aTopLeft + (40 @ 40)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> taxiAcrossTheGrid [

	^ self taxiFrom: 0 @ 0 to: 240 @ 240 avoiding: self gridOfNodesWithoutTheCorners
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> taxiFrom: aSourceTopLeft to: aTargetTopLeft [

	^ TLBlocConnectionTaxi from: (self square: aSourceTopLeft) to: (self square: aTargetTopLeft)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> taxiFrom: aSourceTopLeft to: aTargetTopLeft avoiding: someRectangles [

	^ TLBlocConnectionTaxi
		  from: (self square: aSourceTopLeft)
		  to: (self square: aTargetTopLeft)
		  offset: 0
		  obstacles: someRectangles
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcArrivesAlongTheTangentAtItsEnd [
	"The head points from the control point to the end"

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	self assertPoint: arc endDirection isCloseTo: (30 @ 24) normalized
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcBulgesToTheLeftOfItsDirectionWithAPositiveOffset [
	"The offset is the distance of the control point from the middle of the chord. Going right, the left is up on the screen"

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	self assertPoint: arc control isCloseTo: 70 @ -20.
	self assertPoint: arc middlePoint isCloseTo: 70 @ -8
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcBulgesToTheRightWithANegativeOffset [

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: -40.
	self assertPoint: arc control isCloseTo: 70 @ 60.
	self assertPoint: arc middlePoint isCloseTo: 70 @ 48
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcEndsAreOnTheBordersOnTheLinesToTheControlPoint [
	"Each end is where the line from the center of its node to the control point leaves the node"

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	self assertPoint: arc start isCloseTo: 40 @ 4.
	self assertPoint: arc end isCloseTo: 100 @ 4
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcLabelIsAboveTheMiddleOfAnArcWhichBulgesUp [

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	self assertPoint: (arc labelCenterFor: 30 @ 10 gap: 3) isCloseTo: 70 @ (-8 - 5 - 3)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcPointsAreTheEndsAndTheControlPoint [

	| arc |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	self assert: arc points size equals: 3.
	self assertPoint: arc points first isCloseTo: arc start.
	self assertPoint: arc points second isCloseTo: arc control.
	self assertPoint: arc points last isCloseTo: arc end
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testArcWithTheSameCentersIsEmpty [

	| arc |
	arc := self arcFrom: 0 @ 0 to: 0 @ 0 offset: 40.
	self assert: arc start equals: arc end
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testCurveStylesGiveTheirRoute [
	"A Bezier curve is a straight line for a connection which has no other connection with the same nodes, an arc otherwise. A direct curve is always straight, and segments are always a taxi"

	| source target |
	source := self square: 0 @ 0.
	target := self square: 100 @ 0.
	self assert: (TLBezierCurve blocRouteFrom: source to: target offset: 0) class equals: TLBlocConnectionSegment.
	self assert: (TLBezierCurve blocRouteFrom: source to: target offset: 30) class equals: TLBlocConnectionArc.
	self assert: (TLDirectCurve blocRouteFrom: source to: target offset: 30) class equals: TLBlocConnectionSegment.
	self assert: (TLSegmentsCurve blocRouteFrom: source to: target offset: 30) class equals: TLBlocConnectionTaxi
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLabelOfALongTaxiIsNotOnItsLine [

	| taxi label |
	taxi := self taxiAcrossTheGrid.
	label := taxi labelCenterFor: 30 @ 10 gap: 3.
	self deny: label equals: taxi middlePoint
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopArrivesOnTheNodeFromAbove [

	| loop |
	loop := self loopAround: 100 @ 100 offset: 0.
	self assert: loop endDirection y > 0
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopControlPointIsAwayFromTheNodeAbove [

	| loop |
	loop := self loopAround: 100 @ 100 offset: 0.
	self assert: loop control y < 70.
	self assertPoint: loop control isCloseTo: 120 @ loop control y
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopGeometryIsABezierCurve [

	self assert: ((self loopAround: 100 @ 100 offset: 0) geometryRelativeTo: 0 @ 0) class equals: BlBezierCurveGeometry
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopLabelIsOutsideOfTheNodeAboveTheLoop [

	| loop label |
	loop := self loopAround: 100 @ 100 offset: 0.
	label := loop labelCenterFor: 30 @ 10 gap: 3.
	self assert: label y + 5 < loop middlePoint y.
	self assert: label x closeTo: loop middlePoint x
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopOfACircleStartsOnItsBorder [

	| loop |
	loop := TLBlocConnectionLoop around: (self circle: 100 @ 100) offset: 0.
	self assert: (loop start distanceTo: 120 @ 120) closeTo: 20.
	self assert: (loop end distanceTo: 120 @ 120) closeTo: 20
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopOffsetTurnsTheLoopAroundTheNode [
	"A second loop on the same node is somewhere else, so that they do not overlap"

	| first second |
	first := self loopAround: 100 @ 100 offset: 0.
	second := self loopAround: 100 @ 100 offset: 20.
	self deny: (first control closeTo: second control).
	self assert: second control x > first control x
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopOppositeOffsetsTurnTheLoopOnOppositeSides [

	| left right |
	left := self loopAround: 100 @ 100 offset: -20.
	right := self loopAround: 100 @ 100 offset: 20.
	self assert: left control x < 120.
	self assert: right control x > 120
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopPointsAreTheEndsAndTheControlPoint [

	| loop |
	loop := self loopAround: 100 @ 100 offset: 0.
	self assert: loop points equals: {
			loop start.
			loop control.
			loop end }
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testLoopStartsAndEndsOnTheBorderOfTheNodeAbove [
	"The square goes from 100@100 to 140@140, its top border is at 100"

	| loop |
	loop := self loopAround: 100 @ 100 offset: 0.
	self assert: loop start y closeTo: 100.
	self assert: loop end y closeTo: 100.
	self assert: loop start x < loop end x.
	self assert: loop start x > 100.
	self assert: loop end x < 140
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testMiddleOfALongTaxiIsHalfWayAlongItsLength [

	| taxi length |
	taxi := self taxiAcrossTheGrid.
	length := 0.
	taxi points overlappingPairsDo: [ :from :to | length := length + (from distanceTo: to) ].
	self assert: taxi points size > 4.
	self assert: (self lengthAlong: taxi points upTo: taxi middlePoint) closeTo: length / 2
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testMiddlePointOfALongTaxiIsOnTheLine [

	| taxi middle onTheLine |
	taxi := self taxiAcrossTheGrid.
	middle := taxi middlePoint.
	onTheLine := false.
	taxi points overlappingPairsDo: [ :from :to | (((from min: to) - 0.01 corner: (from max: to) + 0.01) containsPoint: middle) ifTrue: [ onTheLine := true ] ].
	self assert: onTheLine
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testOppositeArcsDoNotShareTheSameSide [
	"Two connections between the same nodes, in both directions, with the same offset: each bulges to the left of its own direction, so they do not overlap"

	| forward backward |
	forward := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	backward := self arcFrom: 100 @ 0 to: 0 @ 0 offset: 40.
	self assert: forward middlePoint y < 20.
	self assert: backward middlePoint y > 20
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testParallelTaxisAreNotOnTheSameLines [

	| first second |
	first := TLBlocConnectionTaxi
		         from: (self square: 0 @ 0)
		         to: (self square: 200 @ 100)
		         offset: -20
		         obstacles: #(  ).
	second := TLBlocConnectionTaxi
		          from: (self square: 0 @ 0)
		          to: (self square: 200 @ 100)
		          offset: 20
		          obstacles: #(  ).
	self assertTaxiHasOnlyRightAngles: first.
	self assertTaxiHasOnlyRightAngles: second.
	self deny: first start y closeTo: second start y.
	self deny: first end y closeTo: second end y.
	self deny: first middlePoint x closeTo: second middlePoint x
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testParallelTaxisInOppositeDirectionsAreOnOppositeSides [
	"Each one is to the left of its own direction"

	| going coming |
	going := TLBlocConnectionTaxi
		         from: (self square: 0 @ 0)
		         to: (self square: 200 @ 0)
		         offset: 20
		         obstacles: #(  ).
	coming := TLBlocConnectionTaxi
		          from: (self square: 200 @ 0)
		          to: (self square: 0 @ 0)
		          offset: 20
		          obstacles: #(  ).
	self assert: going start y < 20.
	self assert: coming start y > 20
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testStraightSegmentHasTheApiOfARoute [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 0).
	self assert: segment points equals: {
			(40 @ 20).
			(100 @ 20) }.
	self assertPoint: segment endDirection isCloseTo: 1 @ 0.
	self assertPoint: segment middlePoint isCloseTo: 70 @ 20.
	self assertPoint: (segment translatedBy: 0 @ 5) start isCloseTo: 40 @ 25
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiAcrossTheGridLeavesAndArrivesAlongAnAxis [
	"The first and the last segments are not empty and are perpendicular to the borders"

	| taxi |
	taxi := self taxiAcrossTheGrid.
	self assert: taxi points first ~= taxi points second.
	self assert: taxi points last ~= (taxi points at: taxi points size - 1)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiAcrossTheGridStartsAndEndsOnTheBordersOfItsNodes [

	| taxi |
	taxi := self taxiAcrossTheGrid.
	self assert: taxi start equals: taxi points first.
	self assert: taxi end equals: taxi points last.
	self assert: (taxi start x = 40 or: [ taxi start x = 0 or: [ taxi start y = 0 or: [ taxi start y = 40 ] ] ]).
	self assert: (taxi end x = 240 or: [ taxi end x = 280 or: [ taxi end y = 240 or: [ taxi end y = 280 ] ] ])
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiArrivesAlongTheLastSegment [

	| horizontal vertical |
	horizontal := self taxiFrom: 0 @ 0 to: 100 @ 60.
	vertical := self taxiFrom: 0 @ 0 to: 60 @ 100.
	self assertPoint: horizontal endDirection isCloseTo: 1 @ 0.
	self assertPoint: vertical endDirection isCloseTo: 0 @ 1
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiAvoidsSeveralNodes [

	| taxi obstacles |
	obstacles := {
		             (100 @ 50 corner: 140 @ 90).
		             (40 @ 40 corner: 80 @ 80).
		             (100 @ 0 corner: 140 @ 40) }.
	taxi := self taxiFrom: 0 @ 0 to: 200 @ 100 avoiding: obstacles.
	obstacles do: [ :obstacle | self assertTaxi: taxi avoids: obstacle ]
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiBetweenAlignedNodesIsAStraightLine [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 0.
	taxi points do: [ :point | self assert: point y equals: 20 ].
	self assertPoint: taxi start isCloseTo: 40 @ 20.
	self assertPoint: taxi end isCloseTo: 100 @ 20
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiGoesAcrossAGridOfNodesWhenFourPointsAreNotEnough [

	| taxi |
	taxi := self taxiAcrossTheGrid.
	self assertTaxiHasOnlyRightAngles: taxi.
	self gridOfNodesWithoutTheCorners do: [ :node | self assertTaxi: taxi avoids: node ].
	self assert: taxi points size > 4
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiGoesAroundANodeBetweenAlignedNodes [
	"A straight line would cross the node: the taxi leaves the other way, above it"

	| taxi obstacle |
	obstacle := 80 @ 0 corner: 120 @ 40.
	taxi := self taxiFrom: 0 @ 0 to: 200 @ 0 avoiding: { obstacle }.
	self assertTaxiHasOnlyRightAngles: taxi.
	self assertTaxi: taxi avoids: obstacle
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiGoesBackwards [

	| taxi |
	taxi := self taxiFrom: 100 @ 60 to: 0 @ 0.
	self assertPoint: taxi points first isCloseTo: 100 @ 80.
	self assertPoint: taxi points last isCloseTo: 40 @ 20.
	self assertPoint: taxi endDirection isCloseTo: -1 @ 0
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiGoesHorizontallyWhenTheNodesAreMoreApartHorizontally [
	"Out of the border of the source, to the middle, along the other axis, then to the border of the target"

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 60.
	self assert: taxi points size equals: 4.
	self assertPoint: taxi points first isCloseTo: 40 @ 20.
	self assertPoint: taxi points second isCloseTo: 70 @ 20.
	self assertPoint: taxi points third isCloseTo: 70 @ 80.
	self assertPoint: taxi points last isCloseTo: 100 @ 80.
	self assertPoint: taxi start isCloseTo: 40 @ 20.
	self assertPoint: taxi end isCloseTo: 100 @ 80
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiGoesVerticallyWhenTheNodesAreMoreApartVertically [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 60 @ 100.
	self assertPoint: taxi points first isCloseTo: 20 @ 40.
	self assertPoint: taxi points second isCloseTo: 20 @ 70.
	self assertPoint: taxi points third isCloseTo: 80 @ 70.
	self assertPoint: taxi points last isCloseTo: 80 @ 100
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiKeepsItsDefaultRouteWhenNoRouteAvoidsTheNodes [
	"Nodes all around the target: nothing can be avoided"

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 60 avoiding: { (-1000 @ -1000 corner: 1000 @ 1000) }.
	self assertPoint: taxi points second isCloseTo: 70 @ 20.
	self assertPoint: taxi points third isCloseTo: 70 @ 80
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiKeepsItsFourPointsWhenTheyAvoidTheNodes [
	"The grid search is only for the lines which cannot be made with four points"

	self assert: (self taxiFrom: 0 @ 0 to: 200 @ 100 avoiding: { (100 @ 50 corner: 140 @ 90) }) points size equals: 4
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiKeepsItsMiddleSegmentWhenTheNodeIsNotInTheWay [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 200 @ 100 avoiding: { (100 @ 300 corner: 140 @ 340) }.
	self assertPoint: taxi points second isCloseTo: 120 @ 20
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiLabelIsNextToTheMiddleSegment [
	"The middle segment of a horizontal taxi is vertical: the label is on its right"

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 60.
	self assertPoint: taxi middlePoint isCloseTo: 70 @ 50.
	self assertPoint: (taxi labelCenterFor: 30 @ 10 gap: 3) isCloseTo: 70 + 15 + 3 @ 50
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiMovesItsMiddleSegmentAwayFromANodeInTheWay [

	| taxi obstacle |
	obstacle := 100 @ 50 corner: 140 @ 90.
	taxi := self taxiFrom: 0 @ 0 to: 200 @ 100 avoiding: { obstacle }.
	self assert: taxi points size equals: 4.
	self assertTaxiHasOnlyRightAngles: taxi.
	self assertTaxi: taxi avoids: obstacle.
	self assertPoint: taxi start isCloseTo: 40 @ 20.
	self assertPoint: taxi end isCloseTo: 200 @ 120
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiWithTheSameCentersIsEmpty [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 0 @ 0.
	self assert: taxi start equals: taxi end
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiWithoutObstacleIsTheSameAsBefore [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 60 avoiding: #(  ).
	self assertPoint: taxi points second isCloseTo: 70 @ 20.
	self assertPoint: taxi points third isCloseTo: 70 @ 80
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiWithoutOffsetOrObstacleStillUsesTheShortApi [

	self assert: (self taxiFrom: 0 @ 0 to: 100 @ 60) points equals: (self taxiFrom: 0 @ 0 to: 100 @ 60 avoiding: #(  )) points
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTranslatedArcMovesAllItsPoints [

	| arc moved |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	moved := arc translatedBy: 5 @ 7.
	moved points with: arc points do: [ :point :original | self assertPoint: point isCloseTo: original + (5 @ 7) ]
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTranslatedLoopMovesAllItsPoints [

	| loop moved |
	loop := self loopAround: 100 @ 100 offset: 0.
	moved := loop translatedBy: 5 @ 7.
	self assertPoint: moved control isCloseTo: loop control + (5 @ 7).
	self assertPoint: moved start isCloseTo: loop start + (5 @ 7).
	self assertPoint: moved end isCloseTo: loop end + (5 @ 7)
]
