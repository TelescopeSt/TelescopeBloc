Class {
	#name : 'TLBlocConnectorGridTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorGridTest >> grid [

	^ self root children
		  detect: [ :child | child class = TLBlocGridElement ]
		  ifNone: [ nil ]
]

{ #category : 'helpers' }
TLBlocConnectorGridTest >> open [

	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Grid'.
	self settle
]

{ #category : 'helpers' }
TLBlocConnectorGridTest >> root [

	^ connector view space root
]

{ #category : 'helpers' }
TLBlocConnectorGridTest >> settle [

	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsAreAtTheOriginOfTheContent [
	"The dots are a grid of the content: a point of the content stays on a dot whatever the panning and the zoom"

	| origin spacing |
	self open.
	connector view zoomBy: 1.3 around: 50 @ 50.
	connector view panBy: 17 @ 9.
	origin := connector view content localPointToGlobal: 0 @ 0.
	spacing := self grid dotSpacing.
	self assert: (origin x - self grid dotOrigin x / spacing) rounded * spacing closeTo: origin x - self grid dotOrigin x.
	self assert: (origin y - self grid dotOrigin y / spacing) rounded * spacing closeTo: origin y - self grid dotOrigin y
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsAreDrawn [

	| form origin |
	self open.
	origin := self grid dotOrigin + (self grid dotSpacing @ self grid dotSpacing).
	form := self root asForm.
	self deny: (form colorAt: origin rounded) equals: (form colorAt: origin rounded + (self grid dotSpacing / 2) rounded)
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsAreNeitherTooCloseNorTooFar [
	"When the content is zoomed out, every other dot is drawn, and when it is zoomed in, dots are added between them"

	self open.
	connector view zoomBy: TLBlocVisualization minimumZoom / connector view zoom around: 0 @ 0.
	self assert: self grid dotSpacing >= TLBlocGridElement minimumSpacing.
	connector view zoomBy: TLBlocVisualization maximumZoom / connector view zoom around: 0 @ 0.
	self assert: self grid dotSpacing <= TLBlocGridElement maximumSpacing
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsFollowThePanning [

	| before |
	self open.
	before := self grid dotOrigin.
	connector view panBy: 3 @ 2.
	self assert: (self grid dotOrigin - before - (3 @ 2)) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsFollowTheZoom [

	| before |
	self open.
	connector view zoomBy: 1 / connector view zoom around: 0 @ 0.
	before := self grid dotSpacing.
	connector view zoomBy: 1.5 around: 0 @ 0.
	self assert: self grid dotSpacing closeTo: before * 1.5
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testDotsHaveTheColorOfTheTheme [

	connector theme: TLBlocDarkTheme new.
	self open.
	self assert: self grid dotColor equals: TLBlocDarkTheme new gridColor
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridCanBeHidden [

	connector gridVisible: false.
	self open.
	self assert: self grid isNil
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridDoesNotTakeTheMouse [
	"A press on the background is for the root, where the panning starts"

	self open.
	self assert: (self root findMouseEventTargetAt: 390 @ 290) identicalTo: self root
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridFollowsTheSetting [

	| previous |
	previous := TLBlocConnector gridVisible.
	[
		TLBlocConnector gridVisible: false.
		self open.
		self assert: self grid isNil ] ensure: [ TLBlocConnector gridVisible: previous ]
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridIsBehindTheVisualization [

	self open.
	self assert: self grid isNotNil.
	self assert: (self root children indexOf: self grid) < (self root children indexOf: connector view)
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridIsDrawnAgainWhenTheVisualizationMoves [

	| space |
	self open.
	space := connector view space.
	space clearDirtyElements.
	connector view panBy: 3 @ 2.
	self assert: ((space instVarNamed: #elementsNeedingPaint) includes: self grid)
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridIsVisibleByDefault [

	self assert: TLBlocConnector defaultGridVisible
]

{ #category : 'tests' }
TLBlocConnectorGridTest >> testGridOfAConnectorWinsOverTheSetting [

	| previous |
	previous := TLBlocConnector gridVisible.
	[
		TLBlocConnector gridVisible: false.
		connector gridVisible: true.
		self open.
		self assert: self grid isNotNil ] ensure: [ TLBlocConnector gridVisible: previous ]
]
