"
I test the Telescope shapes used as the head of a connection: the outline of a shape has its tip on the end of the connection and points in the direction of the connection. I only use Geometry project shapes, no Bloc element.
"
Class {
	#name : 'TLBlocConnectionHeadShapeTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'helpers' }
TLBlocConnectionHeadShapeTest >> headOf: aShape pointingTo: aDirection at: aTip [
	"The outline of the shape as the head of a connection, with a length and a width of 10 pixels"

	^ aShape
		  headOutlineAt: aTip
		  direction: aDirection
		  length: 10
		  width: 10
]

{ #category : 'helpers' }
TLBlocConnectionHeadShapeTest >> pointsOf: anOutline [
	"The vertices of a polygon, as points"

	^ (anOutline vertices collect: #asPoint as: Array) collect: [ :point | point rounded ]
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testArrowHeadHasItsTipOnTheEndOfTheConnection [

	| outline tip |
	outline := self headOf: TLArrow pointingTo: 1 @ 0 at: 100 @ 50.
	tip := (self pointsOf: outline) detectMax: [ :point | point x ].
	self assert: tip equals: 100 @ 50
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testCircleHeadTouchesTheTipWithItsBorder [

	| outline |
	outline := self headOf: TLCircle pointingTo: 1 @ 0 at: 100 @ 50.
	self assert: outline class equals: GEllipse.
	self assert: outline center asPoint equals: 95 @ 50.
	self assert: outline semiMajorAxisLength equals: 5
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testEveryShapeCanBeAHead [

	TLSimpleShape allSubclasses do: [ :shape |
			self
				shouldnt: [
						shape
							headOutlineAt: 100 @ 50
							direction: 1 @ 0
							length: 10
							width: 10 ]
				raise: Error ]
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testFileFolderAndLabelHeadsAreTheirNodeShapesTurnedByAQuarter [

	{
		TLFileShape.
		TLFolderShape.
		TLLabel } do: [ :shape | self assert: shape headPolygonPoints equals: (shape polygonPoints collect: [ :point | point y negated @ point x ]) ]
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testHeadFollowsTheDirectionOfTheConnection [

	| outline points |
	outline := self headOf: TLTriangle pointingTo: 0 @ 1 at: 50 @ 100.
	points := self pointsOf: outline.
	self assert: points asSet equals: {
			(50 @ 100).
			(45 @ 90).
			(55 @ 90) } asSet
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testLabelHeadPointsForwardLikeTheOthers [

	| outline tip |
	outline := self headOf: TLLabel pointingTo: 1 @ 0 at: 100 @ 50.
	tip := (self pointsOf: outline) detectMax: [ :point | point x ].
	self assert: tip equals: 100 @ 50
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testNoShapeHasNoHead [

	self assert: (self headOf: TLNoShape pointingTo: 1 @ 0 at: 100 @ 50) isNil
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testSquareHeadIsBehindTheTip [

	| outline points |
	outline := self headOf: TLSquare pointingTo: 1 @ 0 at: 100 @ 50.
	points := self pointsOf: outline.
	self assert: points asSet equals: {
			(90 @ 45).
			(100 @ 45).
			(100 @ 55).
			(90 @ 55) } asSet
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testTriangleHeadHasItsApexOnTheTipAndItsBaseBehind [

	| outline points |
	outline := self headOf: TLTriangle pointingTo: 1 @ 0 at: 100 @ 50.
	points := self pointsOf: outline.
	self assert: points asSet equals: {
			(100 @ 50).
			(90 @ 45).
			(90 @ 55) } asSet
]

{ #category : 'tests' }
TLBlocConnectionHeadShapeTest >> testVeeHeadPointsForwardLikeTheOthers [

	| outline tip |
	outline := self headOf: TLVee pointingTo: 1 @ 0 at: 100 @ 50.
	tip := (self pointsOf: outline) detectMax: [ :point | point x ].
	self assert: tip equals: 100 @ 50
]
