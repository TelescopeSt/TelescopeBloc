"
I test the panning of a visualization in a window: dragging the background with the primary button moves the visualization. A press on a node does not pan, and moving the mouse without pressing does not either. I inherit the window and the mouse event helpers from TLBlocConnectorNavigationTest.
"
Class {
	#name : 'TLBlocConnectorPanTest',
	#superclass : 'TLBlocConnectorNavigationTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

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
