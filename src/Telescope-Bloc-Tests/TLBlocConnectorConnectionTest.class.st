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

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> assertRoute: aRoute avoidsTheNodeOfEntity: anEntity [

	| rectangle |
	rectangle := (self elementOfEntity: anEntity) encompassingRectangle.
	aRoute points overlappingPairsDo: [ :from :to | self deny: (((from min: to) - 0.5 corner: (from max: to) + 0.5) intersects: rectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> centerOf: anOutline [

	^ anOutline encompassingRectangle center asPoint
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> elementOfConnectionStyledBy: aBlock [
	"The block gets the style sheet of a connection between two nodes. Answers the element of the connection"

	| connection |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	aBlock value: connection styleSheet.
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 150;
			 yourself).
	connector open: visualization inWindowSized: 500 @ 300 titled: 'Arrows'.
	connector view space settleForDuration: 1 seconds.
	^ connector elementFromTLDrawable: connection
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> elementOfConnectionStyledWith: aLineStyle [

	| connection |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	aLineStyle ifNotNil: [ connection styleSheet connectionLineStyle: aLineStyle ].
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Line style'.
	connector view space settleForDuration: 1 seconds.
	^ connector elementFromTLDrawable: connection
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> elementOfEntity: anEntity [

	^ connector elementFromTLDrawable: (visualization allNodesRecursively detect: [ :node | node entity = anEntity ])
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> openConnectionsBetweenTwoNodes: aCount direction: aBlock [
	"Opens a visualization of the nodes 1 and 2 with the given number of connections between them. The block gets the index of a connection and its two nodes and answers the connection"

	| first second |
	first := visualization addNodeFromEntity: 1.
	second := visualization addNodeFromEntity: 2.
	(1 to: aCount) do: [ :index | aBlock value: index value: first value: second ].
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Curves'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> openDemo: aDemo [
	"Opens the demo in a window with the connector of the test"

	visualization := aDemo.
	visualization generator: connector.
	connector open: visualization inWindowSized: 900 @ 600 titled: 'Demo'.
	connector view space settleForDuration: 2 seconds
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> openSelfConnections: aCount [
	"Opens a visualization of a node with the given number of connections from itself to itself and answers their elements"

	| node connections |
	node := visualization addNodeFromEntity: 1.
	visualization addNodeFromEntity: 2.
	connections := (1 to: aCount) collect: [ :index | node connectTo: node ].
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Self'.
	connector view space settleForDuration: 1 seconds.
	^ connections collect: [ :connection | connector elementFromTLDrawable: connection ]
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> openThreeNodesInARowWithSegmentsFromFirstToLast: aCurveStyle [
	"The second node is between the other two. Answers the connection from the first to the last"

	| nodes connection |
	nodes := (1 to: 3) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connection := nodes first connectTo: nodes last.
	connection styleSheet curveStyle: aCurveStyle.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 80;
			 yourself).
	connector open: visualization inWindowSized: 600 @ 300 titled: 'Obstacle'.
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
TLBlocConnectorConnectionTest >> testArrowHasTheColorOfTheLineUnlessItHasItsOwn [

	| element |
	element := self elementOfConnectionStyledBy: [ :style |
			           style color: Color red.
			           style > #base shape: TLTriangle.
			           (style > #middle)
				           shape: TLTriangle;
				           color: Color blue ].
	self assert: (element arrowNamed: #base) element background paint color equals: Color red.
	self assert: (element arrowNamed: #middle) element background paint color equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testArrowIsBiggerOnAThickerLine [

	| thin thick |
	thin := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	thin styleSheet > #middle shape: TLTriangle.
	thick := (visualization addNodeFromEntity: 3) connectTo: (visualization addNodeFromEntity: 4).
	thick styleSheet width: 6.
	thick styleSheet > #middle shape: TLTriangle.
	connector open: visualization inWindowSized: 500 @ 300 titled: 'Arrows'.
	connector view space settleForDuration: 1 seconds.
	self assert: ((connector elementFromTLDrawable: thick) arrowNamed: #middle) element extent x > ((connector elementFromTLDrawable: thin) arrowNamed: #middle) element extent x
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testArrowWithoutShapeIsNotDrawn [

	| element |
	element := self elementOfConnectionStyledBy: [ :style | style > #base shape: TLNoShape ].
	self assert: element arrows isEmpty
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testArrowsAreDrawnAgainWhenTheStyleChanges [

	| connection element count |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	connection styleSheet > #middle shape: TLTriangle.
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 150;
			 yourself).
	connector open: visualization inWindowSized: 500 @ 300 titled: 'Arrows'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: connection.
	count := element children size.
	element customizeFromConnection: connection.
	element update.
	self assert: element children size equals: count.
	self assert: element arrows size equals: 1
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testArrowsFollowTheShapeOfTheirStyle [

	| element |
	element := self elementOfConnectionStyledBy: [ :style | style > #middle shape: TLCircle ].
	self assert: (element arrowNamed: #middle) element geometry class equals: BlEllipseGeometry
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testBaseArrowIsAtTheStartOfTheLinePointingBackwards [

	| element arrow |
	element := self elementOfConnectionStyledBy: [ :style | style > #base shape: TLTriangle ].
	arrow := element arrowNamed: #base.
	self assert: arrow isNotNil.
	self assert: (self tipOf: arrow outline pointing: -1 @ 0) equals: element start.
	self assert: arrow element isNotNil.
	self assert: arrow element parent identicalTo: element
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testBaseArrowOfACurvedConnectionFollowsItsTangent [

	| element arrow direction |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | (first connectTo: second) styleSheet > #base shape: TLTriangle ].
	element := connector connections first.
	arrow := element arrowNamed: #base.
	direction := element route startDirection negated.
	self assert: (self tipOf: arrow outline pointing: direction) equals: element start
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testBezierConnectionStaysStraightThroughTheNodeBetweenItsNodes [
	"Only the segments curve goes around the nodes"

	| element |
	element := self openThreeNodesInARowWithSegmentsFromFirstToLast: TLBezierCurve.
	self assert: element route class equals: TLBlocConnectionSegment
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionArrowsDemoShowsTheThreeArrows [

	| arrows |
	self openDemo: TLDemos exampleConnectionArrows.
	arrows := connector connections flatCollect: [ :connection | connection arrows collect: #name ].
	self assert: (arrows includes: #base).
	self assert: (arrows includes: #middle).
	self assert: (arrows includes: #middleReversed)
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
TLBlocConnectorConnectionTest >> testConnectionHasNoArrowAtItsStartOrMiddleByDefault [

	| element |
	element := self elementOfConnectionStyledBy: [ :style |  ].
	self assert: element arrows isEmpty
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
	self assert: (connector view content children includes: element)
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testConnectionIsSolidByDefault [

	| element |
	element := self elementOfConnectionStyledWith: nil.
	self deny: element border style isDashed.
	self assertEmpty: element lines
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionJoinedByAnotherOneBetweenTheSameNodesBecomesAnArc [

	| nodes first pointsBefore |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	first := nodes first connectTo: nodes second.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Connections'.
	connector view space settleForDuration: 1 seconds.
	pointsBefore := (connector elementFromTLDrawable: first) route points.
	nodes second connectTo: nodes first.
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self deny: (connector elementFromTLDrawable: first) route points equals: pointsBefore
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
	count := (connector view content children select: [ :each | each class == TLBlocNodeConnection ]) size.
	self assert: count equals: TLSimpleShape allSubclasses size + 1
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testConnectionStyleDemoSegmentsConnectionHasBends [
	"The last nodes of the two groups are not on the same row, so the segments have a turn"

	| segments |
	self openDemo: TLDemos exampleConnectionStyle.
	segments := connector connections detect: [ :connection | connection geometry class = BlPolylineGeometry ].
	self assert: (segments route points collect: #y) asSet size > 1
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

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testConnectionsInBothDirectionsAreCurvedOnDifferentSides [

	| forward backward |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second |
			index = 1
				ifTrue: [ first connectTo: second ]
				ifFalse: [ second connectTo: first ] ].
	forward := connector connections first.
	backward := connector connections last.
	self assert: forward geometry class equals: BlBezierCurveGeometry.
	self assert: backward geometry class equals: BlBezierCurveGeometry.
	self assert: (forward route middlePoint - backward route middlePoint) r > 10
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testConnectionsInTheSameDirectionAreCurvedOnDifferentSides [

	| first second |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :one :other | one connectTo: other ].
	first := connector connections first.
	second := connector connections last.
	self assert: first geometry class equals: BlBezierCurveGeometry.
	self assert: (first route middlePoint - second route middlePoint) r > 10
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionsOfANodeWhichChangesItsShapeJoinItsNewBorder [
	"The node keeps its place and its size: only its outline changes. The connection is diagonal, where the border of an ellipse is not the one of a rectangle"

	| nodes connection pointsBefore |
	nodes := (1 to: 4) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connection := nodes first connectTo: nodes fourth.
	visualization styleSheet
		width: 40;
		height: 40.
	visualization layout: (TLLinearLayout perLine: 2).
	nodes fourth addInteraction: (TLStyleCustomizationAction custom: [ :style | style shape: TLEllipse ]) onMouseOver.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Connections'.
	connector view space settleForDuration: 1 seconds.
	pointsBefore := (connector elementFromTLDrawable: connection) route points.
	(connector elementFromTLDrawable: nodes fourth) dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 1 seconds.
	self deny: (connector elementFromTLDrawable: connection) route points equals: pointsBefore
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectorOffersEveryShapeAsAConnectionHead [

	| shapes |
	shapes := connector connectionHeadShapesAvailableForConnector.
	self assert: shapes size equals: TLSimpleShape allSubclasses size.
	self assert: (shapes includes: TLTriangle).
	self assert: (shapes includes: TLNoShape)
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testCurvedConnectionIsInsideItsBox [
	"The box of the element has to hold the control point: nothing is drawn outside of it"

	| element box |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | first connectTo: second ].
	element := connector connections first.
	box := element measuredBounds position extent: element extent.
	element route points do: [ :point | self assert: ((box expandBy: 0.01) containsPoint: point) ]
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testCurvesAreInsideTheWindowAfterTheFit [

	| window |
	self openConnectionsBetweenTwoNodes: 3 direction: [ :index :first :second |
			index even
				ifTrue: [ second connectTo: first ]
				ifFalse: [ first connectTo: second ] ].
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	connector connections do: [ :element | self assert: (window containsRect: element boundsInSpace asRectangle) ]
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

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testDirectCurveStaysStraightWhateverTheOtherConnections [

	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | (first connectTo: second) styleSheet curveStyle: TLDirectCurve ].
	connector connections do: [ :connection | self assert: connection geometry class equals: BlLineGeometry ]
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

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testDoubleLineOfACurvedConnectionIsTwoCurves [

	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | (first connectTo: second) styleSheet connectionLineStyle: TLDoubleLineStyle ].
	connector connections do: [ :element |
			self assert: element lines size equals: 2.
			element lines do: [ :line | self assert: line geometry class equals: BlBezierCurveGeometry ] ]
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testHeadArrivesAtTheEndOfACurvedConnection [

	| element corners box |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | first connectTo: second ].
	element := connector connections first.
	self assert: element head isNotNil.
	corners := element headOutline encompassingRectangle vertices collect: #asPoint as: Array.
	box := (corners collect: #x) min @ (corners collect: #y) min corner: (corners collect: #x) max @ (corners collect: #y) max.
	self assert: ((box expandBy: 1) containsPoint: element end)
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

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testHighlightingANodeDoesNotRouteTheOtherConnectionsAgain [
	"A mouse over updates the visualization: routing all the connections again made it take more than 100 ms with 2000 connections"

	| nodes unrelated routeBefore |
	nodes := (1 to: 4) collect: [ :entity | visualization addNodeFromEntity: entity ].
	nodes first connectTo: nodes second.
	unrelated := nodes third connectTo: nodes fourth.
	visualization addInteraction: (TLStyleCustomizationAction custom: [ :style | style backgroundColor: Color red ]) onMouseOver.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Connections'.
	connector view space settleForDuration: 1 seconds.
	routeBefore := (connector elementFromTLDrawable: unrelated) route.
	(connector elementFromTLDrawable: nodes first) dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (connector elementFromTLDrawable: unrelated) route identicalTo: routeBefore
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testLabelOfACurvedConnectionIsNotOnItsMiddle [

	| element label rectangle |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | (first connectTo: second) styleSheet connectionLabel: [ 'link' ] ].
	element := connector connections first.
	label := element label.
	rectangle := element measuredBounds position + label measuredBounds position extent: label extent.
	self deny: (rectangle containsPoint: element route middlePoint)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testMiddleArrowIsCenteredOnTheMiddleOfTheLineAndPointsAlongIt [

	| element arrow |
	element := self elementOfConnectionStyledBy: [ :style | style > #middle shape: TLTriangle ].
	arrow := element arrowNamed: #middle.
	self assert: (self centerOf: arrow outline) x closeTo: element route middlePoint x.
	self assert: (self centerOf: arrow outline) y closeTo: element route middlePoint y.
	self assert: (self tipOf: arrow outline pointing: 1 @ 0) x > element route middlePoint x
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testMiddleArrowOfASegmentsConnectionIsOnItsMiddleSegment [

	| element arrow |
	element := self elementOfConnectionStyledBy: [ :style |
			           style curveStyle: TLSegmentsCurve.
			           style > #middle shape: TLTriangle ].
	arrow := element arrowNamed: #middle.
	self assert: (self centerOf: arrow outline) x closeTo: element route middlePoint x.
	self assert: (self centerOf: arrow outline) y closeTo: element route middlePoint y
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testMiddleOfThreeConnectionsStaysStraight [

	self openConnectionsBetweenTwoNodes: 3 direction: [ :index :first :second | first connectTo: second ].
	self assert: (connector connections collect: [ :connection | connection geometry class ] as: Set) size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testMiddleReversedArrowPointsBackwards [

	| element arrow |
	element := self elementOfConnectionStyledBy: [ :style | style > #middleReversed shape: TLTriangle ].
	arrow := element arrowNamed: #middleReversed.
	self assert: (self centerOf: arrow outline) x closeTo: element route middlePoint x.
	self assert: (self tipOf: arrow outline pointing: -1 @ 0) x < element route middlePoint x
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

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testParallelSegmentsConnectionsAreNotOnTheSameLines [

	| first second connections |
	first := visualization addNodeFromEntity: 1.
	second := visualization addNodeFromEntity: 2.
	connections := {
		               (first connectTo: second).
		               (second connectTo: first) }.
	connections do: [ :connection | connection styleSheet curveStyle: TLSegmentsCurve ].
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 120;
			 yourself).
	connector open: visualization inWindowSized: 600 @ 300 titled: 'Parallel'.
	connector view space settleForDuration: 1 seconds.
	self deny: (connector elementFromTLDrawable: connections first) route start y closeTo: (connector elementFromTLDrawable: connections last) route start y
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
TLBlocConnectorConnectionTest >> testSegmentsConnectionAvoidsTheLabelsOfTheNodesInItsWay [
	"The labels are measured after the first layout: the routes are made again once they are"

	| nodes connection element label labelRectangle |
	visualization styleSheet
		width: 50;
		height: 50;
		nodeLabel: #asString position: #bottom;
		layout: ((TLLinearLayout perLine: 3)
				 gap: 70;
				 yourself).
	nodes := (1 to: 3) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connection := nodes first connectTo: nodes last.
	connection styleSheet curveStyle: TLSegmentsCurve.
	connector open: visualization inWindowSized: 600 @ 300 titled: 'Labels'.
	connector view space settleForDuration: 2 seconds.
	element := connector elementFromTLDrawable: connection.
	label := (self elementOfEntity: 2) labelElement.
	self assert: label extent y > 0.
	labelRectangle := ((self elementOfEntity: 2) topLeftRelativeTo: connector view) + label measuredBounds position extent: label extent.
	element route points overlappingPairsDo: [ :from :to | self deny: (((from min: to) - 0.5 corner: (from max: to) + 0.5) intersects: labelRectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSegmentsConnectionGoesAroundTheNodeBetweenItsNodes [

	| element |
	element := self openThreeNodesInARowWithSegmentsFromFirstToLast: TLSegmentsCurve.
	self assertRoute: element route avoidsTheNodeOfEntity: 2
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSegmentsConnectionIsNotMovedByTheNodesItJoins [
	"The nodes of the connection are not obstacles, nor the composite which contains them"

	| first second connection element |
	first := visualization addNodeFromEntity: 1.
	second := visualization addNodeFromEntity: 2.
	connection := first connectTo: second.
	connection styleSheet curveStyle: TLSegmentsCurve.
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 80;
			 yourself).
	connector open: visualization inWindowSized: 600 @ 300 titled: 'Obstacle'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: connection.
	self assert: element route points size equals: 4.
	self assert: element route points second y equals: element route points first y
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSegmentsCurveHasTheHeadAlongItsLastSegment [
	"The head of a taxi is horizontal or vertical"

	| element |
	visualization layout: ((TLLinearLayout perLine: 1)
			 gap: 100;
			 yourself).
	self openConnectionsBetweenTwoNodes: 1 direction: [ :index :first :second | (first connectTo: second) styleSheet curveStyle: TLSegmentsCurve ].
	element := connector connections first.
	self assert: element route endDirection isNotNil.
	self assert: (element route endDirection x abs < 0.001 or: [ element route endDirection y abs < 0.001 ])
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSegmentsCurveIsAPolyline [

	| first second connection |
	first := visualization addNodeFromEntity: 1.
	second := visualization addNodeFromEntity: 2.
	connection := first connectTo: second.
	connection styleSheet curveStyle: TLSegmentsCurve.
	visualization layout: ((TLLinearLayout perLine: 1)
			 gap: 100;
			 yourself).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Curves'.
	connector view space settleForDuration: 1 seconds.
	self assert: connector connections first geometry class equals: BlPolylineGeometry
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionHasAHeadAtTheEndOfTheLoop [

	| element |
	element := (self openSelfConnections: 1) first.
	self assert: element head isNotNil
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionIsALoopOutsideOfItsNode [

	| element node |
	element := (self openSelfConnections: 1) first.
	node := element fromNode.
	self assert: element route class equals: TLBlocConnectionLoop.
	self assert: element extent > (1 @ 1).
	self assert: element boundsInSpace top < node boundsInSpace top
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionIsInsideTheWindowAfterTheFit [

	| element window |
	element := (self openSelfConnections: 1) first.
	window := 0 @ 0 extent: connector view space extent.
	self assert: (window containsRect: element boundsInSpace asRectangle)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionLabelIsAwayFromTheNode [

	| node connection element label |
	node := visualization addNodeFromEntity: 1.
	connection := node connectTo: node.
	connection styleSheet
		connectionLabel: [ 'link' ];
		connectionLabelSize: 12.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Self'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: connection.
	label := element label.
	self assert: label isNotNil.
	self assert: element measuredBounds position y + label measuredBounds position y + label extent y <= element fromNode measuredBounds position y
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionOfEveryCurveStyleIsALoop [

	| elements |
	elements := #( 1 2 3 )
		            with: {
				            TLBezierCurve.
				            TLDirectCurve.
				            TLSegmentsCurve }
		            collect: [ :entity :curve |
				            | node connection |
				            node := visualization addNodeFromEntity: entity.
				            connection := node connectTo: node.
				            connection styleSheet curveStyle: curve.
				            connection ].
	connector open: visualization inWindowSized: 600 @ 300 titled: 'Self'.
	connector view space settleForDuration: 1 seconds.
	elements do: [ :connection | self assert: (connector elementFromTLDrawable: connection) route class equals: TLBlocConnectionLoop ]
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionStartsAndEndsOnTheBorderOfItsNode [

	| element nodeBounds |
	element := (self openSelfConnections: 1) first.
	nodeBounds := element fromNode boundsInSpace asRectangle expandBy: 2.
	self assert: (nodeBounds containsPoint: element route start + element parent positionInSpace).
	self assert: (nodeBounds containsPoint: element route end + element parent positionInSpace)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSelfConnectionsOfTheSameNodeDoNotOverlap [

	| elements |
	elements := self openSelfConnections: 3.
	self assert: (elements collect: [ :element | element route control ] as: Set) size equals: 3
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoGeneratesItsTenConnections [

	| connections |
	visualization := TLDemos exampleSimpleConnections.
	visualization generator: connector.
	visualization generateWith: connector.
	connections := connector view content children select: [ :each | each class == TLBlocNodeConnection ].
	self assert: connections size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoHasALoopOnItsFirstNode [

	self openDemo: TLDemos exampleSimpleConnections.
	self assert: (connector connections count: [ :connection | connection route class == TLBlocConnectionLoop ]) equals: 1
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoHasDirectConnectionsWhichStayStraight [

	| directs |
	self openDemo: TLDemos exampleSimpleConnections.
	directs := connector connections select: [ :connection | connection geometry class = BlLineGeometry ].
	self assert: directs size >= 2
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoSegmentsConnectionHasBends [

	| segments |
	self openDemo: TLDemos exampleSimpleConnections.
	segments := connector connections detect: [ :connection | connection geometry class = BlPolylineGeometry ].
	self assert: (segments route points collect: #y) asSet size > 1.
	self assert: (segments route points collect: #x) asSet size > 1
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoShowsTheThreeCurveStyles [
	"Arcs for the connections in both directions between two nodes, a polyline for the diagonal one and straight lines for the others"

	| geometries |
	self openDemo: TLDemos exampleSimpleConnections.
	geometries := connector connections collect: [ :connection | connection geometry class ] as: Set.
	self assert: (geometries includes: BlBezierCurveGeometry).
	self assert: (geometries includes: BlPolylineGeometry).
	self assert: (geometries includes: BlLineGeometry)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoSpreadsTheTwoConnectionsBetweenTheSameNodes [

	| arcs |
	self openDemo: TLDemos exampleSimpleConnections.
	arcs := connector connections select: [ :connection | connection route class == TLBlocConnectionArc ].
	self assert: arcs size equals: 2.
	self assert: (arcs first route middlePoint - arcs last route middlePoint) r > 10
]

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testSingleConnectionIsStraightWithTheDefaultCurve [
	"The default curve style of Telescope is Bezier, which is a straight line when the connection is alone between its nodes"

	self openConnectionsBetweenTwoNodes: 1 direction: [ :index :first :second | first connectTo: second ].
	self assert: connector connections first geometry class equals: BlLineGeometry
]

{ #category : 'tests - line style' }
TLBlocConnectorConnectionTest >> testSolidConnectionIsAnUninterruptedLine [

	| element |
	element := self elementOfConnectionStyledWith: TLSolidLineStyle.
	self deny: element border style isDashed.
	self assertEmpty: element lines
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testThreeArrowsAndTheHeadCanBeTogether [

	| element |
	element := self elementOfConnectionStyledBy: [ :style |
			           style > #base shape: TLTriangle.
			           style > #middle shape: TLTriangle.
			           style > #middleReversed shape: TLTriangle ].
	self assert: element arrows size equals: 3.
	self assert: element head isNotNil
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

{ #category : 'tests - curves' }
TLBlocConnectorConnectionTest >> testViewContentIncludesTheCurvesOfTheConnections [
	"A curve goes out of the box of the nodes: the fit of the view has to count it"

	| box |
	self openConnectionsBetweenTwoNodes: 2 direction: [ :index :first :second | first connectTo: second ].
	connector connections do: [ :element |
			box := element measuredBounds position extent: element extent.
			self assert: ((connector view contentRectangle expandBy: 0.01) containsRect: box) ]
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> tipOf: anOutline pointing: aVector [
	"The vertex of the outline which is the farthest along the vector"

	^ (anOutline vertices collect: #asPoint as: Array) detectMax: [ :point | point dotProduct: aVector ]
]
