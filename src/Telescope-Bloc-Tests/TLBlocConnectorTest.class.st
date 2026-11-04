"
I am the superclass of the tests of the Bloc connector. I create the connector and a visualization that uses it, and I close the window a test opened, whatever the outcome of the test. I am abstract: my subclasses hold the tests.
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
	connector host: BlHeadlessHost default.
	connector animationDuration: 0 seconds.
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector
]

{ #category : 'running' }
TLBlocConnectorTest >> tearDown [
	"Closes the window opened by a test, whatever the outcome of the test"

	connector view space ifNotNil: [ :space |
			space close.
			space settleForDuration: 1 seconds ].
	super tearDown
]
