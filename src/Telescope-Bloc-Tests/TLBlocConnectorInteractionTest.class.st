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
TLBlocConnectorInteractionTest >> connectionElement [

	^ self connectionElements anyOne
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
TLBlocConnectorInteractionTest >> openTwoConnectedVisualizations [
	"As the demo: clicking a node of the first visualization colors the opposite node of the second one in red, and the other way round in green. Each visualization has its own connector and window. Answers the second visualization and its connector"

	| other otherConnector |
	other := TLVisualization new.
	otherConnector := TLBlocConnector new.
	otherConnector host: BlHeadlessHost default.
	otherConnector animationDuration: 0 seconds.
	other
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: otherConnector.
	visualization styleSheet nodeLabel: #asString.
	other styleSheet nodeLabel: #asString.
	visualization addNodesFromEntities: (1 to: 5).
	other addNodesFromEntities: (-5 to: -1).
	visualization addInteraction:
		((TLStyleCustomizationAction custom: [ :style | style backgroundColor: Color red ] target: [ :aNode | other nodeForEntity: aNode entity negated ]) updateAlso: other) onClick.
	other addInteraction:
		((TLStyleCustomizationAction custom: [ :style | style backgroundColor: Color green ] target: [ :aNode | visualization nodeForEntity: aNode entity negated ]) updateAlso: visualization) onClick.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'First'.
	otherConnector open: other inWindowSized: 400 @ 300 titled: 'Second'.
	connector view space settleForDuration: 500 milliSeconds.
	otherConnector view space settleForDuration: 500 milliSeconds.
	^ other -> otherConnector
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> openWithHighlightOnMouseOver: aCustomizationBlock [
	"Opens a visualization of two nodes connected one to the other, where the mouse over a node or over the connection changes the style. Answers the node 1"

	| nodes connection highlight |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	connection := nodes first connectTo: nodes second.
	highlight := (TLStyleCustomizationAction custom: aCustomizationBlock) onMouseOver.
	visualization addInteraction: highlight.
	connection addInteraction: highlight.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	^ nodes first
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> openWithRightClickCounter [
	"Opens a visualization of a node whose right click increments a counter, and answers the counter in an array"

	| counter |
	counter := Array with: 0.
	visualization addNodesFromEntities: #( 1 ).
	visualization addInteraction: (TLCustomAction block: [ :node | counter at: 1 put: (counter at: 1) + 1 ]) onRightClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	^ counter
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
TLBlocConnectorInteractionTest >> pressOn: anElement button: aButton [

	anElement fireEvent: (BlMouseDownEvent new
			 position: 5 @ 5;
			 screenPosition: 905 @ 505;
			 button: aButton;
			 yourself).
	connector view space settleForDuration: 300 milliSeconds
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
TLBlocConnectorInteractionTest >> testClickingANodeColorsTheOppositeNodeOfTheOtherVisualization [

	| pair other otherConnector |
	pair := self openTwoConnectedVisualizations.
	other := pair key.
	otherConnector := pair value.
	[
		| before |
		before := (otherConnector elementFromTLDrawable: (other nodeForEntity: -3)) background paint color.
		(connector elementFromTLDrawable: (visualization nodeForEntity: 3)) dispatchEvent: BlClickEvent new.
		connector view space settleForDuration: 500 milliSeconds.
		otherConnector view space settleForDuration: 500 milliSeconds.
		self assert: (otherConnector elementFromTLDrawable: (other nodeForEntity: -3)) background paint color equals: Color red.
		self deny: before equals: Color red.
		self deny: (otherConnector elementFromTLDrawable: (other nodeForEntity: -2)) background paint color equals: Color red ] ensure: [ otherConnector view space ifNotNil: #close ]
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
TLBlocConnectorInteractionTest >> testClickingAgainRestoresTheOppositeNode [

	| pair other otherConnector original |
	pair := self openTwoConnectedVisualizations.
	other := pair key.
	otherConnector := pair value.
	[
		original := (otherConnector elementFromTLDrawable: (other nodeForEntity: -3)) background paint color.
		2 timesRepeat: [
				(connector elementFromTLDrawable: (visualization nodeForEntity: 3)) dispatchEvent: BlClickEvent new.
				connector view space settleForDuration: 500 milliSeconds.
				otherConnector view space settleForDuration: 500 milliSeconds ].
		self assert: (otherConnector elementFromTLDrawable: (other nodeForEntity: -3)) background paint color equals: original ] ensure: [ otherConnector view space ifNotNil: #close ]
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
TLBlocConnectorInteractionTest >> testClickingTheOtherVisualizationColorsTheOppositeNodeGreen [

	| pair other otherConnector |
	pair := self openTwoConnectedVisualizations.
	other := pair key.
	otherConnector := pair value.
	[
		(otherConnector elementFromTLDrawable: (other nodeForEntity: -4)) dispatchEvent: BlClickEvent new.
		otherConnector view space settleForDuration: 500 milliSeconds.
		connector view space settleForDuration: 500 milliSeconds.
		self assert: (connector elementFromTLDrawable: (visualization nodeForEntity: 4)) background paint color equals: Color green ] ensure: [ otherConnector view space ifNotNil: #close ]
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testClosingTheVisualizationClosesItsWindow [

	visualization addNodesFromEntities: #( 1 ).
	visualization addInteraction: (TLCustomAction block: [ :node | visualization close ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	self assert: connector view space isNotNil.
	self click: visualization allNodes first.
	self assert: connector view space isNil
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testHiddenConnectionIsNotDrawnAtFirst [

	self openWithTwoConnectionsAndTheirActions.
	self assert: self connectionTargetEntities equals: #( 2 )
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testInteractionsAreNotAddedAgainByUpdates [
	"An update which changes the style, as the highlight of the mouse over does, does not change the interactions: the click is executed once"

	| count node |
	count := Array with: 0.
	node := visualization addNodeFromEntity: 1.
	visualization addInteractions: {
			(TLCustomAction block: [ :each | count at: 1 put: (count at: 1) + 1 ]) onClick.
			(TLStyleCustomizationAction custom: [ :style | style borderColor: Color red ]) onMouseOver }.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	self mouseEnter: node.
	self mouseLeave: node.
	self mouseEnter: node.
	self mouseLeave: node.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	self assert: count first equals: 1
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
TLBlocConnectorInteractionTest >> testMouseOverAConnectionChangesItsColorUntilTheMouseLeaves [

	| element before |
	self openWithHighlightOnMouseOver: [ :style | style color: Color red ].
	element := self connectionElement.
	before := element border paint color.
	element dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: element border paint color equals: Color red.
	self assert: element head background paint color equals: Color red.
	element dispatchEvent: BlMouseLeaveEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: element border paint color equals: before
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseOverAConnectionStillJoinsItsNodes [

	| element |
	self openWithHighlightOnMouseOver: [ :style | style color: Color red ].
	element := self connectionElement.
	element dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self deny: element start equals: element end
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseOverANodeAddsTheConnectionsOfTheAction [

	| node |
	node := self connectFirstNodeToTheOthersOnMouseOver.
	self mouseEnter: node.
	self assert: self connectionElements size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseOverANodeChangesItsBackgroundUntilTheMouseLeaves [

	| node before |
	node := self openWithHighlightOnMouseOver: [ :style | style backgroundColor: Color green ].
	before := (connector elementFromTLDrawable: node) background paint color.
	self mouseEnter: node.
	self assert: (connector elementFromTLDrawable: node) background paint color equals: Color green.
	self mouseLeave: node.
	self assert: (connector elementFromTLDrawable: node) background paint color equals: before
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testMouseOverANodeChangesItsBorderUntilTheMouseLeaves [

	| node before |
	node := self openWithHighlightOnMouseOver: [ :style | style borderColor: Color red ].
	before := (connector elementFromTLDrawable: node) border paint color.
	self mouseEnter: node.
	self assert: (connector elementFromTLDrawable: node) border paint color equals: Color red.
	self mouseLeave: node.
	self assert: (connector elementFromTLDrawable: node) border paint color equals: before
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testNodeMovedToAnotherGroupGetsTheInteractionsOfThatGroup [

	| counters moved element |
	counters := Array with: 0 with: 0.
	(visualization > #group1)
		addNodesFromEntities: #( 1 2 );
		addInteraction: (TLCustomAction block: [ :node | counters at: 1 put: (counters at: 1) + 1 ]) onClick.
	(visualization > #group2)
		addNodesFromEntities: #( 3 );
		addInteraction: (TLCustomAction block: [ :node | counters at: 2 put: (counters at: 2) + 1 ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	moved := visualization allNodes detect: [ :node | node entity = 1 ].
	moved moveToGroup: visualization > #group2.
	visualization update.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: moved.
	element dispatchEvent: BlClickEvent new.
	self assert: counters asArray equals: #( 0 1 )
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testPrimaryButtonDoesNotExecuteTheRightClickAction [

	| counter element |
	counter := self openWithRightClickCounter.
	element := connector elementFromTLDrawable: visualization allNodes first.
	self pressOn: element button: BlMouseButton primary.
	self assert: counter first equals: 0
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testRightClickActionHasPriorityOverTheMenuOfTheNode [
	"The menu only reminds that a right click does something: opening it on a node the action may have removed would be wrong"

	| counter action element |
	counter := Array with: 0.
	visualization addNodesFromEntities: #( 1 ).
	action := TLCustomAction block: [ :node | counter at: 1 put: (counter at: 1) + 1 ].
	visualization addInteractions: {
			action onRightClick.
			(action withMenu: 'Do it (Right Click)') }.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Interactions'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: visualization allNodes first.
	self pressOn: element button: BlMouseButton secondary.
	self assert: counter first equals: 1.
	self assert: (connector view space root children noneSatisfy: [ :child | child class = TLBlocMenuPopup ])
]

{ #category : 'tests' }
TLBlocConnectorInteractionTest >> testRightClickExecutesTheActionOfTheNode [

	| counter element |
	counter := self openWithRightClickCounter.
	element := connector elementFromTLDrawable: visualization allNodes first.
	self pressOn: element button: BlMouseButton secondary.
	self assert: counter first equals: 1
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
