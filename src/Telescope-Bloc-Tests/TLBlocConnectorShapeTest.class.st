"
I test the shapes of the nodes drawn by the Bloc connector: the outline of a node, a Geometry project shape built from the Telescope shape and the dimension of the node, and the Bloc geometry derived from it. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorShapeTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorShapeTest >> elementWithShape: aShape width: aWidth height: aHeight [
	"Generates a node of the given shape and dimension, and answers its element"

	| node |
	node := visualization addNodeFromEntity: 1.
	node styleSheet
		shape: aShape;
		width: aWidth;
		height: aHeight.
	visualization generateWith: connector.
	^ connector elementFromTLDrawable: node
]

{ #category : 'tests' }
TLBlocConnectorShapeTest >> testAllShapesDemoGeneratesEachShapeSmokeTest [

	| demo |
	demo := TLDemos exampleAllShapes.
	demo generator: connector.
	demo generateWith: connector.
	self assert: connector view content children size equals: 15
]

{ #category : 'tests' }
TLBlocConnectorShapeTest >> testNodeWithoutShapeDrawsNothing [

	| element |
	element := self elementWithShape: TLNoShape width: 40 height: 40.
	self assert: element geometry class equals: BlEmptyGeometry.
	self assert: element outline isNil
]
