Class {
	#name : 'TLBlocConnectorFitTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorFitTest >> assertEveryNodeIsInTheWindow [

	| window |
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	self nodeBoundsInWindow do: [ :rectangle | self assert: (window containsRect: rectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> contentCenterInWindow [

	| rectangle |
	rectangle := Rectangle merging: self nodeBoundsInWindow asArray.
	^ rectangle origin + (rectangle extent / 2)
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> contentRectangleInWindow [

	^ Rectangle merging: self nodeBoundsInWindow asArray
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> labelBoundsInWindow [
	"The rectangles of the labels of the nodes in the window"

	^ visualization allNodes collect: [ :node | (connector elementFromTLDrawable: node) children first boundsInSpace asRectangle ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> nodeBoundsInWindow [
	"The rectangles of the node elements in the window, whatever the zoom and the panning"

	^ visualization allNodes collect: [ :node | (connector elementFromTLDrawable: node) boundsInSpace asRectangle ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> openNodes: aNumber [
	"Opens a visualization of the given number of nodes, ten per line, in a window of 300 by 300"

	visualization layout: ((TLLinearLayout perLine: 10)
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: aNumber).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Fit'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testAutoFitIsOnAgainAfterBeingTurnedOnAgain [

	| zoomBefore |
	self openNodes: 3.
	connector view autoFitOnLayout: false.
	connector view autoFitOnLayout: true.
	zoomBefore := connector view zoom.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 400;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1500 milliSeconds.
	self assert: connector view zoom < zoomBefore
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testChangingTheLayoutFitsTheVisualizationAgain [

	| zoomBefore |
	self openNodes: 3.
	zoomBefore := connector view zoom.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 400;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self assert: connector view zoom < zoomBefore.
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testChangingTheLayoutFitsTheVisualizationAgainOnceTheAnimationIsDone [

	connector animationDuration: 300 milliSeconds.
	self openNodes: 3.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 400;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1500 milliSeconds.
	self assert: connector view zoom < 1.
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testContentIsFittedAgainIfTheToolbarIsMeasuredAfterTheFit [
	"The strip depends on the size of the toolbar, which is known after the first layout: the content is still clear of it at the end, in a window which is almost as wide as the toolbar"

	| toolbar |
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: 9).
	connector open: visualization inWindowSized: 240 @ 240 titled: 'Fit'.
	connector view space settleForDuration: 2 seconds.
	toolbar := connector view toolbar boundsInSpace asRectangle.
	self nodeBoundsInWindow do: [ :rectangle | self deny: (toolbar intersects: rectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testEnlargedVisualizationStaysInTheWindow [

	| window |
	self openNodes: 12.
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	self nodeBoundsInWindow do: [ :rectangle | self assert: (window containsRect: rectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitAreaIsTheWindowWithoutTheStripsOfTheToolbarAndOfTheLegend [

	| area |
	visualization legend description: 'Dead code' forColor: Color red.
	self openNodes: 3.
	area := connector view fitArea.
	self assert: area top >= connector view toolbar boundsInSpace bottom.
	self assert: area left > 0.
	self assert: area right equals: connector view space extent x.
	self assert: area bottom equals: connector view space extent y
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitAreaWithoutLegendStartsAtTheLeftOfTheWindow [

	self openNodes: 3.
	self assert: connector view fitArea left equals: 0
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitCanBeRequestedAgainAfterZoomingAndPanning [

	self openNodes: 200.
	connector view zoomBy: 3 around: 150 @ 150.
	connector view panBy: 40 @ 40.
	connector view fitIntoWindow.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: connector view zoom < 1.
	self assert: (self contentCenterInWindow - connector view fitArea center) abs < (2 @ 2)
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitCentersTheContentInTheWindow [
	"In the area the content may fill: the window without the strips of the toolbar and of the legend"

	self openNodes: 3.
	self assert: (self contentCenterInWindow - connector view fitArea center) abs < (2 @ 2)
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitForgetsThePanningAndTheZoomWhenTheLayoutIsApplied [

	self openNodes: 3.
	connector view zoomBy: 3 around: 150 @ 150.
	connector view panBy: 100 @ 100.
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 30;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1 seconds.
	self assertEveryNodeIsInTheWindow.
	self assert: (self contentCenterInWindow - connector view fitArea center) abs < (2 @ 2)
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitFunctionsWhenAutoFitIsOff [

	self openNodes: 200.
	connector view autoFitOnLayout: false.
	connector view zoomBy: 4 around: 150 @ 150.
	connector view fitIntoWindow.
	connector view space settleForDuration: 500 milliSeconds.
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitKeepsTheContentAwayFromTheLegend [
	"A square of nodes fills the window, so it would be under the legend"

	| legend |
	visualization legend
		description: 'Dead code' forColor: Color red;
		description: 'Alive code' forColor: Color green.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: 9).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Fit'.
	connector view space settleForDuration: 1 seconds.
	legend := (connector view space root children detect: [ :child | child class = TLBlocLegendElement ]) boundsInSpace asRectangle.
	self nodeBoundsInWindow do: [ :rectangle | self deny: (legend intersects: rectangle) ].
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitKeepsTheContentAwayFromTheToolbar [
	"A square of nodes fills the window, so it would be under the toolbar at the top right"

	| toolbar |
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: 9).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Fit'.
	connector view space settleForDuration: 1 seconds.
	toolbar := connector view toolbar boundsInSpace asRectangle.
	self nodeBoundsInWindow do: [ :rectangle | self deny: (toolbar intersects: rectangle) ].
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testFitWithoutLegendUsesTheWholeWindow [

	| rectangle |
	self openNodes: 40.
	rectangle := self contentRectangleInWindow.
	self assert: (rectangle left - connector view windowMargin) abs < 30
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testLabelsAboveTheNodesAreInTheWindowAfterTheFit [
	"The labels are placed once they are measured, after the first layout"

	| window |
	visualization styleSheet nodeLabel: #asString position: #top.
	visualization layout: (TLLinearLayout topToBottom
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: 15).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Fit'.
	connector view space settleForDuration: 2 seconds.
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	self labelBoundsInWindow do: [ :rectangle | self assert: (window containsRect: rectangle) ].
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testLabelsAddedByAnUpdateAreInTheWindowAfterTheFit [

	| window |
	visualization styleSheet nodeLabel: #asString position: #top.
	visualization layout: (TLLinearLayout topToBottom
			 gap: 20;
			 yourself).
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Fit'.
	connector view space settleForDuration: 1 seconds.
	visualization addNodesFromEntities: (4 to: 15).
	visualization update.
	connector view space settleForDuration: 2 seconds.
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	self labelBoundsInWindow do: [ :rectangle | self assert: (window containsRect: rectangle) ].
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testLargeVisualizationFitsTheWindowWhenItOpens [

	| window |
	self openNodes: 200.
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	self assert: connector view zoom < 1.
	self nodeBoundsInWindow do: [ :rectangle | self assert: (window containsRect: rectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testLayoutUpdateDoesNotFitWhenAutoFitIsOff [
	"The visualization stays where it is, even though the new layout makes it bigger than the window: the user asked not to fit it again"

	| zoomBefore |
	self openNodes: 3.
	connector view autoFitOnLayout: false.
	zoomBefore := connector view zoom.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 400;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1500 milliSeconds.
	self assert: connector view zoom equals: zoomBefore
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testLayoutUpdateStillFitsWhenAutoFitIsOn [

	| zoomBefore |
	self openNodes: 3.
	self assert: connector view autoFitOnLayout.
	zoomBefore := connector view zoom.
	visualization layout: ((TLLinearLayout perLine: 3)
			 gap: 400;
			 yourself).
	visualization update.
	connector view space settleForDuration: 1500 milliSeconds.
	self assert: connector view zoom < zoomBefore
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testNodesAddedByAnUpdateDoNotFitWhenAutoFitIsOff [
	"Neither the layout, nor the labels which are placed after it, make the visualization fit again"

	| zoomBefore |
	visualization styleSheet nodeLabel: #asString position: #top.
	self openNodes: 3.
	connector view autoFitOnLayout: false.
	zoomBefore := connector view zoom.
	visualization addNodesFromEntities: (4 to: 40).
	visualization update.
	connector view space settleForDuration: 2 seconds.
	self assert: connector view zoom equals: zoomBefore
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testPanningDuringTheSmoothFitStopsIt [

	| zoom |
	self openNodes: 200.
	connector view zoomBy: 3 around: 150 @ 150.
	zoom := connector view zoom.
	connector view fitIntoWindowSmoothly.
	connector view panBy: 10 @ 0.
	connector view space settleForDuration: 1 seconds.
	self assert: connector view zoom equals: zoom.
	self deny: connector view autoFit
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testPathBuilderIsFittedAfterItsOriginIsClicked [
	"The nodes it adds are in groups, and their labels are above them: the content is only known once the labels are placed"

	| builder window |
	builder := TLPathBuilder new
		           origin: 42;
		           incomingBlock: [ :aNumber | aNumber to: aNumber + 10 ];
		           outgoingBlock: [ :aNumber | aNumber - 11 to: aNumber - 1 ];
		           yourself.
	builder generator: connector.
	connector open: builder inWindowSized: 900 @ 600 titled: 'Path builder'.
	connector view space settleForDuration: 1 seconds.
	(connector elementFromTLDrawable: builder allNodes first) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 2 seconds.
	window := (0 @ 0 extent: connector view space extent) expandBy: 1.
	builder allNodes do: [ :node |
			| element |
			element := connector elementFromTLDrawable: node.
			self assert: (window containsRect: element boundsInSpace asRectangle).
			self assert: (window containsRect: element children first boundsInSpace asRectangle) ]
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testSmallVisualizationIsEnlargedToFillTheWindow [
	"The content touches the margin of the window on one axis, and is centered on the other"

	| rectangle window margin |
	self openNodes: 3.
	window := connector view space extent.
	margin := connector view windowMargin.
	rectangle := self contentRectangleInWindow.
	self assert: connector view zoom > 1.
	self assert: ((rectangle width - (window x - (margin * 2))) abs < 1 or: [ (rectangle height - (window y - (margin * 2))) abs < 1 ])
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testSmoothFitDoesNotJump [
	"The Fit button of the toolbar moves the visualization to the fit in a short animation"

	| zoom |
	self openNodes: 200.
	connector view zoomBy: 3 around: 150 @ 150.
	zoom := connector view zoom.
	connector view fitIntoWindowSmoothly.
	self assert: connector view zoom equals: zoom
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testSmoothFitEndsAsTheFit [

	| smoothZoom smoothCenter |
	self openNodes: 200.
	connector view zoomBy: 3 around: 150 @ 150.
	connector view panBy: 40 @ 40.
	connector view fitIntoWindowSmoothly.
	connector view space settleForDuration: 1 seconds.
	smoothZoom := connector view zoom.
	smoothCenter := self contentCenterInWindow.
	connector view fitIntoWindow.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: (smoothZoom - connector view zoom) abs < 0.0001.
	self assert: (smoothCenter - self contentCenterInWindow) abs < (0.5 @ 0.5).
	self assert: connector view autoFit
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testSmoothFitPassesThroughTheZoomsBetween [
	"The zoom changes progressively from the one before the fit to the one of the fit"

	| zooms before |
	self openNodes: 200.
	connector view zoomBy: 3 around: 150 @ 150.
	before := connector view zoom.
	zooms := OrderedCollection new.
	connector view fitIntoWindowSmoothly.
	15 timesRepeat: [
			connector view space settleForDuration: 20 milliSeconds.
			zooms add: connector view zoom ].
	connector view space settleForDuration: 1 seconds.
	self assert: (zooms anySatisfy: [ :zoom | zoom < before and: [ zoom > connector view zoom ] ])
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testUpdatingWithoutApplyingTheLayoutKeepsTheZoom [

	| zoomBefore |
	self openNodes: 3.
	connector view zoomBy: 0.5 around: 150 @ 150.
	zoomBefore := connector view zoom.
	visualization update.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: connector view zoom equals: zoomBefore
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testVisualizationIsFittedWhenItOpensWhateverAutoFit [
	"Auto fit is about the layouts which are applied again: the first one still fits"

	connector view autoFitOnLayout: false.
	self openNodes: 200.
	self assert: connector view zoom < 1.
	self assertEveryNodeIsInTheWindow
]

{ #category : 'tests' }
TLBlocConnectorFitTest >> testZoomIsNeverBeyondTheMaximumOfTheZoom [

	self openNodes: 1.
	self assert: connector view zoom <= connector view class maximumZoom
]
