"
I am the Bloc element that holds the elements of a Telescope visualization: the nodes with their labels. I move myself so that the content starts at the margin of the window, shifted by the panning, and I scale myself with the zoom. The pan and zoom handlers are installed on the root of the window while I am in it. I do not clip my children, because the window already clips me.
"
Class {
	#name : 'TLBlocVisualization',
	#superclass : 'BlElement',
	#instVars : [
		'panOffset',
		'panHandler',
		'zoomFactor',
		'zoomHandler'
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

{ #category : 'layout' }
TLBlocVisualization >> contentTopLeft [
	"Answers the smallest top left corner of the nodes and their labels, relative to the visualization, whatever the depth of the groups they are in"

	| corners |
	corners := self children flatCollect: [ :child | child cornersRelativeTo: 0 @ 0 ].
	^ corners ifEmpty: [ 0 @ 0 ] ifNotEmpty: [ (corners collect: [ :corner | corner x ]) min @ (corners collect: [ :corner | corner y ]) min ]
]

{ #category : 'layout' }
TLBlocVisualization >> fitContentToWindow [
	"Moves the visualization so that the top left corner of the nodes and of their labels sits at the margin of the window, shifted by the panning"

	self position: self basePosition + panOffset
]

{ #category : 'initialization' }
TLBlocVisualization >> initialize [
	"The window already clips the visualization, so nodes and labels placed outside the default extent must still be drawn"

	super initialize.
	self clipChildren: false.
	panOffset := 0 @ 0.
	zoomFactor := 1.
	panHandler := TLBlocPanHandler on: self.
	zoomHandler := TLBlocZoomHandler on: self.
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self fitContentToWindow ].
	self addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self installNavigationHandlers ].
	self addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | self uninstallNavigationHandlers ]
]

{ #category : 'initialization' }
TLBlocVisualization >> installNavigationHandlers [
	"The mouse events of the background arrive on the root of the window"

	{
		panHandler.
		zoomHandler } do: [ :handler | self space root addEventHandlerIfNotPresent: handler ]
]

{ #category : 'layout' }
TLBlocVisualization >> panBy: aPoint [
	"Moves the visualization by the given distance, and keeps the distance for the next layouts"

	panOffset := panOffset + aPoint.
	self fitContentToWindow
]

{ #category : 'initialization' }
TLBlocVisualization >> uninstallNavigationHandlers [

	{
		panHandler.
		zoomHandler } do: [ :handler | handler uninstall ]
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
