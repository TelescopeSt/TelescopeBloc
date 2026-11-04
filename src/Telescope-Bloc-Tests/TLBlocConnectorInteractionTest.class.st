Class {
	#name : 'TLBlocConnectorInteractionTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> click: aNode [

	(connector elementFromTLDrawable: aNode) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> connectFirstNodeToTheOthersOnMouseOver [
	"Opens a visualization of three nodes, the first one being connected to the two others while the mouse is over it. Answers the first node"

	| nodes |
	nodes := (1 to: 3) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization addInteraction: ((TLConnectAction property: [ :entity | #( 2 3 ) ] context: visualization allNodes)
			 connectToOrigin: false;
			 yourself) onMouseOver.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	^ nodes first
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> connectionElements [

	^ connector view children select: [ :element | element class = TLBlocNodeConnection ]
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> connectionTargetEntities [
	"The entities of the nodes the connection elements go to"

	^ (self connectionElements collect: [ :element | (visualization allNodes detect: [ :node | (connector elementFromTLDrawable: node) == element toNode ]) entity ] as: Array) asSortedCollection asArray
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> expandOnClick [
	"Opens a visualization of the nodes 1 and 2, whose click adds a child of the entity multiplied by ten, or removes it again. Answers the first node"

	| nodes |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization addInteraction: (TLExpandCollapseNodesAction property: [ :entity | { (entity * 10) } ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	^ nodes first
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> mouseEnter: aNode [

	(connector elementFromTLDrawable: aNode) dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> mouseLeave: aNode [

	(connector elementFromTLDrawable: aNode) dispatchEvent: BlMouseLeaveEvent new.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> nodeElements [

	^ connector view children select: [ :element | element class = TLBlocNodeElement ]
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> openWithTwoConnectionsAndTheirActions [
	"Opens a visualization where the node 1 is connected to the node 2, and to the node 3 with a hidden connection. A click on the node 1 hides the first connection and shows the second one, a second click does the opposite. Answers the node 1"

	| nodes shown hidden |
	nodes := (1 to: 3) collect: [ :entity | visualization addNodeFromEntity: entity ].
	shown := nodes first connectTo: nodes second.
	hidden := nodes first connectTo: nodes third.
	hidden hide.
	visualization addInteractions: {
			(TLHideAction on: shown) onClick.
			(TLShowAction on: hidden) onClick }.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	^ nodes first
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testAddedConnectionsJoinTheirNodes [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self connectionElements do: [ :element | self deny: element start equals: element end ]
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testClickShowsAHiddenConnectionAndHidesAVisibleOne [

	self click: self openWithTwoConnectionsAndTheirActions.
	self assert: self connectionTargetEntities equals: #( 3 )
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testClickingANodeExpandsIt [

	| node |
	node := self expandOnClick.
	self assert: self nodeElements size equals: 2.
	self click: node.
	self assert: self nodeElements size equals: 3.
	self assert: self connectionElements size equals: 1
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testClickingAnExpandedNodeCollapsesIt [

	| node |
	node := self expandOnClick.
	self click: node.
	self click: node.
	self assert: self nodeElements size equals: 2.
	self assertEmpty: self connectionElements
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testHiddenConnectionIsNotDrawnAtFirst [

	self openWithTwoConnectionsAndTheirActions.
	self assert: self connectionTargetEntities equals: #( 2 )
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseLeavingTheNodeRemovesTheConnectionsAgain [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self mouseLeave: node.
	self assertEmpty: self connectionElements
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseOverANodeAddsTheConnectionsOfTheAction [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self assert: self connectionElements size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testSecondClickDoesTheOpposite [

	| node |
	node := self openWithTwoConnectionsAndTheirActions.
	self click: node.
	self click: node.
	self assert: self connectionTargetEntities equals: #( 2 )
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testShownConnectionJoinsItsNodes [

	self click: self openWithTwoConnectionsAndTheirActions.
	self connectionElements do: [ :element | self deny: element start equals: element end ]
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testTheConnectionsCanBeAddedAgain [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self mouseLeave: node.
	self mouseEnter: node.
	self assert: self connectionElements size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testTheExpandedNodeIsPlacedByTheLayout [

	| node child |
	node := self expandOnClick.
	self click: node.
	child := visualization allNodes detect: [ :each | each entity = 10 ].
	self deny: (connector elementFromTLDrawable: child) measuredBounds position equals: (connector elementFromTLDrawable: node) measuredBounds position
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testThereIsNoConnectionBeforeTheMouseIsOver [

	self connectFirstNodeToTheOthersOnMouseOver.
	self assertEmpty: self connectionElements
]
