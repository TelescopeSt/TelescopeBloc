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
TLBlocConnectorLabelTest >> testNodeDoesNotClipItsLabel [

	| visualization node |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector.
	visualization styleSheet nodeLabel: #yourself.
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self deny: (connector elementFromTLDrawable: node) clipChildren
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testNodeWithLabelGeneratesItsLabelText [

	| visualization node |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector.
	visualization styleSheet nodeLabel: #yourself.
	node := visualization addNodeFromEntity: 'abc'.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) children first text asString equals: 'abc'
]

{ #category : 'tests' }
TLBlocConnectorLabelTest >> testTopLabelIsAboveItsNode [

	| visualization node label |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector.
	visualization styleSheet
		nodeLabel: #yourself;
		nodeLabelPosition: #top.
	node := visualization addNodeFromEntity: 'abc'.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Top label'.
	connector view space settleForDuration: 1 seconds.
	label := (connector elementFromTLDrawable: node) children first.
	self assert: label position y < 0
]
