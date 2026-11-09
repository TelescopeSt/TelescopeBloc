Class {
	#name : 'TLBlocConnectorDragTest',
	#superclass : 'TLBlocConnectorNavigationTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorDragTest >> centerOfElementOf: aNode [

	^ (connector elementFromTLDrawable: aNode) boundsInSpace center
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> centerOfNode: aNode [

	| element |
	element := connector elementFromTLDrawable: aNode.
	^ element measuredBounds position + (element dimension / 2)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> drag: anElement by: aVector [
	"Presses on the element, moves the mouse in two steps, and releases it, like a user"

	| root start |
	root := connector view space root.
	start := 5 @ 5.
	self pressAt: start on: anElement.
	self moveTo: start + (aVector / 2) on: root.
	self moveTo: start + aVector on: root.
	self releaseAt: start + aVector on: root.
	self settle
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> dropNode: aNode onNode: anotherNode [
	"Presses on the center of the first node, moves the mouse and releases it over the center of the second one: all the positions are the ones of the window"

	| element root start target |
	element := connector elementFromTLDrawable: aNode.
	root := connector view space root.
	start := element boundsInSpace center.
	target := self centerOfElementOf: anotherNode.
	self pressAt: start on: element.
	self moveTo: start + target / 2 on: root.
	self moveTo: target on: root.
	self releaseAt: target on: root.
	self settle
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> dropRecorder: aCollection [
	"An action with the node which receives the drop and the node which was dropped on it: both entities are recorded"

	^ (TLCustomWithParameterAction block: [ :target :dropped | aCollection add: target entity -> dropped entity ]) onDrop
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> nodeElement [
	"The first node of the visualization"

	^ connector elementFromTLDrawable: visualization allNodes first
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> openDropDemo [
	"Opens the demo of the people which are dropped on tasks, in a window with a connector of its own"

	connector view space close.
	connector := TLBlocConnector new.
	connector host: BlHeadlessHost default.
	connector animationDuration: 0 seconds.
	visualization := TLDemos exampleDropAndDoubleClick.
	visualization generator: connector.
	connector open: visualization inWindowSized: 800 @ 500 titled: 'Demo'.
	self settle
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> openWithInteractions: someInteractions [
	"Opens again, with a visualization of the nodes 1, 2 and 3 which has the interactions, at their natural size"

	connector view space close.
	connector := TLBlocConnector new.
	connector host: BlHeadlessHost default.
	connector animationDuration: 0 seconds.
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector.
	visualization styleSheet nodeLabel: #asString position: #top.
	visualization layout: TLLinearLayout new.
	visualization addNodesFromEntities: (1 to: 3).
	visualization addInteractions: someInteractions.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Navigation'.
	self settle.
	connector view zoomBy: 1 / connector view zoom around: 0 @ 0.
	self settle
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> personNamed: aName [

	^ visualization allNodes detect: [ :node | node entity = aName ]
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testClickEndingADragDoesNotExecuteTheInteractionsOfTheNode [
	"The click interaction of Telescope is for a click, not for the end of a drag"

	| count |
	connector view space close.
	connector := TLBlocConnector new.
	connector host: BlHeadlessHost default.
	connector animationDuration: 0 seconds.
	count := 0.
	visualization := TLVisualization new.
	visualization
		nodeCreationStrategy: TLNodeCreationStrategy default;
		styleSheet: TLStyleSheet default;
		generator: connector.
	visualization addNodesFromEntities: (1 to: 3).
	visualization addInteraction: (TLCustomAction block: [ :each | count := count + 1 ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Drag'.
	self settle.
	self drag: self nodeElement by: 60 @ 40.
	self nodeElement dispatchEvent: BlClickEvent new.
	self assert: count equals: 0.
	self pressAt: 5 @ 5 on: self nodeElement.
	self releaseAt: 5 @ 5 on: connector view space root.
	self nodeElement dispatchEvent: BlClickEvent new.
	self assert: count equals: 1
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testConnectionsFollowTheDraggedNode [

	| connection before |
	connection := visualization allNodes first connectTo: visualization allNodes last.
	visualization update.
	self settle.
	before := (connector elementFromTLDrawable: connection) start.
	self drag: self nodeElement by: 0 @ 80.
	self deny: (connector elementFromTLDrawable: connection) start equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggedNodeGoesBackWhenTheLayoutIsApplied [

	| node before |
	node := self nodeElement.
	before := node measuredBounds position.
	self drag: node by: 60 @ 40.
	visualization layout: TLLinearLayout new.
	visualization update.
	self settle.
	self assert: node measuredBounds position equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggingANodeDoesNotPanTheVisualization [

	| before |
	before := connector view measuredBounds position.
	self drag: self nodeElement by: 60 @ 40.
	self assert: connector view measuredBounds position equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggingANodeJoinsAgainTheConnectionsOfTheNodesWhichMovedMeanwhile [
	"Something else than the drag moves a node, for example a composite node which fits its children once a label is measured: its connections must not stay where the node was"

	| nodes connection lastElement routeFollowingTheNodes |
	nodes := visualization allNodes.
	connection := nodes second connectTo: nodes last.
	visualization update.
	self settle.
	lastElement := connector elementFromTLDrawable: nodes last.
	lastElement placeAt: lastElement placement + (0 @ 50).
	self settle.
	self drag: self nodeElement by: 0 @ 10.
	routeFollowingTheNodes := (connector elementFromTLDrawable: connection) route points.
	connector updateConnectionRoutes.
	self assert: (connector elementFromTLDrawable: connection) route points equals: routeFollowingTheNodes
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggingANodeJoinsAgainTheConnectionsWhichGoAroundTheNodes [
	"A connection with segments goes around the nodes in its way, and the node which moves may be in it"

	| nodes joinedToTheNode other routeBefore |
	nodes := visualization allNodes.
	joinedToTheNode := nodes first connectTo: nodes second.
	other := nodes second connectTo: nodes last.
	other styleSheet curveStyle: TLSegmentsCurve.
	visualization update.
	self settle.
	routeBefore := (connector elementFromTLDrawable: other) route.
	self drag: self nodeElement by: 0 @ 80.
	self deny: (connector elementFromTLDrawable: other) route == routeBefore
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggingANodeMovesIt [

	| node before |
	node := self nodeElement.
	before := node measuredBounds position.
	self drag: node by: 60 @ 40.
	self assert: node measuredBounds position equals: before + (60 @ 40)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDraggingANodeOnlyJoinsAgainTheConnectionsOfThatNode [
	"The other connections cannot change, and a drag asks for an update at each move of the mouse"

	| nodes joinedToTheNode other routesBefore |
	nodes := visualization allNodes.
	joinedToTheNode := nodes first connectTo: nodes second.
	other := nodes second connectTo: nodes last.
	visualization update.
	self settle.
	routesBefore := {
		                joinedToTheNode.
		                other } collect: [ :connection | (connector elementFromTLDrawable: connection) route ].
	self drag: self nodeElement by: 0 @ 80.
	self deny: (connector elementFromTLDrawable: joinedToTheNode) route == routesBefore first.
	self assert: (connector elementFromTLDrawable: other) route identicalTo: routesBefore last
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropDemoAssignsAPersonToTheTaskItIsDroppedOn [

	self openDropDemo.
	self dropNode: (self personNamed: 'Alice') onNode: (self personNamed: 'Test').
	self assert: connector connections size equals: 1.
	self assert: connector connections first toNode identicalTo: (connector elementFromTLDrawable: (self personNamed: 'Test'))
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropDemoDoesNotAssignTwiceTheSamePerson [

	self openDropDemo.
	2 timesRepeat: [ self dropNode: (self personNamed: 'Alice') onNode: (self personNamed: 'Test') ].
	self assert: connector connections size equals: 1
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropDemoSendsThePersonBackToItsPlaceAndKeepsTheAssignment [
	"The place is the one in the visualization: re-applying the layout also fits the visualization in the window again, which moves everything in the window"

	| alice before |
	self openDropDemo.
	alice := connector elementFromTLDrawable: (self personNamed: 'Alice').
	before := alice measuredBounds position.
	self dropNode: (self personNamed: 'Alice') onNode: (self personNamed: 'Test').
	self assert: connector connections size equals: 1.
	self assert: (alice measuredBounds position - before) r < 1.
	self deny: connector connections first start equals: connector connections first end
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropDemoShowsThePeopleAtTheLeftOfTheTasks [

	| people tasks |
	self openDropDemo.
	people := #( 'Alice' 'Bob' 'Carol' ) collect: [ :name | (self centerOfElementOf: (self personNamed: name)) x ].
	tasks := #( 'Write' 'Test' 'Review' ) collect: [ :name | (self centerOfElementOf: (self personNamed: name)) x ].
	self assert: people max < tasks min
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropDemoUnassignsAPersonWithADoubleClick [

	self openDropDemo.
	self dropNode: (self personNamed: 'Alice') onNode: (self personNamed: 'Test').
	self dropNode: (self personNamed: 'Alice') onNode: (self personNamed: 'Review').
	self assert: connector connections size equals: 2.
	(connector elementFromTLDrawable: (self personNamed: 'Alice')) dispatchEvent: BlDoubleClickEvent new.
	self settle.
	self assertEmpty: connector connections
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDropInteractionOfANodeWhichIsNotTheTargetIsNotExecuted [

	| drops |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	self dropNode: visualization allNodes last onNode: visualization allNodes first.
	self assert: (drops collect: #key) asArray equals: #( 1 )
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDroppedNodeIsAlsoMoved [
	"The moved interaction and the drop interaction are for different nodes: the dragged one and the one under it"

	| moves drops |
	moves := OrderedCollection new.
	drops := OrderedCollection new.
	self openWithInteractions: {
			(TLCustomWithParameterAction block: [ :each :position | moves add: each entity ]) onMove.
			(self dropRecorder: drops) }.
	self dropNode: visualization allNodes first onNode: visualization allNodes second.
	self assert: moves asArray equals: #( 1 ).
	self assert: drops asArray equals: { (2 -> 1) }
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testDroppedNodeStaysWhereItWasDropped [

	| node center |
	self openWithInteractions: { (self dropRecorder: OrderedCollection new) }.
	node := visualization allNodes first.
	self dropNode: node onNode: visualization allNodes second.
	center := self centerOfElementOf: node.
	self assert: (center - (self centerOfElementOf: visualization allNodes second)) r < 10
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testLabelFollowsTheEntityWhichTheMovedInteractionChanges [
	"The demo puts the position of the node in its entity, and the label shows the entity"

	| node |
	self openWithInteractions: { (TLCustomWithParameterAction block: [ :each :position | each entity: position x asInteger @ position y asInteger ]) onMove }.
	node := visualization allNodes first.
	self drag: (connector elementFromTLDrawable: node) by: 40 @ 30.
	self assert: (connector elementFromTLDrawable: node) children first labelText equals: node entity asString.
	self assert: node entity isPoint
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testMemorizedPositionIsKeptWhenTheLayoutIsApplied [

	| node dropped |
	self openWithInteractions: { TLMemorizeNodePositionAction onMove }.
	node := visualization allNodes first.
	self drag: (connector elementFromTLDrawable: node) by: 60 @ 40.
	dropped := self centerOfNode: node.
	visualization layout: TLLinearLayout new.
	visualization update.
	self settle.
	self assert: (self centerOfNode: node) equals: dropped
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testMovedInteractionIsExecutedWithTheNewCenterWhenTheNodeIsDropped [

	| positions node |
	positions := OrderedCollection new.
	self openWithInteractions: { (TLCustomWithParameterAction block: [ :each :position | positions add: each entity -> position ]) onMove }.
	node := visualization allNodes first.
	self drag: (connector elementFromTLDrawable: node) by: 40 @ 30.
	self assert: positions size equals: 1.
	self assert: positions first key equals: 1.
	self assert: (positions first value - (self centerOfNode: node)) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testMovedInteractionIsNotExecutedWithoutADrag [

	| positions node |
	positions := OrderedCollection new.
	self openWithInteractions: { (TLCustomWithParameterAction block: [ :each :position | positions add: position ]) onMove }.
	node := visualization allNodes first.
	self pressAt: 5 @ 5 on: (connector elementFromTLDrawable: node).
	self releaseAt: 5 @ 5 on: connector view space root.
	self assertEmpty: positions
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testMovedInteractionOfAnotherNodeIsNotExecuted [

	| positions |
	positions := OrderedCollection new.
	self openWithInteractions: { (TLCustomWithParameterAction block: [ :each :position | positions add: each entity ]) onMove }.
	self drag: (connector elementFromTLDrawable: visualization allNodes last) by: 40 @ 30.
	self assert: positions asArray equals: #( 3 )
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeDoesNotMoveAfterTheMouseIsReleased [

	| node before root |
	node := self nodeElement.
	self drag: node by: 60 @ 40.
	before := node measuredBounds position.
	root := connector view space root.
	self moveTo: 200 @ 200 on: root.
	self settle.
	self assert: node measuredBounds position equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeDroppedOnAnotherOneIsGivenToItsDropInteraction [

	| drops |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	self dropNode: visualization allNodes first onNode: visualization allNodes second.
	self assert: drops asArray equals: { (2 -> 1) }
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeDroppedOnNothingIsGivenToNoOne [

	| drops |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	self drag: (connector elementFromTLDrawable: visualization allNodes first) by: 0 @ 120.
	self assertEmpty: drops
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeFollowsTheMouseWhateverTheZoom [

	| node before |
	connector view zoomBy: 2 around: 0 @ 0.
	self settle.
	node := self nodeElement.
	before := node measuredBounds position.
	self drag: node by: 60 @ 40.
	self assert: node measuredBounds position equals: before + (30 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeIsNotDroppedOnItself [
	"A short drag leaves the pointer over the node itself"

	| drops |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	self drag: (connector elementFromTLDrawable: visualization allNodes first) by: 4 @ 0.
	self assertEmpty: drops
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodeKnowsItWasDragged [

	self drag: self nodeElement by: 60 @ 40.
	self assert: self nodeElement wasDragged
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testNodesAreUnderTheMouseAgainOnceTheDragIsOver [

	| root dragged other |
	connector view panBy: 0 @ 100.
	self settle.
	root := connector view space root.
	dragged := self nodeElement.
	other := connector elementFromTLDrawable: visualization allNodes last.
	self pressAt: 5 @ 5 on: dragged.
	self moveTo: 40 @ 40 on: root.
	self releaseAt: 40 @ 40 on: root.
	self settle.
	self assert: (root findMouseEventTargetAt: other boundsInSpace center) identicalTo: other
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testOnlyTheNodeUnderThePointerReceivesTheDrop [

	| drops |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	self dropNode: visualization allNodes first onNode: visualization allNodes last.
	self assert: drops asArray equals: { (3 -> 1) }
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testOtherNodesDoNotMove [

	| other before |
	other := connector elementFromTLDrawable: visualization allNodes last.
	before := other measuredBounds position.
	self drag: self nodeElement by: 60 @ 40.
	self assert: other measuredBounds position equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testOtherNodesStayInTheWindowWhenANodeIsDraggedBeyondTheTopLeftOfTheContent [
	"The node becomes the top left corner of the content, which the visualization is anchored to: the panning compensates"

	| other before |
	other := connector elementFromTLDrawable: visualization allNodes first.
	before := other boundsInSpace origin.
	self drag: (connector elementFromTLDrawable: visualization allNodes last) by: -300 @ -200.
	self assert: (other boundsInSpace origin - before) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testOtherNodesStayInTheWindowWhenTheTopLeftNodeIsDraggedAway [
	"The corner of the content is then another node: the panning compensates"

	| other before |
	other := connector elementFromTLDrawable: visualization allNodes last.
	before := other boundsInSpace origin.
	self drag: self nodeElement by: 200 @ 150.
	self assert: (other boundsInSpace origin - before) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testPositionIsNotKeptWithoutTheMemorizeAction [

	| node dropped |
	self openWithInteractions: #(  ).
	node := visualization allNodes first.
	self drag: (connector elementFromTLDrawable: node) by: 60 @ 40.
	dropped := self centerOfNode: node.
	visualization layout: TLLinearLayout new.
	visualization update.
	self settle.
	self deny: (self centerOfNode: node) equals: dropped
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testPressingWithoutADragIsNotADrop [

	| drops node |
	drops := OrderedCollection new.
	self openWithInteractions: { (self dropRecorder: drops) }.
	node := connector elementFromTLDrawable: visualization allNodes first.
	self pressAt: 5 @ 5 on: node.
	self releaseAt: 5 @ 5 on: connector view space root.
	self assertEmpty: drops
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testPressingWithoutMovingIsNotADrag [

	self pressAt: 5 @ 5 on: self nodeElement.
	self releaseAt: 5 @ 5 on: connector view space root.
	self deny: self nodeElement wasDragged
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testSecondaryButtonDoesNotDragTheNode [

	| node before root |
	node := self nodeElement.
	before := node measuredBounds position.
	root := connector view space root.
	node fireEvent: (BlMouseDownEvent new
			 position: 5 @ 5;
			 screenPosition: 5 @ 5;
			 button: BlMouseButton secondary;
			 yourself).
	self moveTo: 65 @ 45 on: root.
	self settle.
	self assert: node measuredBounds position equals: before
]

{ #category : 'tests' }
TLBlocConnectorDragTest >> testTheDraggedNodeIsUnderTheMouseWhileItIsDragged [
	"The nodes it passes over are not entered and left, which would run their mouse over interactions at each move, and the element under the mouse is not looked for among all the nodes"

	| root dragged other |
	connector view panBy: 0 @ 100.
	self settle.
	root := connector view space root.
	dragged := self nodeElement.
	other := connector elementFromTLDrawable: visualization allNodes last.
	self pressAt: 5 @ 5 on: dragged.
	self moveTo: 40 @ 40 on: root.
	self assert: (root findMouseEventTargetAt: other boundsInSpace center) identicalTo: dragged
]
