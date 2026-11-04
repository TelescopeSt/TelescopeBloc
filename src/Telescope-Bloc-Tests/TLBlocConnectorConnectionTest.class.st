"
I test the connections between nodes drawn by the Bloc connector: a connection is an element of the view, it joins the borders of the outlines of its two nodes, whatever the groups the nodes are in, and it takes the color and the width of its style. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorConnectionTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> elementOfConnectionStyledWith: aLineStyle [

	| connection |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	aLineStyle ifNotNil: [ connection styleSheet connectionLineStyle: aLineStyle ].
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Line style'.
	connector view space settleForDuration: 1 seconds.
	^ connector elementFromTLDrawable: connection
]

{ #category : 'setup' }
TLBlocConnectorConnectionTest >> setUp [

	super setUp.
	visualization styleSheet
		width: 40;
		height: 40
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionHasATriangleHeadByDefaultWhoseTipIsTheEndOfTheLine [

	| source target connection element tip |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	self assert: element head isNotNil.
	self assert: element head geometry class equals: BlPolygonGeometry.
	tip := (element headOutline vertices collect: #asPoint as: Array) detectMax: [ :point | point x ].
	self assert: tip equals: element end
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionIsAnElementOfTheView [

	| source target connection element |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	self assert: element class equals: TLBlocNodeConnection.
	self assert: (connector view children includes: element)
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testConnectionIsSolidByDefault [

	| element |
	element := self elementOfConnectionStyledWith: nil.
	self deny: element border style isDashed.
	self assertEmpty: element lines
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionJoinsNodesOfTwoSubGroups [

	| source target connection sourceElement targetElement element |
	source := visualization > #left addNodeFromEntity: 1.
	target := visualization > #right addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	sourceElement := connector elementFromTLDrawable: source.
	targetElement := connector elementFromTLDrawable: target.
	element := connector elementFromTLDrawable: connection.
	self assert: element start equals: (sourceElement topLeftRelativeTo: connector view) + (40 @ 20).
	self assert: element end equals: (targetElement topLeftRelativeTo: connector view) + (0 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionJoinsTheBordersOfItsNodes [

	| source target connection sourceElement targetElement element |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	sourceElement := connector elementFromTLDrawable: source.
	targetElement := connector elementFromTLDrawable: target.
	element := connector elementFromTLDrawable: connection.
	"The nodes are in a row: the connection leaves by the right of the source and arrives by the left of the target"
	self assert: element start equals: (sourceElement topLeftRelativeTo: connector view) + (40 @ 20).
	self assert: element end equals: (targetElement topLeftRelativeTo: connector view) + (0 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionLabelIsNextToTheLineAtItsMiddle [

	| connection element label topLeft |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	connection styleSheet
		connectionLabel: [ 'link' ];
		connectionLabelSize: 12.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Connection label'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: connection.
	label := element label.
	self assert: label text asString equals: 'link'.
	topLeft := element measuredBounds position + label measuredBounds position.
	"The connection is horizontal: the label is above the line, along the middle of it"
	self assert: topLeft y + label extent y < element start y.
	self assert: (topLeft x + (label extent x / 2) - (element start x + element end x / 2)) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionStyleDemoGeneratesAConnectionForEachHeadShape [

	| count |
	visualization := TLDemos exampleConnectionStyle.
	visualization generator: connector.
	visualization generateWith: connector.
	count := (connector view children select: [ :each | each class == TLBlocNodeConnection ]) size.
	self assert: count equals: TLSimpleShape allSubclasses size + 1
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionTakesTheColorAndTheWidthOfItsStyle [

	| connection element |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	connection styleSheet
		color: Color red;
		width: 3.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	self assert: element border paint color equals: Color red.
	self assert: element border width equals: 3
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionWithoutHeadShapeHasNoHead [

	| connection |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	connection styleSheet > #head shape: TLNoShape.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: connection) head isNil
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionWithoutLabelHasNoLabel [

	| connection |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: connection) label isNil
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectorOffersEveryShapeAsAConnectionHead [

	| shapes |
	shapes := connector connectionHeadShapesAvailableForConnector.
	self assert: shapes size equals: TLSimpleShape allSubclasses size.
	self assert: (shapes includes: TLTriangle).
	self assert: (shapes includes: TLNoShape)
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testDashedConnectionIsMadeOfSegmentsLongerThanTheirGaps [

	| element dashArray |
	element := self elementOfConnectionStyledWith: TLDashedLineStyle.
	self assert: element border style isDashed.
	dashArray := element border style dashArray.
	self assert: dashArray size equals: 2.
	self assert: dashArray first > dashArray last
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testDottedConnectionIsMadeOfSquareDotsAsWideAsTheLineWithGapsOfTheSameWidth [

	| element |
	element := self elementOfConnectionStyledWith: TLDottedLineStyle.
	self assert: element border style isDashed.
	self assert: element border style dashArray equals: {
			element border width.
			element border width }
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testDoubleConnectionIsCenteredOnTheAxisOfTheSegment [

	| element centers axis |
	element := self elementOfConnectionStyledWith: TLDoubleLineStyle.
	centers := element lines collect: [ :line | line position + (line extent / 2) ].
	axis := element start + element end / 2 - element measuredBounds position.
	self assert: (centers first + centers last / 2 - axis) abs < (1 @ 1).
	self deny: centers first equals: centers last
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testDoubleConnectionIsTwoThinLinesAsThickAsASolidOne [
	"Two lines and the gap between them, each a third of the width, take the width of a solid line"

	| element width centers |
	element := self elementOfConnectionStyledWith: TLDoubleLineStyle.
	width := visualization allConnections anyOne effectiveStyleSheet width.
	self assert: element lines size equals: 2.
	element lines do: [ :line |
			self assert: line geometry class equals: BlLineGeometry.
			self deny: line border style isDashed.
			self assert: line border width equals: width / 3.0 ].
	centers := element lines collect: [ :line | line position + (line extent / 2) ].
	self assert: (centers first - centers last) r closeTo: width * 2 / 3.0
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testHeadFollowsTheDirectionOfADiagonalConnection [

	| nodes connection element direction vertices |
	visualization styleSheet layout: ((TLLinearLayout perLine: 2)
			 gap: 60;
			 yourself).
	nodes := (1 to: 4) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connection := (nodes at: 1) connectTo: (nodes at: 4).
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	direction := (element end - element start) normalized.
	vertices := element headOutline vertices collect: #asPoint as: Array.
	self assert: element start y < element end y.
	self assert: element start x < element end x.
	"The tip is on the end of the line and all the other points are behind it, along the direction of the line"
	self assert: (vertices anySatisfy: [ :point | (point - element end) abs < (0.01 @ 0.01) ]).
	self assert: (vertices allSatisfy: [ :point | (point - element end dotProduct: direction) <= 0.01 ])
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testHeadHasTheColorOfTheConnectionUnlessItHasItsOwn [

	| plain colored |
	plain := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	plain styleSheet color: Color red.
	colored := (visualization addNodeFromEntity: 3) connectTo: (visualization addNodeFromEntity: 4).
	colored styleSheet color: Color red.
	colored styleSheet > #head color: Color blue.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: plain) head background paint color equals: Color red.
	self assert: (connector elementFromTLDrawable: colored) head background paint color equals: Color blue
]

{ #category : 'tests - adjacency' }
TLBlocConnectorConnectionTest >> testNodesKnowTheirAdjacentNodesForTheLayouts [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source connectTo: target.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Adjacency'.
	connector view space settleForDuration: 1 seconds.
	self assert: (connector elementFromTLDrawable: source) outgoingAdjacentNodes asArray equals: { (connector elementFromTLDrawable: target) }.
	self assert: (connector elementFromTLDrawable: target) incomingAdjacentNodes asArray equals: { (connector elementFromTLDrawable: source) }.
	self assertEmpty: (connector elementFromTLDrawable: source) incomingAdjacentNodes.
	self assertEmpty: (connector elementFromTLDrawable: target) outgoingAdjacentNodes
]

{ #category : 'tests - adjacency' }
TLBlocConnectorConnectionTest >> testRemovedConnectionIsForgottenByItsNodes [

	| source target connection |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Adjacency'.
	connector view space settleForDuration: 1 seconds.
	connection removed.
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self assertEmpty: (connector elementFromTLDrawable: source) outgoingAdjacentNodes.
	self assertEmpty: (connector elementFromTLDrawable: target) incomingAdjacentNodes
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoGeneratesItsSixConnections [

	| connections |
	visualization := TLDemos exampleSimpleConnections.
	visualization generator: connector.
	visualization generateWith: connector.
	connections := connector view children select: [ :each | each class == TLBlocNodeConnection ].
	self assert: connections size equals: 6
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testSolidConnectionIsAnUninterruptedLine [

	| element |
	element := self elementOfConnectionStyledWith: TLSolidLineStyle.
	self deny: element border style isDashed.
	self assertEmpty: element lines
]

{ #category : 'tests - adjacency' }
TLBlocConnectorConnectionTest >> testTreeLayoutPlacesTheTargetBelowTheSource [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source connectTo: target.
	visualization layout: (TLTreeLayout new
			 useOutgoingLinks;
			 yourself).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Tree'.
	connector view space settleForDuration: 1 seconds.
	self assert: (connector elementFromTLDrawable: target) measuredBounds position y > (connector elementFromTLDrawable: source) measuredBounds position y
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testUpdatingConnectionsDoesNotMoveTheOutlineOfAnEllipse [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source styleSheet shape: TLEllipse.
	target styleSheet shape: TLEllipse.
	source connectTo: target.
	visualization generateWith: connector.
	connector updateConnections.
	self assert: (connector elementFromTLDrawable: target) outline center asPoint equals: 20 @ 20
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testUpdatingConnectionsDoesNotMoveTheOutlineOfTheNodes [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source connectTo: target.
	visualization generateWith: connector.
	connector updateConnections.
	connector updateConnections.
	"The target is not at the origin of the view: its outline must still be in its own coordinates"
	self assert: ((connector elementFromTLDrawable: target) outline vertices collect: #asPoint as: Array) equals: {
			(0 @ 0).
			(40 @ 0).
			(40 @ 40).
			(0 @ 40) }
]
