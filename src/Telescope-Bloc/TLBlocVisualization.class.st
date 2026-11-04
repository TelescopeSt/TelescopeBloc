"
I am the Bloc element that holds the elements of a Telescope visualization: the nodes with their labels. I move myself so that the content starts at the margin of the window, shifted by the panning, and I scale myself with the zoom. The pan and zoom handlers are installed on the root of the window while I am in it. The first time I am laid out with some content I am fitted into the window: scaled so that the content fills the window, down or up as far as the zoom allows, and centered, which #fitIntoWindow does again on request. #zoomIn and #zoomOut zoom around the center of the window, and #exportAsPngTo: and #exportAsSvgTo: write me as I am shown. I put my toolbar in the root of the window while I am in it. I do not clip my children, because the window already clips me. I let the user drag the nodes, and the panning compensates the nodes which move my content, so that the other nodes stay under the mouse. The connector is told when a node moved, to join the nodes again. I keep the legend, and I fit my content in what is at its right.
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
		'legend'
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

{ #category : 'layout' }
TLBlocVisualization >> fitContentToWindow [
	"Moves the visualization so that the top left corner of the nodes and of their labels sits at the margin of the window, shifted by the panning"

	self position: self basePosition + panOffset
]

{ #category : 'fitting' }
TLBlocVisualization >> fitIfPendingOtherwiseKeepContentInWindow [
	"The first layout with some content fits the visualization into the window. The next ones only keep the content where the panning and the zoom put it"

	(fitPending and: [ self children isNotEmpty ])
		ifTrue: [
				fitPending := false.
				self fitIntoWindow ]
		ifFalse: [ self fitContentToWindow ]
]

{ #category : 'fitting' }
TLBlocVisualization >> fitIntoWindow [
	"Scales the visualization so that all its nodes and labels fill the window, as much as the zoom allows, and centers it. The legend is at the left of the window: the visualization fills what is at its right. The panning is forgotten"

	| rectangle available ratios reserved |
	self space ifNil: [ ^ self ].
	rectangle := self contentRectangle.
	rectangle extent isZero ifTrue: [ ^ self ].
	reserved := self legendReservedWidth.
	available := self space extent x - reserved @ self space extent y.
	ratios := available - (self windowMargin * 2) / (rectangle extent max: 1 @ 1).
	zoomFactor := (ratios x min: ratios y) min: self class maximumZoom max: self class minimumZoom.
	self applyZoom.
	panOffset := reserved @ 0 + (available - (rectangle extent * zoomFactor) / 2) - self windowMargin.
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
	"The visualization stays where it is while the block moves nodes. It is anchored to the top left corner of its content, which a node dragged to the left or to the top moves: the panning compensates, so the other nodes do not move under the mouse"

	| keptPosition |
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
TLBlocVisualization >> nodesMoved [

	nodesMovedAction value
]

{ #category : 'dragging' }
TLBlocVisualization >> onNodesMovedDo: aBlock [
	"What happens when the user moved a node with the mouse: the connector joins the nodes again"

	nodesMovedAction := aBlock
]

{ #category : 'layout' }
TLBlocVisualization >> panBy: aPoint [
	"Moves the visualization by the given distance, and keeps the distance for the next layouts"

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

{ #category : 'layout' }
TLBlocVisualization >> zoomBy: aFactor around: aPoint [
	"Scales the visualization, within the limits of the zoom, and keeps the point under the given position of the window where it is"

	| newZoom ratio currentPosition |
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
