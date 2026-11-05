"
I am the Bloc element that holds the elements of a Telescope visualization: the nodes with their labels. I move myself so that the content starts at the margin of the window, shifted by the panning, and I scale myself with the zoom. The pan and zoom handlers are installed on the root of the window while I am in it. The first time I am laid out with some content I am fitted into the window: scaled so that the content fills the window, down or up as far as the zoom allows, and centered, which #fitIntoWindow does again on request. #zoomIn and #zoomOut zoom around the center of the window, and #exportAsPngTo: and #exportAsSvgTo: write me as I am shown. I put my toolbar in the root of the window while I am in it. I do not clip my children, because the window already clips me. I let the user drag the nodes, and the panning compensates the nodes which move my content, so that the other nodes stay under the mouse. The connector is told when a node moved, to join the nodes again. I keep the legend, and I fit my content in what is at its right. After a fit, I fit myself again when my content changes, until the user pans, zooms or drags, because the content is only known after a few layouts. It finds the node under the point where a node was dropped (#dropTargetOf:at:). The area where I am fitted (#fitArea) is the window without the strip of the legend, at its left, and the strip of the toolbar, at its top, so that the content is clear of both.
"
Class {
	#name : 'TLBlocVisualization',
	#superclass : 'BlElement',
	#instVars : [
		'panOffset',
		'panHandler',
		'zoomFactor',
		'zoomHandler',
		'toolbar',
		'fitPending',
		'dragHandler',
		'nodesMovedAction',
		'legend',
		'autoFit',
		'fittedRectangle',
		'fittedArea'
	],
	#category : 'Telescope-Bloc-Core',
	#package : 'Telescope-Bloc',
	#tag : 'Core'
}

