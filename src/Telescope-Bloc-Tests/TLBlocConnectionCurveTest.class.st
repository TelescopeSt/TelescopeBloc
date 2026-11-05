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
TLBlocConnectionCurveTest >> square: aTopLeft [
	"A square of 40 pixels"

	^ GRectangle origin: aTopLeft corner: aTopLeft + (40 @ 40)
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> taxiFrom: aSourceTopLeft to: aTargetTopLeft [

	^ TLBlocConnectionTaxi from: (self square: aSourceTopLeft) to: (self square: aTargetTopLeft)
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
TLBlocConnectionCurveTest >> testOppositeArcsDoNotShareTheSameSide [
	"Two connections between the same nodes, in both directions, with the same offset: each bulges to the left of its own direction, so they do not overlap"

	| forward backward |
	forward := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	backward := self arcFrom: 100 @ 0 to: 0 @ 0 offset: 40.
	self assert: forward middlePoint y < 20.
	self assert: backward middlePoint y > 20
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
TLBlocConnectionCurveTest >> testTaxiArrivesAlongTheLastSegment [

	| horizontal vertical |
	horizontal := self taxiFrom: 0 @ 0 to: 100 @ 60.
	vertical := self taxiFrom: 0 @ 0 to: 60 @ 100.
	self assertPoint: horizontal endDirection isCloseTo: 1 @ 0.
	self assertPoint: vertical endDirection isCloseTo: 0 @ 1
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
TLBlocConnectionCurveTest >> testTaxiLabelIsNextToTheMiddleSegment [
	"The middle segment of a horizontal taxi is vertical: the label is on its right"

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 100 @ 60.
	self assertPoint: taxi middlePoint isCloseTo: 70 @ 50.
	self assertPoint: (taxi labelCenterFor: 30 @ 10 gap: 3) isCloseTo: 70 + 15 + 3 @ 50
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTaxiWithTheSameCentersIsEmpty [

	| taxi |
	taxi := self taxiFrom: 0 @ 0 to: 0 @ 0.
	self assert: taxi start equals: taxi end
]

{ #category : 'tests' }
TLBlocConnectionCurveTest >> testTranslatedArcMovesAllItsPoints [

	| arc moved |
	arc := self arcFrom: 0 @ 0 to: 100 @ 0 offset: 40.
	moved := arc translatedBy: 5 @ 7.
	moved points with: arc points do: [ :point :original | self assertPoint: point isCloseTo: original + (5 @ 7) ]
]
