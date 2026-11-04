Class {
	#name : 'TLBlocVisualization',
	#superclass : 'BlElement',
	#instVars : [
		'panOffset',
		'panHandler'
	],
	#category : 'Telescope-Bloc-Core',
	#package : 'Telescope-Bloc',
	#tag : 'Core'
}

{ #category : 'layout' }
TLBlocVisualization >> contentTopLeft [
	"Answers the smallest top left corner of the nodes and their labels, relative to the visualization"

	| corners |
	corners := self children flatCollect: [ :node | { node position } , (node children collect: [ :label | node position + label position ]) ].
	^ corners ifEmpty: [ 0 @ 0 ] ifNotEmpty: [ (corners collect: [ :corner | corner x ]) min @ (corners collect: [ :corner | corner y ]) min ]
]

{ #category : 'layout' }
TLBlocVisualization >> fitContentToWindow [
	"Moves the visualization so that the top left corner of the nodes and of their labels sits at the margin of the window, shifted by the panning"

	| margin |
	margin := 10.
	self position: margin @ margin - self contentTopLeft + panOffset
]

{ #category : 'initialization' }
TLBlocVisualization >> initialize [
	"The window already clips the visualization, so nodes and labels placed outside the default extent must still be drawn"

	super initialize.
	self clipChildren: false.
	panOffset := 0 @ 0.
	panHandler := TLBlocPanHandler on: self.
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self fitContentToWindow ].
	self addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self space root addEventHandlerIfNotPresent: panHandler ].
	self addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | panHandler uninstall ]
]

{ #category : 'layout' }
TLBlocVisualization >> panBy: aPoint [
	"Moves the visualization by the given distance, and keeps the distance for the next layouts"

	panOffset := panOffset + aPoint.
	self fitContentToWindow
]
