"
I test the segment which joins two nodes: it goes from the border of the outline of the source to the border of the outline of the target, along the line which joins their centers. I use Geometry project shapes only, no Bloc element.
"
Class {
	#name : 'TLBlocConnectionSegmentTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'helpers' }
TLBlocConnectionSegmentTest >> assertPoint: aPoint isCloseTo: anExpectedPoint [

	self assert: (aPoint - anExpectedPoint) abs < (0.01 @ 0.01)
]

{ #category : 'helpers' }
TLBlocConnectionSegmentTest >> circle: aTopLeft [
	"A circle of 40 pixels of diameter"

	| center |
	center := aTopLeft + (20 @ 20).
	^ GEllipse center: center asGPoint vertex: (center + (20 @ 0)) asGPoint coVertex: (center - (0 @ 20)) asGPoint
]

{ #category : 'helpers' }
TLBlocConnectionSegmentTest >> square: aTopLeft [
	"A square of 40 pixels"

	^ GRectangle origin: aTopLeft corner: aTopLeft + (40 @ 40)
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testCirclesAreJoinedOnTheLineOfTheirCenters [

	| segment |
	segment := TLBlocConnectionSegment from: (self circle: 0 @ 0) to: (self circle: 100 @ 100).
	"The circles have a radius of 20, and the line is at 45 degrees"
	self assertPoint: segment start isCloseTo: 20 + (20 * 2 sqrt / 2) @ (20 + (20 * 2 sqrt / 2)).
	self assertPoint: segment end isCloseTo: 120 - (20 * 2 sqrt / 2) @ (120 - (20 * 2 sqrt / 2))
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testDiagonalBetweenSquaresGoesFromCornerToCorner [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 100).
	self assert: segment start equals: 40 @ 40.
	self assert: segment end equals: 100 @ 100
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testLabelIsOnTheSameSideWhicheverWayTheSegmentGoes [

	| forward backward |
	forward := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 0).
	backward := TLBlocConnectionSegment from: (self square: 100 @ 0) to: (self square: 0 @ 0).
	self assertPoint: (backward labelCenterFor: 30 @ 10 gap: 3) isCloseTo: (forward labelCenterFor: 30 @ 10 gap: 3)
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testLabelOfADiagonalSegmentDoesNotTouchTheLine [

	| segment center extent label line middle |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 100).
	extent := 30 @ 10.
	center := segment labelCenterFor: extent gap: 3.
	label := GRectangle origin: center - (extent / 2) corner: center + (extent / 2).
	line := GLine through: segment start asGPoint and: segment end asGPoint.
	self assert: (label intersectionsWithLine: line) isEmpty.
	"The label stays at the middle of the line, only moved away from it"
	middle := segment start + segment end / 2.
	self assert: (center - middle dotProduct: (segment end - segment start) normalized) abs < 0.01
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testLabelOfAHorizontalSegmentIsAboveItsMiddle [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 0).
	"The middle of the segment is 70 @ 20, and the label is 30 pixels wide and 10 high, with a gap of 3"
	self assertPoint: (segment labelCenterFor: 30 @ 10 gap: 3) isCloseTo: 70 @ (20 - 5 - 3)
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testLabelOfAVerticalSegmentIsOnTheRightOfItsMiddle [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 0 @ 100).
	self assertPoint: (segment labelCenterFor: 30 @ 10 gap: 3) isCloseTo: 20 + 15 + 3 @ 70
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testNodesWithTheSameCenterGiveAnEmptySegment [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self circle: 0 @ 0).
	self assert: segment start equals: segment end.
	self assert: segment start equals: 20 @ 20
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testSegmentGoesFromTheSourceToTheTarget [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 100 @ 0) to: (self square: 0 @ 0).
	self assert: segment start equals: 100 @ 20.
	self assert: segment end equals: 40 @ 20
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testSquareAndCircleAreJoinedBorderToBorder [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self circle: 100 @ 0).
	self assertPoint: segment start isCloseTo: 40 @ 20.
	self assertPoint: segment end isCloseTo: 100 @ 20
]

{ #category : 'tests' }
TLBlocConnectionSegmentTest >> testSquaresFacingEachOtherAreJoinedBorderToBorder [

	| segment |
	segment := TLBlocConnectionSegment from: (self square: 0 @ 0) to: (self square: 100 @ 0).
	self assert: segment start equals: 40 @ 20.
	self assert: segment end equals: 100 @ 20
]
