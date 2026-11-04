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

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testNodeCreationGeneratesBlocNodeElement [

	| group node |
	group := TLEntitiesGroup new.
	group
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default.
	node := group addNodeFromEntity: 1.
	group generator: connector.
	group generate.
	self assert: (connector elementFromTLDrawable: node) class identicalTo: TLBlocNodeElement
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testOpeningTenNodesShowsThemInAWindow [

	| visualization |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		layout: TLLinearLayout new;
		generator: connector.
	visualization addNodesFromEntities: (1 to: 10).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Ten nodes'.
	self assert: connector view children size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testTenNodesAreGeneratedInTheView [

	| visualization |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		layout: TLLinearLayout new;
		generator: connector.
	visualization addNodesFromEntities: (1 to: 10).
	visualization generateWith: connector.
	self assert: connector view children size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testTenNodesAreLaidOutAtDistinctPositions [

	| visualization positions |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		layout: TLLinearLayout new;
		generator: connector.
	visualization addNodesFromEntities: (1 to: 10).
	visualization generateWith: connector.
	positions := connector view children collect: [ :each | each position ].
	self assert: positions asSet size equals: 10
]

{ #category : 'tests' }
TLBlocConnectorNodeTest >> testVisualizationDoesNotClipItsNodes [

	self deny: TLBlocVisualization new clipChildren
]
