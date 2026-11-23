"
I test how the Bloc connector draws the labels of nodes: their text, their placement around the node, their wrap and their ellipsis. I inherit the connector and the window cleaning from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorLabelTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorLabelTest >> labelHeightOf: aNode [

	^ (connector elementFromTLDrawable: aNode) children first extent y
]

{ #category : 'running' }
TLBlocConnectorLabelTest >> setUp [

	super setUp.
	visualization styleSheet nodeLabel: #yourself
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testDefaultTextColorIsTheOneOfTheDefaultStyle [

	| node |
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self assert: (self textColorOfLabelOf: node) equals: TLStyleSheet default textColor
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testEachLineOfALabelHasTheTextColor [

	| node lines |
	visualization styleSheet textColor: Color red.
	node := visualization addNodeFromEntity: 'first' , (String with: Character lf) , 'second'.
	visualization generateWith: connector.
	lines := (connector elementFromTLDrawable: node) children first children.
	self assert: lines size equals: 2.
	lines do: [ :line | self assert: (self textColorOfLine: line) equals: Color red ]
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testEllipsizedLabelFitsItsMaxWidthOnOneLine [

	| node label |
	visualization styleSheet
		nodeLabelWrap: 'ellipsis';
		nodeLabelMaxWidth: 100.
	node := visualization addNodeFromEntity: 'This is a node with an ellipsed label blablablablablabla'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Ellipsis label'.
	connector view space settleForDuration: 2 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label extent x <= 100.
	self assert: (label labelText endsWith: '...').
	self assert: label children size equals: 1
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testEllipsizedLabelKeepsItsTextColor [

	| node |
	visualization styleSheet
		textColor: Color red;
		nodeLabelWrap: 'ellipsis';
		nodeLabelMaxWidth: 60.
	node := visualization addNodeFromEntity: 'This is a node with a very long label'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Ellipsis label'.
	connector view space settleForDuration: 2 seconds.
	self assert: (self textColorOfLabelOf: node) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testForcedLineReturnsGiveOneLinePerLine [

	| node label |
	visualization styleSheet nodeLabel: [ :string | String streamContents: [ :stream | stream << string << (String with: Character lf) << 'second line' ] ].
	node := visualization addNodeFromEntity: 'first line'.
	visualization generateWith: connector.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label children size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testLabelPositionCanBeABlockAnsweringASymbol [
	"The block gets the entity and the node: a composite node with children has its label at the bottom, the others inside"

	| node label |
	visualization styleSheet
		nodeLabel: #asString;
		nodeLabelPosition: [ :entity :aNode |
				entity = 1
					ifTrue: [ #top ]
					ifFalse: [ #inside ] ].
	node := visualization addNodeFromEntity: 1.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Label position'.
	connector view space settleForDuration: 1 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label measuredBounds position y + label extent y <= 0
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testLabelSizeCanDependOnTheEntity [

	| small big |
	visualization styleSheet
		nodeLabel: [ :entity | 'Hello' ];
		labelSize: [ :entity | entity ].
	small := visualization addNodeFromEntity: 8.
	big := visualization addNodeFromEntity: 30.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Label size'.
	connector view space settleForDuration: 1 seconds.
	self assert: (self labelHeightOf: big) > ((self labelHeightOf: small) * 2)
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testLabelSizeOfTheStyleIsTheSizeOfTheFont [

	| small big |
	small := visualization addNodeFromEntity: 'Hello'.
	small styleSheet labelSize: 8.
	big := visualization addNodeFromEntity: 'Hello'.
	big styleSheet labelSize: 30.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Label size'.
	connector view space settleForDuration: 1 seconds.
	self assert: (self labelHeightOf: big) > ((self labelHeightOf: small) * 2)
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testLabelTextColorIsTheTextColorOfTheStyle [

	| node |
	visualization styleSheet textColor: Color red.
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self assert: (self textColorOfLabelOf: node) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testLinesOfALabelDoNotOverlap [
	"Each line is as high as a line of its font, not only as its letters: the letters of a line which go below or above the others, like the g of a word, do not run over the next line, and the lines are evenly spaced"

	| node lines |
	visualization styleSheet nodeLabel: [ :entity | 'Fit' , (String with: Character cr) , 'going' ] position: #bottom.
	node := visualization addNodeFromEntity: 1.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Label'.
	connector view space settleForDuration: 500 milliSeconds.
	lines := (connector elementFromTLDrawable: node) labelElement children.
	self assert: lines size equals: 2.
	lines do: [ :line | self assert: line height >= TLStyleSheet defaultLabelSize ].
	self assert: lines first height equals: lines second height.
	self assert: lines second bounds inParent top >= lines first bounds inParent bottom
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNameCloudDemoGeneratesLabelsSizedByTheirLabelSizeWithoutOverlap [
	"The widths of the nodes come from their labels and their label size: the biggest word is much bigger than the smallest one, and a word is not drawn over its neighbour"

	| demo sizeOf sorted rectangles |
	demo := TLDemos exampleNameCloud.
	demo generator: connector.
	connector open: demo inWindowSized: 1000 @ 700 titled: 'Name cloud'.
	connector view space settleForDuration: 2 seconds.
	sizeOf := [ :node | node effectiveStyleSheet obtainValue: #labelSize forEntity: node entity inNode: node ].
	sorted := demo allNodes asSortedCollection: [ :first :second | (sizeOf value: first) <= (sizeOf value: second) ].
	self assert: (self labelHeightOf: sorted last) > ((self labelHeightOf: sorted first) * 1.5).
	rectangles := demo allNodes collect: [ :node | (connector elementFromTLDrawable: node) encompassingRectangle ].
	self assert: (rectangles count: [ :rectangle | rectangles anySatisfy: [ :other | other ~~ rectangle and: [ (rectangle intersect: other) area > (rectangle area / 4) ] ] ]) < (rectangles size / 20)
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNodeDoesNotClipItsLabel [

	| node |
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self deny: (connector elementFromTLDrawable: node) clipChildren
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNodeLabelCanBeNoLabelForSomeEntities [

	| shown hidden |
	visualization styleSheet nodeLabel: [ :entity |
			entity = 1
				ifTrue: [ 'one' ]
				ifFalse: [ TLNoNodeLabel ] ].
	shown := visualization addNodeFromEntity: 1.
	hidden := visualization addNodeFromEntity: 2.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: shown) children size equals: 1.
	self assertEmpty: (connector elementFromTLDrawable: hidden) children
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNodeWithLabelGeneratesItsLabelText [

	| node |
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) children first labelText equals: 'abc'
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNodeWithoutLabelHasNoLabelElement [
	"Telescope says that a node has no label with the class TLNoNodeLabel: it is not drawn as a text"

	| node |
	visualization styleSheet noNodeLabel.
	node := visualization addNodeFromEntity: 1.
	visualization generateWith: connector.
	self assertEmpty: (connector elementFromTLDrawable: node) children
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testTextColorCanDependOnTheEntity [

	| even odd |
	visualization styleSheet
		nodeLabel: #asString;
		textColor: [ :entity |
				entity even
					ifTrue: [ Color red ]
					ifFalse: [ Color blue ] ].
	even := visualization addNodeFromEntity: 2.
	odd := visualization addNodeFromEntity: 3.
	visualization generateWith: connector.
	self assert: (self textColorOfLabelOf: even) equals: Color red.
	self assert: (self textColorOfLabelOf: odd) equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testTextColorChangedByAnInteractionIsShownUntilTheMouseLeaves [

	| node element before |
	node := visualization addNodeFromEntity: 'abc'.
	visualization addInteraction: (TLStyleCustomizationAction custom: [ :style | style textColor: Color red ]) onMouseOver.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Text color'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: node.
	before := self textColorOfLabelOf: node.
	element dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: (self textColorOfLabelOf: node) equals: Color red.
	element dispatchEvent: BlMouseLeaveEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: (self textColorOfLabelOf: node) equals: before
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testTopLabelIsAboveItsNode [

	| node label |
	visualization styleSheet nodeLabelPosition: #top.
	node := visualization addNodeFromEntity: 'abc'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Top label'.
	connector view space settleForDuration: 1 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label position y < 0
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testTopLabelIsSeparatedFromItsNodeByAGap [

	| node label |
	visualization styleSheet nodeLabelPosition: #top.
	node := visualization addNodeFromEntity: 'abc'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Top label gap'.
	connector view space settleForDuration: 1 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label position y + label extent y closeTo: -5
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testWrappedLabelFitsItsMaxWidthAndGrowsInHeight [

	| node label |
	visualization styleSheet
		nodeLabelWrap: 'wrap';
		nodeLabelMaxWidth: 100.
	node := visualization addNodeFromEntity: 'This is a node with an automatic wrap'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Wrap label'.
	connector view space settleForDuration: 2 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label extent x <= 100.
	self assert: label children size >= 3.
	self assert: (label children allSatisfy: [ :each | each extent x <= 100 ])
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testWrappedLabelKeepsItsTextColor [
	"The lines are made again while the label is wrapped: they keep the color"

	| node |
	visualization styleSheet
		textColor: Color red;
		nodeLabelWrap: 'wrap';
		nodeLabelMaxWidth: 100.
	node := visualization addNodeFromEntity: 'This is a node with an automatic wrap'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Wrap label'.
	connector view space settleForDuration: 2 seconds.
	(connector elementFromTLDrawable: node) children first children do: [ :line | self assert: (self textColorOfLine: line) equals: Color red ]
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testWrappedLinesAreCentered [

	| node label |
	visualization styleSheet
		nodeLabelWrap: 'wrap';
		nodeLabelMaxWidth: 100.
	node := visualization addNodeFromEntity: 'This is a node with an automatic wrap'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Centered lines'.
	connector view space settleForDuration: 2 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label children size >= 3.
	self assert: (label children allSatisfy: [ :each | (each position x + (each extent x / 2) - (label extent x / 2)) abs < 1 ])
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> textColorOfLabelOf: aNode [

	^ self textColorOfLine: (connector elementFromTLDrawable: aNode) children first children first
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> textColorOfLine: aLineElement [
	"The color of the text of a line of a label, or nil when the text has none"

	^ ((aLineElement text attributesAt: 1)
		   detect: [ :attribute | attribute isKindOf: BlTextForegroundAttribute ]
		   ifNone: [ nil ]) ifNotNil: #paint
]
