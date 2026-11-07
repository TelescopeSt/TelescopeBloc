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
	node := connector view content children first.
	before := self originOfTheView.
	self pressAt: 50 @ 50 on: node.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: self originOfTheView equals: before
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testDraggingTheBackgroundPansTheVisualization [

	| root before |
	root := connector view space root.
	before := self originOfTheView.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: self originOfTheView equals: before + (30 @ 20)
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
TLBlocConnectorPanTest >> testNodesAreLookedForUnderTheMouseAgainAfterThePan [

	| root node |
	root := connector view space root.
	node := connector view content children detect: [ :child | child class == TLBlocNodeElement ].
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self settle.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	self assert: (root findMouseEventTargetAt: node boundsInSpace center) identicalTo: node
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testNodesAreNotLookedForUnderTheMouseWhilePanning [
	"Looking for the element under the mouse goes through all the nodes, whose bounds in the window change at each step of a pan: the window would only show a few frames per second. During a pan the mouse events are for the background"

	| root node center |
	root := connector view space root.
	node := connector view content children detect: [ :child | child class == TLBlocNodeElement ].
	center := node boundsInSpace center.
	self assert: (root findMouseEventTargetAt: center) identicalTo: node.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self settle.
	center := node boundsInSpace center.
	self assert: (root findMouseEventTargetAt: center) identicalTo: root
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningAZoomedInVisualizationHasNoCompositionLayer [
	"The layer is as big as the content in the window: zoomed in, it would take too much memory"

	| root |
	connector view space close.
	connector := TLBlocConnector new.
	connector
		host: BlHeadlessHost default;
		animationDuration: 0 seconds.
	visualization := TLVisualization new.
	visualization generator: connector.
	visualization layout: TLLinearLayout new.
	visualization addNodesFromEntities: (1 to: 40).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Navigation'.
	self settle.
	connector view zoomBy: TLBlocVisualization maximumZoom around: 0 @ 0.
	self settle.
	root := connector view space root.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self deny: connector view content compositingMode wantsCompositionLayer
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningDoesNotLayOutTheVisualizationAgain [
	"The panning only changes the transformation of the visualization, as the zoom does"

	connector view panBy: 30 @ 20.
	self deny: connector view space isLayoutRequested
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningKeepsTheOffsetAfterALayout [

	| root before |
	root := connector view space root.
	before := self originOfTheView.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self releaseAt: 80 @ 70 on: root.
	self settle.
	connector view requestLayout.
	self settle.
	self assert: self originOfTheView equals: before + (30 @ 20)
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningPutsTheContentInACompositionLayer [
	"While the background is dragged only the place of the content changes: Bloc paints the content it drew once instead of drawing all the nodes at each step"

	| root |
	root := connector view space root.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self assert: connector view content compositingMode wantsCompositionLayer
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPanningWithACompositionLayerDrawsTheSameAsWithout [
	"The layer is painted at the place of the content, which is not on a whole pixel: only the edges of the shapes can be half a pixel away"

	| root withLayer withoutLayer differing |
	root := connector view space root.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self settle.
	root asForm.
	self moveTo: 90 @ 80 on: root.
	self settle.
	withLayer := root asForm.
	self assert: connector view content hasCompositionLayer.
	self releaseAt: 90 @ 80 on: root.
	self settle.
	withoutLayer := root asForm.
	differing := (1 to: withLayer bits size) count: [ :index | (withLayer bits at: index) ~= (withoutLayer bits at: index) ].
	self assert: differing < (withLayer bits size / 100)
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testPlacingTheContentAtTheSamePlaceDoesNotRedrawIt [
	"A drag places the content again at each move of the mouse, mostly at the same place: changing the transformation of the visualization, even to the same one, makes Bloc draw all the nodes again"

	| space |
	space := connector view space.
	space clearDirtyElements.
	connector view panBy: 0 @ 0.
	self deny: space hasDirtyElements
]

{ #category : 'tests' }
TLBlocConnectorPanTest >> testReleasingTheMouseEndsTheCompositionLayer [
	"Out of a pan, a change of the content, such as a highlight, would draw the whole layer again"

	| root |
	root := connector view space root.
	self pressAt: 50 @ 50 on: root.
	self moveTo: 80 @ 70 on: root.
	self settle.
	self releaseAt: 80 @ 70 on: root.
	self deny: connector view content compositingMode wantsCompositionLayer.
	self assert: connector view content compositionLayer isNil
]
