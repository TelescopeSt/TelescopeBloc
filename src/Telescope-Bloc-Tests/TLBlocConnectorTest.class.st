"
I test the Bloc connector of Telescope without opening a window. I check that the connector generates the Bloc elements for the Telescope drawables of a visualization.
"
Class {
	#name : 'TLBlocConnectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'connector'
	],
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'running' }
TLBlocConnectorTest >> setUp [

	super setUp.
	connector := TLBlocConnector new
]

{ #category : 'tests' }
TLBlocConnectorTest >> testNodeCreationGeneratesBlocNodeElement [

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
TLBlocConnectorTest >> testNodeWithLabelGeneratesItsLabelText [

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
TLBlocConnectorTest >> testOpeningTenNodesShowsThemInAWindow [

	| visualization space |
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		layout: TLLinearLayout new;
		generator: connector.
	visualization addNodesFromEntities: (1 to: 10).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Ten nodes'.
	space := connector view space.
	self assert: connector view children size equals: 10.
	space close
]

{ #category : 'tests' }
TLBlocConnectorTest >> testTenNodesAreGeneratedInTheView [

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
TLBlocConnectorTest >> testTenNodesAreLaidOutAtDistinctPositions [

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
