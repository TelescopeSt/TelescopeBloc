"
I test the zoom of a visualization in a window: the mouse wheel zooms around the mouse position, and the zoom is limited.
"
Class {
	#name : 'TLBlocConnectorZoomTest',
	#superclass : 'TLBlocConnectorNavigationTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollingDownZoomsOut [

	self scrollDownAt: 100 @ 100.
	self assert: connector view zoom < 1
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollingUpZoomsIn [

	self scrollUpAt: 100 @ 100.
	self assert: connector view zoom > 1
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomIsLimited [

	200 timesRepeat: [ self scrollUpAt: 100 @ 100 ].
	self assert: connector view zoom equals: TLBlocVisualization maximumZoom.
	400 timesRepeat: [ self scrollDownAt: 100 @ 100 ].
	self assert: connector view zoom equals: TLBlocVisualization minimumZoom
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomKeepsThePointUnderTheCursorFixed [

	| cursor localBefore localAfter |
	cursor := 120 @ 90.
	localBefore := cursor - connector view position / connector view zoom.
	self scrollUpAt: cursor.
	self settle.
	localAfter := cursor - connector view position / connector view zoom.
	self assert: (localAfter - localBefore) abs < (0.5 @ 0.5)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomedVisualizationStillPansByTheDragDistance [

	| root before |
	root := connector view space root.
	self scrollUpAt: 100 @ 100.
	self settle.
	before := connector view position.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: connector view position equals: before + (30 @ 20)
]
