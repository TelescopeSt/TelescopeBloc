"
I test how the Bloc connector generates the nodes of a visualization: their element class, their number in the view, their layout and their visibility in a window. I inherit the connector and the window cleaning from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorNodeTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'running' }
TLBlocConnectorNodeTest >> setUp [

	super setUp.
	visualization layout: TLLinearLayout new
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testNodeCreationGeneratesBlocNodeElement [

	| node |
	node := visualization addNodeFromEntity: 1.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) class identicalTo: TLBlocNodeElement
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testOpeningTenNodesShowsThemInAWindow [

	visualization addNodesFromEntities: (1 to: 10).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Ten nodes'.
	self assert: connector view children size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testOpeningUsesTheHostOfTheConnector [

	connector host: BlHeadlessHost default.
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Host'.
	self assert: connector view space host identicalTo: BlHeadlessHost default
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testTenNodesAreGeneratedInTheView [

	visualization addNodesFromEntities: (1 to: 10).
	visualization generateWith: connector.
	self assert: connector view children size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testTenNodesAreLaidOutAtDistinctPositions [

	| positions |
	visualization addNodesFromEntities: (1 to: 10).
	visualization generateWith: connector.
	positions := connector view children collect: [ :each | each position ].
	self assert: positions asSet size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testVisualizationDoesNotClipItsNodes [

	self deny: TLBlocVisualization new clipChildren
]
