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
