"
I test the connections between nodes drawn by the Bloc connector: a connection is an element of the view, it joins the borders of the outlines of its two nodes, whatever the groups the nodes are in, and it takes the color and the width of its style. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorConnectionTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'setup' }
TLBlocConnectorConnectionTest >> setUp [

	super setUp.
	visualization styleSheet
		width: 40;
		height: 40
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionIsAnElementOfTheView [

	| source target connection element |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	self assert: element class equals: TLBlocNodeConnection.
	self assert: (connector view children includes: element)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionJoinsNodesOfTwoSubGroups [

	| source target connection sourceElement targetElement element |
	source := visualization > #left addNodeFromEntity: 1.
	target := visualization > #right addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	sourceElement := connector elementFromTLDrawable: source.
	targetElement := connector elementFromTLDrawable: target.
	element := connector elementFromTLDrawable: connection.
	self assert: element start equals: (sourceElement topLeftRelativeTo: connector view) + (40 @ 20).
	self assert: element end equals: (targetElement topLeftRelativeTo: connector view) + (0 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionJoinsTheBordersOfItsNodes [

	| source target connection sourceElement targetElement element |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	connection := source connectTo: target.
	visualization generateWith: connector.
	sourceElement := connector elementFromTLDrawable: source.
	targetElement := connector elementFromTLDrawable: target.
	element := connector elementFromTLDrawable: connection.
	"The nodes are in a row: the connection leaves by the right of the source and arrives by the left of the target"
	self assert: element start equals: (sourceElement topLeftRelativeTo: connector view) + (40 @ 20).
	self assert: element end equals: (targetElement topLeftRelativeTo: connector view) + (0 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testConnectionTakesTheColorAndTheWidthOfItsStyle [

	| connection element |
	connection := (visualization addNodeFromEntity: 1) connectTo: (visualization addNodeFromEntity: 2).
	connection styleSheet
		color: Color red;
		width: 3.
	visualization generateWith: connector.
	element := connector elementFromTLDrawable: connection.
	self assert: element border paint color equals: Color red.
	self assert: element border width equals: 3
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testSimpleConnectionsDemoGeneratesItsSixConnections [

	| connections |
	visualization := TLDemos exampleSimpleConnections.
	visualization generator: connector.
	visualization generateWith: connector.
	connections := connector view children select: [ :each | each class == TLBlocNodeConnection ].
	self assert: connections size equals: 6
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testUpdatingConnectionsDoesNotMoveTheOutlineOfAnEllipse [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source styleSheet shape: TLEllipse.
	target styleSheet shape: TLEllipse.
	source connectTo: target.
	visualization generateWith: connector.
	connector updateConnections.
	self assert: (connector elementFromTLDrawable: target) outline center asPoint equals: 20 @ 20
]

{ #category : 'tests' }
TLBlocConnectorConnectionTest >> testUpdatingConnectionsDoesNotMoveTheOutlineOfTheNodes [

	| source target |
	source := visualization addNodeFromEntity: 1.
	target := visualization addNodeFromEntity: 2.
	source connectTo: target.
	visualization generateWith: connector.
	connector updateConnections.
	connector updateConnections.
	"The target is not at the origin of the view: its outline must still be in its own coordinates"
	self assert: ((connector elementFromTLDrawable: target) outline vertices collect: #asPoint as: Array) equals: {
			(0 @ 0).
			(40 @ 0).
			(40 @ 40).
			(0 @ 40) }
]
