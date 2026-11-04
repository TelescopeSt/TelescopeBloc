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
