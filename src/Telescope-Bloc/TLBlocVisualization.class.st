"
I am the Bloc element that holds the elements of a Telescope visualization: the nodes with their labels and the connections are in my #content, an element which is never transformed. I translate myself so that the content starts at the margin of the window, shifted by the panning, and I scale myself with the zoom. Both are my transformation, not my position: zooming and panning do not lay out my nodes and their labels again. While the user pans (#startPanning and #stopPanning), my content is in a composition layer: Bloc paints what it drew once at the new place instead of drawing all the nodes at each step, unless the content is too big in the window for the memory of the layer (#contentFitsInACompositionLayer), and the nodes are not looked for under the mouse, so that the mouse events go to the background. The pan, zoom, drag and hover handlers are installed on the root of the window while I am in it. The node under the mouse is outlined in the color of my theme (#hover:, with a TLBlocHoverOutlineEffect, which neither resizes it nor lays it out again). The first time I am laid out with some content I am fitted into the window: scaled so that the content fills the window, down or up as far as the zoom allows, and centered, which #fitIntoWindow does again on request. #zoomIn and #zoomOut zoom around the center of the window, and #exportAsPngTo: and #exportAsSvgTo: write me as I am shown. I put my toolbar in the root of the window while I am in it. I do not clip my children, because the window already clips me. I let the user drag the nodes, and the panning compensates the nodes which move my content, so that the other nodes stay under the mouse. The connector is told when a node moved, to join the nodes again. I keep the legend, and I fit my content in what is at its right. After a fit, I fit myself again when my content changes, until the user pans, zooms or drags, because the content is only known after a few layouts. It finds the node under the point where a node was dropped (#dropTargetOf:at:). The area where I am fitted (#fitArea) is the window without the strip of the legend, at its left, and the strip of the toolbar, at its top, so that the content is clear of both. While I am in a window, a grid of dots (TLBlocGridElement) is behind me in it, unless #gridVisible: turned it off: it follows my panning and my zoom.
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
		'fittedArea',
		'autoFitOnLayout',
		'zoomAnimation',
		'zoomTarget',
		'placedContentTopLeft',
		'content',
		'panning',
		'placedTransformation',
		'theme',
		'grid',
		'gridVisible',
		'hoveredNode',
		'hoverHandler'
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