{ #category : 'zoom' }
TLBlocVisualization class >> maximumZoom [

	^ 10
]

{ #category : 'zoom' }
TLBlocVisualization class >> minimumZoom [

	^ 0.1
]

{ #category : 'layout' }
TLBlocVisualization >> applyZoom [

	self transformDo: [ :builder |
			builder
				topLeftOrigin;
				scaleBy: zoomFactor @ zoomFactor ]
]

{ #category : 'layout' }
TLBlocVisualization >> basePosition [
	"Where the visualization sits so that the top left corner of its nodes and labels is at the margin of the window, before the panning. The zoom scales the corner"

	^ self windowMargin @ self windowMargin - (self contentTopLeft * zoomFactor)
]

{ #category : 'fitting' }
TLBlocVisualization >> contentRectangle [
	"The smallest rectangle which contains the nodes and their labels, relative to the visualization, whatever the depth of the groups they are in"

	| rectangles |
	rectangles := self children flatCollect: [ :child | child rectanglesRelativeTo: 0 @ 0 ].
	^ rectangles ifEmpty: [ 0 @ 0 corner: 0 @ 0 ] ifNotEmpty: [ Rectangle merging: rectangles ]
]

{ #category : 'fitting' }
TLBlocVisualization >> contentTopLeft [
	"Answers the smallest top left corner of the nodes and their labels, relative to the visualization, whatever the depth of the groups they are in"

	^ self contentRectangle origin
]

{ #category : 'dragging' }
TLBlocVisualization >> dropTargetOf: aNodeElement at: aPoint [
	"The node under the point of the window, where the user dropped the node, or nil. The nodes which contain the dropped one, such as its composite, and the ones it contains are not a target: moving a node inside its composite is not dropping it on it"

	| found |
	found := nil.
	self
		nodeElementsOf: self
		do: [ :candidate | ((candidate boundsInSpace asRectangle containsPoint: aPoint) and: [ (self element: candidate isRelatedTo: aNodeElement) not ]) ifTrue: [ found := candidate ] ].
	^ found
]

{ #category : 'dragging' }
TLBlocVisualization >> element: anElement isInside: anAncestor [

	| current |
	current := anElement parent.
	[ current isNotNil ] whileTrue: [
			current == anAncestor ifTrue: [ ^ true ].
			current := current parent ].
	^ false
]

{ #category : 'dragging' }
TLBlocVisualization >> element: anElement isRelatedTo: anotherElement [
	"Whether they are the same, or one is inside of the other"

	^ anElement == anotherElement or: [ (self element: anElement isInside: anotherElement) or: [ self element: anotherElement isInside: anElement ] ]
]

{ #category : 'export' }
TLBlocVisualization >> exportAsPngTo: aFileReference [
	"Writes the visualization as an image, as it is shown: with its zoom and its panning"

	^ BAExporter png
		  target: aFileReference;
		  element: self;
		  export
]

{ #category : 'export' }
TLBlocVisualization >> exportAsSvgTo: aFileReference [
	"Writes the visualization as a vector image, as it is shown: with its zoom and its panning"

	^ BAExporter svg
		  target: aFileReference;
		  element: self;
		  export
]

{ #category : 'fitting' }
TLBlocVisualization >> fitArea [
	"The area of the window where the visualization is fitted: the window without the strip of the legend, at its left, and the strip of the toolbar, at its top. They are measured once they are in the window"

	^ self legendReservedWidth @ self toolbarReservedHeight corner: self space extent
]

{ #category : 'layout' }
TLBlocVisualization >> fitContentToWindow [
	"Moves the visualization so that the top left corner of the nodes and of their labels sits at the margin of the window, shifted by the panning"

	self position: self basePosition + panOffset
]

{ #category : 'fitting' }
TLBlocVisualization >> fitIfPendingOtherwiseKeepContentInWindow [
	"The first layout with some content fits the visualization into the window. As long as the user did not pan, zoom or drag, it is fitted again when its content changes, or when the area it is fitted in changes because the toolbar or the legend were measured: the labels of new nodes are placed after the layout which measures them, so the content is only known after a few layouts. Otherwise the content stays where the panning and the zoom put it"

	(fitPending and: [ self children isNotEmpty ]) ifTrue: [
			fitPending := false.
			^ self fitIntoWindow ].
	(autoFit and: [ self contentRectangle ~= fittedRectangle or: [ self fitArea ~= fittedArea ] ]) ifTrue: [ ^ self fitIntoWindow ].
	self fitContentToWindow
]

{ #category : 'fitting' }
TLBlocVisualization >> fitIntoWindow [
	"Scales the visualization so that all its nodes and labels fill the area of the window which is free, as much as the zoom allows, and centers it there. The legend is at the left of the window and the toolbar at the top: the visualization fills what is left. The panning is forgotten, and the visualization is fitted again when its content changes, until the user pans, zooms or drags"

	| rectangle area ratios |
	self space ifNil: [ ^ self ].
	rectangle := self contentRectangle.
	rectangle extent isZero ifTrue: [ ^ self ].
	area := self fitArea.
	ratios := area extent - (self windowMargin * 2) / (rectangle extent max: 1 @ 1).
	zoomFactor := ((ratios x min: ratios y) min: self class maximumZoom) max: self class minimumZoom.
	self applyZoom.
	panOffset := area origin + (area extent - (rectangle extent * zoomFactor) / 2) - self windowMargin.
	autoFit := true.
	fittedRectangle := rectangle.
	fittedArea := area.
	self fitContentToWindow
]

{ #category : 'fitting' }
TLBlocVisualization >> fitOnNextLayout [
	"The next time I am laid out, once the nodes and their labels are measured, I am fitted into the window"

	fitPending := true
]

{ #category : 'initialization' }
TLBlocVisualization >> initialize [
	"The window already clips the visualization, so nodes and labels placed outside the default extent must still be drawn. The visualization is fitted into the window the first time it is laid out"

	super initialize.
	self clipChildren: false.
	panOffset := 0 @ 0.
	zoomFactor := 1.
	fitPending := true.
	autoFit := false.
	nodesMovedAction := [ ].
	panHandler := TLBlocPanHandler on: self.
	zoomHandler := TLBlocZoomHandler on: self.
	dragHandler := TLBlocNodeDragHandler on: self.
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self fitIfPendingOtherwiseKeepContentInWindow ].
	self addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self installNavigationHandlers ].
	self addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | self uninstallNavigationHandlers ]
]

{ #category : 'legend' }
TLBlocVisualization >> installLegend [
	"Adds the legend to the window when I am in one, unless it has no entry"

	(legend isNil or: [ self space isNil or: [ legend hasParent or: [ legend entries isEmpty ] ] ]) ifTrue: [ ^ self ].
	self space root addChild: legend
]

{ #category : 'initialization' }
TLBlocVisualization >> installNavigationHandlers [
	"The mouse events of the background and of the nodes arrive on the root of the window, which also holds the toolbar and the legend"

	{
		panHandler.
		zoomHandler.
		dragHandler } do: [ :handler | self space root addEventHandlerIfNotPresent: handler ].
	self toolbar hasParent ifFalse: [ self space root addChild: self toolbar ].
	self installLegend
]

{ #category : 'dragging' }
TLBlocVisualization >> keepPositionWhile: aBlock [
	"The visualization stays where it is while the block moves nodes. It is anchored to the top left corner of its content, which a node dragged to the left or to the top moves: the panning compensates, so the other nodes do not move under the mouse. The user took over: the visualization is not fitted again by itself"

	| keptPosition |
	autoFit := false.
	keptPosition := self measuredBounds position.
	aBlock value.
	panOffset := keptPosition - self basePosition.
	self fitContentToWindow
]

{ #category : 'legend' }
TLBlocVisualization >> legend: aLegendElement [
	"The legend is in the window, not in me: the zoom and the panning do not move it. A legend without entries is not shown"

	legend ifNotNil: [ :previous | previous removeFromParent ].
	legend := aLegendElement.
	self installLegend
]

{ #category : 'fitting' }
TLBlocVisualization >> legendReservedWidth [
	"The width of the strip of the window which the legend takes at the left, when there is one: the legend is measured once it is in the window"

	(legend isNil or: [ legend hasParent not ]) ifTrue: [ ^ 0 ].
	^ legend extent x + (legend windowMargin * 2)
]

{ #category : 'dragging' }
TLBlocVisualization >> nodeElementsOf: anElement do: aBlock [
	"The node elements inside of the element, at any depth, each one before the nodes it contains: the last one under a point is the one drawn above the others"

	anElement children do: [ :child |
			child class = TLBlocNodeElement ifTrue: [ aBlock value: child ].
			self nodeElementsOf: child do: aBlock ]
]

{ #category : 'dragging' }
TLBlocVisualization >> nodesMoved [

	nodesMovedAction value
]

{ #category : 'dragging' }
TLBlocVisualization >> onNodesMovedDo: aBlock [
	"What happens when the user moved a node with the mouse: the connector joins the nodes again"

	nodesMovedAction := aBlock
]

{ #category : 'navigation' }
TLBlocVisualization >> panBy: aPoint [
	"Moves the visualization by the given distance, and keeps the distance for the next layouts. The user took over: the visualization is not fitted again by itself"

	autoFit := false.
	panOffset := panOffset + aPoint.
	self fitContentToWindow
]

{ #category : 'legend' }
TLBlocVisualization >> removeLegend [

	legend ifNotNil: [ :previous | previous removeFromParent ].
	legend := nil
]

{ #category : 'toolbar' }
TLBlocVisualization >> toolbar [
	"The buttons which act on me, in the window"

	^ toolbar ifNil: [ toolbar := TLBlocToolbar for: self ]
]

{ #category : 'fitting' }
TLBlocVisualization >> toolbarReservedHeight [
	"The height of the strip of the window which the toolbar takes at the top, when it is in the window: the toolbar is measured once it is there"

	(toolbar isNil or: [ toolbar hasParent not ]) ifTrue: [ ^ 0 ].
	^ toolbar extent y + (toolbar windowMargin * 2)
]

{ #category : 'initialization' }
TLBlocVisualization >> uninstallNavigationHandlers [

	{
		panHandler.
		zoomHandler.
		dragHandler } do: [ :handler | handler uninstall ].
	toolbar ifNotNil: [ :element | element removeFromParent ].
	legend ifNotNil: [ :element | element removeFromParent ]
]

{ #category : 'layout' }
TLBlocVisualization >> windowMargin [
	"The space between the border of the window and the nodes"

	^ 10
]

{ #category : 'layout' }
TLBlocVisualization >> zoom [

	^ zoomFactor
]

{ #category : 'navigation' }
TLBlocVisualization >> zoomBy: aFactor around: aPoint [
	"Scales the visualization, within the limits of the zoom, and keeps the point under the given position of the window where it is. The user took over: the visualization is not fitted again by itself"

	| newZoom ratio currentPosition |
	autoFit := false.
	newZoom := (zoomFactor * aFactor min: self class maximumZoom) max: self class minimumZoom.
	ratio := newZoom / zoomFactor.
	currentPosition := self basePosition + panOffset.
	zoomFactor := newZoom.
	panOffset := aPoint - (ratio * (aPoint - currentPosition)) - self basePosition.
	self applyZoom.
	self fitContentToWindow
]

{ #category : 'fitting' }
TLBlocVisualization >> zoomIn [
	"Zooms around the center of the window"

	self zoomBy: 1.25 around: self space extent / 2
]

{ #category : 'fitting' }
TLBlocVisualization >> zoomOut [
	"Zooms around the center of the window"

	self zoomBy: 1 / 1.25 around: self space extent / 2
]
