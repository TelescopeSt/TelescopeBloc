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
TLBlocConnectorLabelTest >> testForcedLineReturnsGiveOneLinePerLine [

	| node label |
	visualization styleSheet nodeLabel: [ :string | String streamContents: [ :stream | stream << string << (String with: Character lf) << 'second line' ] ].
	node := visualization addNodeFromEntity: 'first line'.
	visualization generateWith: connector.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label children size equals: 2
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
TLBlocConnectorLabelTest >> testNodeWithLabelGeneratesItsLabelText [

	| node |
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) children first labelText equals: 'abc'
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
