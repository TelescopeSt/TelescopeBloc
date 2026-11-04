Class {
	#name : 'TLBlocVisualization',
	#superclass : 'BlElement',
	#category : 'Telescope-Bloc',
	#package : 'Telescope-Bloc'
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
	"Moves the visualization so that the top left corner of the nodes and of their labels sits at the margin of the window"

	| margin |
	margin := 10.
	self position: margin @ margin - self contentTopLeft
]

{ #category : 'initialization' }
TLBlocVisualization >> initialize [
	"The window already clips the visualization, so nodes and labels placed outside the default extent must still be drawn"

	super initialize.
	self clipChildren: false.
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self fitContentToWindow ]
]
