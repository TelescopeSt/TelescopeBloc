"
I test the panning of a visualization in a window: dragging the background with the primary button moves the visualization. The mouse events are sent to the root of the window, so no real mouse is needed. I inherit the connector, the visualization and the window cleaning from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorPanTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'running' }
TLBlocConnectorPanTest >> moveTo: aPoint on: anElement [

	anElement dispatchEvent: (BlMouseMoveEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorPanTest >> pressAt: aPoint on: anElement [

	anElement dispatchEvent: (BlMouseDownEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorPanTest >> releaseAt: aPoint on: anElement [

	anElement dispatchEvent: (BlMouseUpEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorPanTest >> setUp [

	super setUp.
	visualization layout: TLLinearLayout new.
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Panning'.
	self settle
]

{ #category : 'running' }
TLBlocConnectorPanTest >> settle [

	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testDraggingANodeDoesNotPanTheVisualization [

	| root node before |
	root := connector view space root.
	node := connector view children first.
	before := connector view position.
	self pressAt: 50 @ 50 on: node.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: connector view position equals: before
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testDraggingTheBackgroundPansTheVisualization [

	| root before |
	root := connector view space root.
	before := connector view position.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: connector view position equals: before + (30 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testMovingAfterReleaseDoesNotPan [

	| root before |
	root := connector view space root.
	before := connector view position.
	self pressAt: 50 @ 50 on: root.
	self releaseAt: 50 @ 50 on: root.
	self moveTo: 120 @ 90 on: root.
	self settle.
	self assert: connector view position equals: before
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testMovingWithoutPressingDoesNotPan [

	| root before |
	root := connector view space root.
	before := connector view position.
	self moveTo: 80 @ 70 on: root.
	self moveTo: 120 @ 90 on: root.
	self settle.
	self assert: connector view position equals: before
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningKeepsTheOffsetAfterALayout [

	| root before |
	root := connector view space root.
	before := connector view position.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	connector view requestLayout.
	self settle.
	self assert: connector view position equals: before + (30 @ 20)
]
