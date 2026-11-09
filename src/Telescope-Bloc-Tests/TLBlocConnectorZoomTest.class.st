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
TLBlocConnectorZoomTest >> testBiggerScrollZoomsMore [
	"A trackpad sends the distance of its finger movement, not only a direction"

	self scroll: (BlVector x: 0 y: 3) at: 100 @ 100.
	self settle.
	self assert: connector view zoom closeTo: (TLBlocZoomHandler new zoomStep raisedTo: 3)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollingDownZoomsOut [
	self scrollDownAt: 100 @ 100.
	self settle.
	self assert: connector view zoom < 1
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollingInTheOtherDirectionComesBack [
	self scrollUpAt: 100 @ 100.
	self scrollDownAt: 100 @ 100.
	self settle.
	self assert: connector view zoom closeTo: 1
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollingUpZoomsIn [
	self scrollUpAt: 100 @ 100.
	self settle.
	self assert: connector view zoom > 1
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testScrollsInARowAddUp [
	"The events of a trackpad come faster than the animation of the zoom"

	3 timesRepeat: [ self scrollUpAt: 100 @ 100 ].
	self settle.
	self assert: connector view zoom closeTo: (TLBlocZoomHandler new zoomStep raisedTo: 3)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testSmallScrollZoomsLess [
	self scroll: (BlVector x: 0 y: 0.25) at: 100 @ 100.
	self settle.
	self assert: connector view zoom closeTo: (TLBlocZoomHandler new zoomStep raisedTo: 0.25)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomGoesThroughIntermediateValues [
	"The zoom is not a jump: it moves to its target during an animation, always in the same direction"

	| zooms target |
	target := TLBlocZoomHandler new zoomStep.
	self scrollUpAt: 100 @ 100.
	zooms := (1 to: 10) collect: [ :index |
		connector view space settleForDuration: 20 milliSeconds.
		connector view zoom ].
	self assert: (zooms anySatisfy: [ :zoom | zoom > 1 and: [ zoom < (target - 0.001) ] ]).
	zooms overlappingPairsDo: [ :before :after | self assert: after >= before ].
	self settle.
	self assert: connector view zoom closeTo: target
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomIsLimited [
	200 timesRepeat: [ self scrollUpAt: 100 @ 100 ].
	self settle.
	self assert: connector view zoom equals: TLBlocVisualization maximumZoom.
	400 timesRepeat: [ self scrollDownAt: 100 @ 100 ].
	self settle.
	self assert: connector view zoom equals: TLBlocVisualization minimumZoom
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomKeepsThePointUnderTheCursorFixed [

	| cursor localBefore localAfter |
	cursor := 120 @ 90.
	localBefore := cursor - self originOfTheView / connector view zoom.
	self scrollUpAt: cursor.
	self settle.
	localAfter := cursor - self originOfTheView / connector view zoom.
	self assert: (localAfter - localBefore) abs < (0.5 @ 0.5)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomedVisualizationStillPansByTheDragDistance [
	"The origin of the view is computed with the transformation of the zoom: it is right to a fraction of a pixel"

	| root before |
	root := connector view space root.
	self scrollUpAt: 100 @ 100.
	self settle.
	before := self originOfTheView.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: (self originOfTheView - (before + (30 @ 20))) abs < (0.05 @ 0.05)
]

{ #category : 'tests' }
TLBlocConnectorZoomTest >> testZoomingDoesNotLayOutTheVisualizationAgain [
	"The zoom only changes the transformation of the visualization: laying out its nodes and labels again at each step of the zoom would make it slow with many nodes"

	connector view zoomBy: 1.5 around: 100 @ 100.
	self deny: connector view space isLayoutRequested
]
