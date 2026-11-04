"
I test the Bloc connector of Telescope without opening a window. I check that the connector generates the Bloc elements for the Telescope drawables of a visualization.
"
Class {
	#name : 'TLBlocConnectorTest',
	#superclass : 'TestCase',
	#instVars : [
		'connector',
		'visualization'
	],
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'testing' }
TLBlocConnectorTest class >> isAbstract [
	"Only the concrete subclasses hold tests, so the superclass is not run by itself"

	^ self == TLBlocConnectorTest
]

{ #category : 'running' }
TLBlocConnectorTest >> setUp [

	super setUp.
	connector := TLBlocConnector new.
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector
]

{ #category : 'running' }
TLBlocConnectorTest >> tearDown [
	"Closes the window opened by a test, whatever the outcome of the test"

	connector view space ifNotNil: [ :space | space close ].
	super tearDown
]
