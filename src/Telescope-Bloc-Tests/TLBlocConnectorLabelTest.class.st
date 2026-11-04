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
