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
TLBlocConnectorInteractionTest >> testAddedConnectionsJoinTheirNodes [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self connectionElements do: [ :element | self deny: element start equals: element end ]
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
