Class {
	#name : 'TLBlocConnectorDragTest',
	#superclass : 'TLBlocConnectorNavigationTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

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
TLBlocConnectorDragTest >> nodeElement [
	"The first node of the visualization"

	^ connector elementFromTLDrawable: visualization allNodes first
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
TLBlocConnectorDragTest >> testDraggingANodeMovesIt [

	| node before |
	node := self nodeElement.
	before := node measuredBounds position.
	self drag: node by: 60 @ 40.
	self assert: node measuredBounds position equals: before + (60 @ 40)
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
TLBlocConnectorDragTest >> testNodeKnowsItWasDragged [

	self drag: self nodeElement by: 60 @ 40.
	self assert: self nodeElement wasDragged
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
