"
I test how the style sheet of a node is applied to the node drawn by the Bloc connector. For now it covers the colors: a color of the style sheet, a block of the entity or a gradient of the entity gives the color of the background and of the border of each node. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorNodeStyleTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorNodeStyleTest >> backgroundColorOfEntity: anEntity [
	"Generates a node of the entity and answers the color of the background of its element"

	| node |
	node := visualization addNodeFromEntity: anEntity.
	visualization generateWith: connector.
	^ (connector elementFromTLDrawable: node) background paint color
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> borderStyleOfNodeStyledWith: aLineStyle [

	| node |
	node := visualization addNodeFromEntity: 1.
	node styleSheet borderStyle: aLineStyle.
	visualization generateWith: connector.
	^ (connector elementFromTLDrawable: node) border style
]

{ #category : 'helpers' }
TLBlocConnectorNodeStyleTest >> colorsOfEntities: aCollection [
	"Generates a node for each entity and answers the colors of the backgrounds of their elements"

	| nodes |
	nodes := aCollection collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization generateWith: connector.
	^ nodes collect: [ :node | (connector elementFromTLDrawable: node) background paint color ]
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> elementOfNodeStyledWith: aLineStyle [

	| node |
	node := visualization addNodeFromEntity: 1.
	aLineStyle ifNotNil: [ node styleSheet borderStyle: aLineStyle ].
	connector open: visualization inWindowSized: 200 @ 200 titled: 'Border style'.
	connector view space settleForDuration: 1 seconds.
	^ connector elementFromTLDrawable: node
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> openNodesOfHeights: someHeights perLine: aNumber takingAllSpace: aBlock [
	"A node for each height, the entities being 1, 2... The nodes for which the block answers true take all the space of their line. Answers the elements"

	| nodes |
	visualization styleSheet
		width: 20;
		height: [ :entity | someHeights at: entity ];
		takeAllSpace: aBlock.
	visualization layout: ((TLLinearLayout perLine: aNumber)
			 gap: 10;
			 yourself).
	nodes := (1 to: someHeights size) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Take all space'.
	connector view space settleForDuration: 1 seconds.
	^ nodes collect: [ :node | connector elementFromTLDrawable: node ]
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBackgroundIsTheColorOfTheStyle [

	visualization styleSheet backgroundColor: Color red.
	self assert: (self backgroundColorOfEntity: 1) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBlockGivesEachNodeTheColorOfItsEntity [

	| colors |
	visualization styleSheet backgroundColor: [ :entity |
			entity even
				ifTrue: [ Color red ]
				ifFalse: [ Color blue ] ].
	colors := self colorsOfEntities: #( 1 2 3 ).
	self assert: colors asArray equals: {
			Color blue.
			Color red.
			Color blue }
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderColorCanDependOnTheEntityToo [

	| nodes |
	visualization styleSheet borderColor: [ :entity |
			entity = 1
				ifTrue: [ Color red ]
				ifFalse: [ Color blue ] ].
	nodes := #( 1 2 ) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: nodes first) border paint color equals: Color red.
	self assert: (connector elementFromTLDrawable: nodes last) border paint color equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderIsHalfInsideAndHalfOutsideOfTheEdge [

	self assert: (self elementOfNodeStyledWith: nil) outskirts class equals: BlOutskirtsCentered
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderIsSolidByDefault [

	| node |
	node := visualization addNodeFromEntity: 1.
	visualization generateWith: connector.
	self deny: (connector elementFromTLDrawable: node) border style isDashed
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderIsTheBorderColorOfTheStyle [

	| node |
	visualization styleSheet
		borderColor: Color blue;
		borderWidth: 3.
	node := visualization addNodeFromEntity: 1.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) border paint color equals: Color blue.
	self assert: (connector elementFromTLDrawable: node) border width equals: 3
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBordersOfADoubleBorderAreOverTheirEdgesToo [

	| element |
	element := self elementOfNodeStyledWith: TLDoubleLineStyle.
	self assert: element outskirts class equals: BlOutskirtsCentered.
	self assert: element innerBorder outskirts class equals: BlOutskirtsCentered
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testDashedBorderIsDashed [

	self assert: (self borderStyleOfNodeStyledWith: TLDashedLineStyle) isDashed
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testDottedBorderIsMadeOfSquareDotsAsWideAsTheBorder [

	| element |
	element := self elementOfNodeStyledWith: TLDottedLineStyle.
	self assert: element border style dashArray equals: {
			element border width.
			element border width }
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testDoubleBorderDrawsTheOutlineASecondTimeInsideOfTheFirstOneWithAGap [
	"Two outlines and the gap between them, each a third of the width, take the width of a solid border"

	| element inner innerPosition width |
	element := self elementOfNodeStyledWith: TLDoubleLineStyle.
	width := visualization allNodes anyOne effectiveStyleSheet borderWidth.
	inner := element innerBorder.
	innerPosition := inner measuredBounds position.
	self assert: inner isNotNil.
	self assert: inner geometry class equals: element geometry class.
	self assert: element border width equals: width / 3.0.
	self assert: inner border width equals: width / 3.0.
	self assert: innerPosition equals: (width * 2 / 3.0) asPoint.
	self assert: innerPosition * 2 + inner extent equals: element extent
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testGradientGivesEachNodeTheColorOfItsEntity [

	| gradient colors |
	gradient := (MDLColor red property: #yourself gradientAt: 5)
		            to: MDLColor green at: 15;
		            yourself.
	visualization styleSheet backgroundColor: gradient.
	colors := self colorsOfEntities: #( 5 10 15 ).
	self assert: colors first equals: MDLColor red.
	self assert: colors last equals: MDLColor green.
	self assert: (colors at: 2) equals: (gradient value: 10).
	self deny: (colors at: 2) equals: colors first.
	self deny: (colors at: 2) equals: colors last
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testLayoutAppliedAgainDoesNotKeepTheStretchedHeightOfAPreviousLayout [
	"The tallest node of a line is smaller in the next layout: the nodes taking all space follow it"

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 10;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self assert: elements first dimension equals: 20 @ 50.
	visualization layout: ((TLLinearLayout perLine: 1)
			 gap: 10;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self assert: elements first dimension equals: 20 @ 10
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNoNodeTakesAllSpaceByDefault [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: false.
	self assert: (elements collect: #dimension) equals: {
			(20 @ 10).
			(20 @ 50).
			(20 @ 20) }
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeNotTakingAllSpaceKeepsItsHeight [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	self assert: elements second dimension equals: 20 @ 50.
	self assert: elements last dimension equals: 20 @ 20
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeTakesTheSpaceOfItsOwnLineOnly [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 30 ) perLine: 2 takingAllSpace: [ :entity | entity even not ].
	self assert: elements first dimension equals: 20 @ 50.
	self assert: elements third dimension equals: 20 @ 30
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeTakingAllSpaceAnswersSo [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	self assert: elements first occupyMaxSpace.
	self deny: elements second occupyMaxSpace
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeTakingAllSpaceHasItsOriginalDimensionAgainWhenAskedTo [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	elements first restoreOriginalDimension.
	self assert: elements first dimension equals: 20 @ 10
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeTakingAllSpaceHasTheHeightOfTheTallestNodeOfItsLine [

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	self assert: elements first dimension equals: 20 @ 50.
	self assert: elements first extent equals: 20 @ 50
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeTakingAllSpaceKeepsItsHeightWhenItsStyleIsAppliedAgain [
	"A mouse over changes the style of a node: it does not shrink back until the layout is applied again"

	| elements node |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	node := visualization allNodes first.
	elements first customizeFromNode: node.
	self assert: elements first dimension equals: 20 @ 50
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testNodeWithAZeroDimensionIsStillGenerated [
	"A width given by a property, such as a number of attributes, can be 0"

	| node element |
	visualization styleSheet
		width: [ :entity | entity ];
		height: [ :entity | entity ].
	node := visualization addNodeFromEntity: 0.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: node.
	self assert: element dimension equals: 0 @ 0.
	self assert: element outline isNotNil
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testOccupyMaximumSpaceIsTheSameAsTakeAllSpace [

	| nodes |
	visualization styleSheet
		width: 20;
		height: [ :entity | entity * 10 ];
		occupyMaximumSpace.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 10;
			 yourself).
	nodes := (1 to: 3) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Take all space'.
	connector view space settleForDuration: 1 seconds.
	self assert: (nodes collect: [ :node | (connector elementFromTLDrawable: node) dimension ]) equals: {
			(20 @ 30).
			(20 @ 30).
			(20 @ 30) }
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testOutlineOfANodeTakingAllSpaceFollowsItsDimension [
	"The connections meet the border of the node: its outline has to be as high as the node"

	| elements |
	elements := self openNodesOfHeights: #( 10 50 20 ) perLine: 3 takingAllSpace: [ :entity | entity = 1 ].
	self assert: elements first outline encompassingRectangle height equals: 50
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testShapeCanDependOnTheEntity [

	| rectangle ellipse |
	visualization styleSheet shape: [ :entity |
			entity even
				ifTrue: [ TLRectangle ]
				ifFalse: [ TLEllipse ] ].
	rectangle := visualization addNodeFromEntity: 2.
	ellipse := visualization addNodeFromEntity: 3.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: rectangle) outline class equals: GRectangle.
	self assert: (connector elementFromTLDrawable: ellipse) outline class equals: GEllipse
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testSolidBorderHasNoInnerBorder [

	self assert: (self elementOfNodeStyledWith: TLSolidLineStyle) innerBorder isNil
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testTakeAllSpaceDemoMakesTheOddNodesAsHighAsTheTallestOfTheirLine [

	| elements |
	visualization := TLDemos exampleTakeAllSpace.
	visualization generator: connector.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Demo'.
	connector view space settleForDuration: 2 seconds.
	elements := visualization allNodes collect: [ :node | connector elementFromTLDrawable: node ].
	"The first line has the entities 1 to 4, with the heights 55, 80, 105 and 30"
	self assert: elements first dimension y equals: 105.
	self assert: (elements at: 2) dimension y equals: 80.
	self assert: (elements at: 3) dimension y equals: 105.
	self assert: (elements at: 4) dimension y equals: 30
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testWidthAndHeightCanDependOnTheEntity [

	| small big |
	visualization styleSheet
		width: [ :entity | entity * 10 ];
		height: [ :entity | entity * 5 ].
	small := visualization addNodeFromEntity: 2.
	big := visualization addNodeFromEntity: 6.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: small) dimension equals: 20 @ 10.
	self assert: (connector elementFromTLDrawable: big) dimension equals: 60 @ 30
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testWidthAndHeightOfANodeAreItsDimensionEvenBeforeTheLayout [
	"The layouts of Telescope ask the nodes for their width: a Bloc element has no extent before it is laid out"

	| node element |
	node := visualization addNodeFromEntity: 1.
	node styleSheet
		width: 30;
		height: 70.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: node.
	self assert: element width equals: 30.
	self assert: element height equals: 70
]