{ #category : 'zoom' }
TLBlocVisualization class >> zoomDuration [
	"How long the zoom takes to reach its target"

	^ 150 milliSeconds
]

{ #category : 'fitting' }
TLBlocVisualization >> autoFitOnLayout [
	"Whether the visualization is fitted again into the window when its layout is applied again. The first fit and the fit button do not depend on it"

	^ autoFitOnLayout
]

{ #category : 'fitting' }
TLBlocVisualization >> autoFitOnLayout: aBoolean [

	autoFitOnLayout := aBoolean
]

{ #category : 'layout' }
TLBlocVisualization >> basePosition [
	"Where the visualization sits so that the top left corner of its nodes and labels is at the margin of the window, before the panning. The zoom scales the corner"

	^ self basePositionFor: self contentTopLeft
]

{ #category : 'layout' }
TLBlocVisualization >> basePositionFor: aContentTopLeft [
	"Where the visualization sits so that the given top left corner of its content is at the margin of the window, before the panning. The zoom scales the corner"

	^ self windowMargin @ self windowMargin - (aContentTopLeft * zoomFactor)
]

{ #category : 'accessing' }
TLBlocVisualization >> content [
	"The element which holds the nodes and the connections. It is never transformed: my transformation pans and zooms it, and the coordinates of the nodes and of the connections are the ones of the content"

	^ content
]

{ #category : 'navigation' }
TLBlocVisualization >> contentFitsInACompositionLayer [
	"Whether the content in the window is at most twice as big as the window on each side, so that a layer of it does not take too much memory"

	| limit extent |
	self space ifNil: [ ^ false ].
	limit := self space extent * 2.
	extent := content invalidationBoundsInSpace extent.
	^ extent x <= limit x and: [ extent y <= limit y ]
]

{ #category : 'fitting' }
TLBlocVisualization >> contentRectangle [
	"The smallest rectangle which contains the nodes and their labels, relative to the visualization, whatever the depth of the groups they are in"

	| rectangles |
	rectangles := content children flatCollect: [ :child | child rectanglesRelativeTo: 0 @ 0 ].
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

{ #category : 'event handling' }
TLBlocVisualization >> findMouseEventTargetAt: aPoint [
	"The element under the point of the window which the mouse events are for, as Bloc finds it, but in my coordinates. Bloc compares the point with the bounds of each element in the window, which a pan or a zoom changes: it computes them again for all the nodes at the next move of the mouse, which takes milliseconds with thousands of nodes. The point is converted once into my coordinates, then into the ones of each child, whose bounds a pan or a zoom does not change.
	While the user pans, the mouse events are for the background, and the nodes are not looked for under the mouse at all. While the user drags a node, they are for that node, which follows the mouse: the nodes it passes over are not entered and left, which would run their mouse over interactions at each move"

	panning ifTrue: [ ^ nil ].
	dragHandler draggedNode ifNotNil: [ :draggedNode | ^ draggedNode ].
	^ self mouseEventTargetIn: self at: (self globalPointToLocal: aPoint)
]

{ #category : 'fitting' }
TLBlocVisualization >> fitArea [
	"The area of the window where the visualization is fitted: the window without the strip of the legend, at its left, and the strip of the toolbar, at its top. They are measured once they are in the window"

	^ self legendReservedWidth @ self toolbarReservedHeight corner: self space extent
]

{ #category : 'layout' }
TLBlocVisualization >> fitContentToWindow [
	"Moves the content so that its top left corner sits at the margin of the window, shifted by the panning"

	self placeContentWithTopLeft: self contentTopLeft
]

{ #category : 'fitting' }
TLBlocVisualization >> fitIfPendingOtherwiseKeepContentInWindow [
	"The first layout with some content fits the visualization into the window. As long as the user did not pan, zoom or drag, and the auto fit is on, it is fitted again when its content changes, or when the area it is fitted in changes because the toolbar or the legend were measured: the labels of new nodes are placed after the layout which measures them, so the content is only known after a few layouts. Otherwise the content stays where the panning and the zoom put it"

	(fitPending and: [ content hasChildren ]) ifTrue: [
			fitPending := false.
			^ self fitIntoWindow ].
	(autoFitOnLayout and: [ autoFit and: [ self contentRectangle ~= fittedRectangle or: [ self fitArea ~= fittedArea ] ] ]) ifTrue: [ ^ self fitIntoWindow ].
	self fitContentToWindow
]

{ #category : 'layout' }
TLBlocVisualization >> fitIntoWindow [
	"Scales the visualization so that all its nodes and labels fill the area of the window which is free, as much as the zoom allows, and centers it there. The legend is at the left of the window and the toolbar at the top: the visualization fills what is left. The panning is forgotten, and the visualization is fitted again when its content changes, until the user pans, zooms or drags"

	| rectangle area ratios |
	self space ifNil: [ ^ self ].
	rectangle := self contentRectangle.
	rectangle extent isZero ifTrue: [ ^ self ].
	area := self fitArea.
	ratios := area extent - (self windowMargin * 2) / (rectangle extent max: 1 @ 1).
	zoomFactor := ((ratios x min: ratios y) min: self class maximumZoom) max: self class minimumZoom.
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

{ #category : 'fitting' }
TLBlocVisualization >> fitOnNextLayoutIfAutoFit [
	"The next time I am laid out, once the nodes and their labels are measured, I am fitted into the window, unless the auto fit is off"

	autoFitOnLayout ifTrue: [ self fitOnNextLayout ]
]

{ #category : 'accessing' }
TLBlocVisualization >> gridVisible [

	^ gridVisible ifNil: [ true ]
]

{ #category : 'accessing' }
TLBlocVisualization >> gridVisible: aBoolean [
	"Whether the window shows a grid of dots behind me, which follows my panning and my zoom (see TLBlocGridElement). It does by default"

	gridVisible := aBoolean
]

{ #category : 'hovering' }
TLBlocVisualization >> hover: aNodeElement [
	"The node under the mouse is outlined in the color of my theme, and nil removes the outline. Only the nodes whose outline changes are drawn again: an effect changes neither their size nor the layout"

	hoveredNode == aNodeElement ifTrue: [ ^ self ].
	hoveredNode ifNotNil: [ :previous | previous effect: BlNullEffect new ].
	hoveredNode := aNodeElement.
	aNodeElement ifNotNil: [ aNodeElement effect: (TLBlocHoverOutlineEffect color: self theme hoverOutlineColor width: self hoverOutlineWidth) ]
]

{ #category : 'hovering' }
TLBlocVisualization >> hoverOutlineWidth [

	^ 2
]

{ #category : 'accessing' }
TLBlocVisualization >> hoveredNode [
	"The node under the mouse, which is outlined, if any"

	^ hoveredNode
]

{ #category : 'initialization' }
TLBlocVisualization >> initialize [
	"The window already clips the visualization, so nodes and labels placed outside the default extent must still be drawn. The nodes and the connections are in my content, which is never transformed: my transformation pans and zooms it. Neither I nor my content take the mouse: a press on the background must reach the root of the space, which pans. My children still take it. The visualization is fitted into the window the first time it is laid out, and again when a layout is applied again unless the auto fit is turned off."

	super initialize.
	content := BlElement new
		           preventMouseEvents;
		           clipChildren: false;
		           yourself.
	self addChild: content.
	self
		clipChildren: false;
		preventMouseEvents.
	panOffset := 0 @ 0.
	zoomFactor := 1.
	fitPending := true.
	autoFit := false.
	autoFitOnLayout := true.
	panning := false.
	nodesMovedAction := [ ].
	panHandler := TLBlocPanHandler on: self.
	zoomHandler := TLBlocZoomHandler on: self.
	dragHandler := TLBlocNodeDragHandler on: self.
	hoverHandler := TLBlocHoverHandler on: self.
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self fitIfPendingOtherwiseKeepContentInWindow ].
	self addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self installNavigationHandlers ].
	self addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | self uninstallNavigationHandlers ]
]

{ #category : 'navigation' }
TLBlocVisualization >> installGrid [
	"The grid is behind everything in the window"

	(self gridVisible and: [ grid isNil or: [ grid hasParent not ] ]) ifFalse: [ ^ self ].
	grid := TLBlocGridElement for: self.
	self space root addChild: grid at: 1
]

{ #category : 'legend' }
TLBlocVisualization >> installLegend [
	"Adds the legend to the window when I am in one, unless it has no entry"

	(legend isNil or: [ self space isNil or: [ legend hasParent or: [ legend entries isEmpty ] ] ]) ifTrue: [ ^ self ].
	self space root addChild: legend
]

{ #category : 'initialization' }
TLBlocVisualization >> installNavigationHandlers [
	"The mouse events of the background and of the nodes arrive on the root of the window, which also holds the toolbar, the legend and the grid"

	{
		panHandler.
		zoomHandler.
		dragHandler.
		hoverHandler } do: [ :handler | self space root addEventHandlerIfNotPresent: handler ].
	self toolbar hasParent ifFalse: [ self space root addChild: self toolbar ].
	self installLegend.
	self installGrid
]

{ #category : 'zoom' }
TLBlocVisualization >> isZooming [
	"The zoom is moving to its target"

	^ zoomAnimation isNotNil
]

{ #category : 'dragging' }
TLBlocVisualization >> itemOfContentHolding: anElement [
	"The child of my content which is or holds the element: a node, or the element of a group or of a composite node"

	| item |
	item := anElement.
	[ item parent == content ] whileFalse: [ item := item parent ].
	^ item
]

{ #category : 'dragging' }
TLBlocVisualization >> keepPositionWhile: aBlock [
	"The visualization stays where it is while the block moves nodes. It is anchored to the top left corner of its content, which a node dragged to the left or to the top moves: the panning compensates, so the other nodes do not move under the mouse. The user took over: the visualization is not fitted again by itself. The corner before the move is the one of the last placement, and the one after it is computed once"

	| keptPosition topLeft |
	autoFit := false.
	keptPosition := (self basePositionFor: self placedContentTopLeft) + panOffset.
	aBlock value.
	topLeft := self contentTopLeft.
	panOffset := keptPosition - (self basePositionFor: topLeft).
	self placeContentWithTopLeft: topLeft
]

{ #category : 'dragging' }
TLBlocVisualization >> keepPositionWhileMoving: aNodeElement with: aBlock [
	"As #keepPositionWhile:, for a block which only moves the node and the composite nodes around it, as a drag does at each move of the mouse. The top left corner of the content after the move is found from the one of the last placement and from the item of my content which holds the node: it only changes when that item goes beyond it. All the nodes are gone through, which takes milliseconds with thousands of them, only when that item was on the corner"

	| cornerBefore keptPosition item itemCornerBefore itemCornerAfter topLeft |
	autoFit := false.
	cornerBefore := self placedContentTopLeft.
	keptPosition := (self basePositionFor: cornerBefore) + panOffset.
	item := self itemOfContentHolding: aNodeElement.
	itemCornerBefore := self topLeftOfItem: item.
	aBlock value.
	itemCornerAfter := self topLeftOfItem: item.
	topLeft := (itemCornerBefore x > cornerBefore x and: [ itemCornerBefore y > cornerBefore y ])
		           ifTrue: [ cornerBefore min: itemCornerAfter ]
		           ifFalse: [ self contentTopLeft ].
	panOffset := keptPosition - (self basePositionFor: topLeft).
	self placeContentWithTopLeft: topLeft
]

{ #category : 'legend' }
TLBlocVisualization >> legend: aLegendElement [
	"The legend is in the window, not in me: the zoom and the panning do not move it. A legend without entries is not shown. When there is already a legend in the window it is kept and gets the new entries: a new element would be at the top of the window until it is laid out, and the legend would jump there each time it is made again, for example by a mouse over"

	(legend isNotNil and: [ legend hasParent and: [ aLegendElement entries isNotEmpty ] ]) ifTrue: [ ^ legend takeEntriesOf: aLegendElement ].
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

{ #category : 'event handling' }
TLBlocVisualization >> mouseEventTargetIn: anElement at: aLocalPoint [
	"The deepest element among the element and its children which the mouse events at the point, in the coordinates of the element, are for, or nil. The same rules as BlElement>>#findMouseEventTargetAt:: the children above the others first, the children only when they handle the mouse events, and only inside of the element when it clips them. A child without transformation only moves the point by its position"

	| wantsEvent pointForChildren |
	anElement isVisible ifFalse: [ ^ nil ].
	wantsEvent := anElement containsPoint: aLocalPoint.
	(anElement shouldChildrenHandleMouseEvents not or: [ anElement hasChildren not ]) ifTrue: [
			^ (wantsEvent and: [ anElement shouldHandleMouseEvents ])
				  ifTrue: [ anElement ]
				  ifFalse: [ nil ] ].
	(anElement clipChildren and: [ wantsEvent not ]) ifTrue: [ ^ nil ].
	pointForChildren := anElement localPointToChildren: aLocalPoint.
	anElement children sortedByElevation reverseDo: [ :child |
			| pointInChild |
			pointInChild := child transformation isIdentity
				                ifTrue: [ pointForChildren - child position ]
				                ifFalse: [ child parentPointToLocal: aLocalPoint ].
			(self mouseEventTargetIn: child at: pointInChild) ifNotNil: [ :target | ^ target ] ].
	^ (wantsEvent and: [ anElement shouldHandleMouseEvents ])
		  ifTrue: [ anElement ]
		  ifFalse: [ nil ]
]

{ #category : 'hovering' }
TLBlocVisualization >> nodeElementHolding: anElement [
	"The innermost node which is or contains the element, if any: the element under the mouse may be the label of a node"

	| current |
	current := anElement.
	[ current isNil or: [ current == self or: [ current class = TLBlocNodeElement ] ] ] whileFalse: [ current := current parent ].
	^ current == self ifFalse: [ current ]
]

{ #category : 'dragging' }
TLBlocVisualization >> nodeElementsOf: anElement do: aBlock [
	"The node elements inside of the element, at any depth, each one before the nodes it contains: the last one under a point is the one drawn above the others"

	anElement children do: [ :child |
			child class = TLBlocNodeElement ifTrue: [ aBlock value: child ].
			self nodeElementsOf: child do: aBlock ]
]

{ #category : 'dragging' }
TLBlocVisualization >> nodesMoved: aNodeElement [
	"The user moved the node with the mouse: the connections of the node, and of its children which move with it, follow"

	nodesMovedAction cull: aNodeElement
]

{ #category : 'dragging' }
TLBlocVisualization >> onNodesMovedDo: aBlock [
	"What happens when the user moved a node with the mouse: the block is given the element of the node, and the connector joins its connections again"

	nodesMovedAction := aBlock
]

{ #category : 'navigation' }
TLBlocVisualization >> panBy: aPoint [
	"Moves the visualization by the given distance, and keeps the distance for the next layouts. The user took over: the visualization is not fitted again by itself. The content does not change: the top left corner of the last placement is reused"

	autoFit := false.
	panOffset := panOffset + aPoint.
	self placeContentWithTopLeft: self placedContentTopLeft
]

{ #category : 'accessing' }
TLBlocVisualization >> panOffset [
	^ panOffset
]

{ #category : 'layout' }
TLBlocVisualization >> placeContentWithTopLeft: aContentTopLeft [
	"Translates and scales me so that the top left corner of my content, the one given, sits at the margin of the window, shifted by the panning. Only my transformation changes, not my position: my nodes and their labels are not laid out again, which makes the zoom and the panning fluid with many nodes. The content is scaled first, then translated. The corner is remembered: the zoom and the panning do not change the content, they reuse it.
	A drag places the content at each move of the mouse, mostly at the same place: the transformation is only changed when it differs, because changing it, even to the same one, makes Bloc draw all the nodes again. The grid follows the content: it is drawn again"

	| translation aTransformation |
	placedContentTopLeft := aContentTopLeft.
	translation := (self basePositionFor: aContentTopLeft) + panOffset.
	aTransformation := {
		                   zoomFactor.
		                   translation }.
	aTransformation = placedTransformation ifTrue: [ ^ self ].
	placedTransformation := aTransformation.
	self transformDo: [ :builder |
			builder
				topLeftOrigin;
				scaleBy: zoomFactor @ zoomFactor;
				translateBy: translation ].
	grid ifNotNil: [ :element | element invalidate ]
]

{ #category : 'layout' }
TLBlocVisualization >> placedContentTopLeft [
	"The top left corner of the content when I was last placed. The content only changes with a layout, which places me again, or with a drag, which computes it again: the zoom and the panning can reuse it instead of going through all the nodes"

	^ placedContentTopLeft ifNil: [ self contentTopLeft ]
]

{ #category : 'legend' }
TLBlocVisualization >> removeLegend [

	legend ifNotNil: [ :previous | previous removeFromParent ].
	legend := nil
]

{ #category : 'navigation' }
TLBlocVisualization >> startPanning [
	"The user started to drag the background. While the content only moves, Bloc can paint what it drew once instead of drawing all the nodes at each step: the content gets a composition layer, unless it is too big in the window, because the layer is as big as the content and zoomed in it would take too much memory. The nodes are not looked for under the mouse until the pan ends (see #findMouseEventTargetAt:)"

	panning := true.
	self contentFitsInACompositionLayer ifTrue: [ content beInSingleCompositionLayer ]
]

{ #category : 'navigation' }
TLBlocVisualization >> stopPanning [
	"The user released the background. Out of a pan, a change of the content, such as a highlight or a drag, would draw the whole layer again: the content is drawn without a layer, and its surface is released"

	panning := false.
	content beWithoutCompositionLayer.
	content detachCompositionLayer
]

{ #category : 'theme' }
TLBlocVisualization >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocVisualization >> theme: aTheme [
	"The theme of my toolbar and of the window I am in, given by the connector (see TLBlocConnector>>#theme:)"

	theme := aTheme
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

{ #category : 'dragging' }
TLBlocVisualization >> topLeftOfItem: anItemOfContent [
	"The top left corner of the item of my content, with its labels and its children, in the coordinates of my content"

	^ (Rectangle merging: (anItemOfContent rectanglesRelativeTo: 0 @ 0)) origin
]

{ #category : 'initialization' }
TLBlocVisualization >> uninstallNavigationHandlers [

	{
		panHandler.
		zoomHandler.
		dragHandler.
		hoverHandler } do: [ :handler | handler uninstall ].
	toolbar ifNotNil: [ :element | element removeFromParent ].
	legend ifNotNil: [ :element | element removeFromParent ].
	grid ifNotNil: [ :element | element removeFromParent ]
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
	"Scales the visualization, within the limits of the zoom, and keeps the point under the given position of the window where it is. The user took over: the visualization is not fitted again by itself. The content is the same whatever the zoom: the top left corner of the last placement is reused"

	| newZoom ratio topLeft currentPosition |
	autoFit := false.
	newZoom := (zoomFactor * aFactor min: self class maximumZoom) max: self class minimumZoom.
	ratio := newZoom / zoomFactor.
	topLeft := self placedContentTopLeft.
	currentPosition := (self basePositionFor: topLeft) + panOffset.
	zoomFactor := newZoom.
	panOffset := aPoint - (ratio * (aPoint - currentPosition)) - (self basePositionFor: topLeft).
	self placeContentWithTopLeft: topLeft
]

{ #category : 'accessing' }
TLBlocVisualization >> zoomFactor [
	^ zoomFactor
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

{ #category : 'zoom' }
TLBlocVisualization >> zoomSmoothlyBy: aFactor around: aPoint [
	"Brings the zoom to its target in a short animation instead of jumping. The target is the one of the animation in progress, if there is one, so that the events of a trackpad, which come faster than the animation, add up. The point under the given position of the window stays where it is. A new animation replaces the one in progress, which ignores its steps from then on and ends by itself"

	| start target animation |
	start := zoomFactor.
	target := ((zoomTarget ifNil: [ zoomFactor ]) * aFactor min: self class maximumZoom) max: self class minimumZoom.
	zoomTarget := target.
	animation := BlNumberTransition new.
	animation
		from: 0;
		to: 1;
		duration: self class zoomDuration;
		onStepDo: [ :progress |
			| newZoom |
			zoomAnimation == animation ifTrue: [
				newZoom := progress >= 1
					           ifTrue: [ target ]
					           ifFalse: [ start * ((target / start) raisedTo: progress) ].
				self zoomBy: newZoom / zoomFactor around: aPoint.
				progress >= 1 ifTrue: [
					zoomTarget := nil.
					zoomAnimation := nil ] ] ].
	zoomAnimation := animation.
	self addAnimation: animation
]
