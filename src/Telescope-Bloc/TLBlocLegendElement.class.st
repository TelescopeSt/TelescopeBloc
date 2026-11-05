"
I am the legend of a Telescope visualization of Bloc: a translucent box with the entries one above the other. The visualization puts me in the window, not in itself, at its bottom left corner, so that the zoom and the panning do not move me, and it fits its content in what is at my right. I am not shown when I have no entry. When the legend is made again, for example by a mouse over, the element stays where it is and gets the new entries (#takeEntriesOf:): a new element would be at the top of the window until it is laid out.
"
Class {
	#name : 'TLBlocLegendElement',
	#superclass : 'BlElement',
	#instVars : [
		'window',
		'resizeHandler'
	],
	#category : 'Telescope-Bloc-Legend',
	#package : 'Telescope-Bloc',
	#tag : 'Legend'
}

{ #category : 'accessing' }
TLBlocLegendElement >> entries [
	"The entries of the legend, from top to bottom"

	^ self children asArray
]

{ #category : 'accessing' }
TLBlocLegendElement >> entries: someEntryElements [

	someEntryElements do: [ :entry | self addChild: entry ]
]

{ #category : 'initialization' }
TLBlocLegendElement >> initialize [
	"A translucent box with the entries one above the other, at the bottom left corner of the window. It is placed again when the window is resized"

	super initialize.
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets
				 top: 8
				 left: 12
				 bottom: 8
				 right: 12);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		background: (Color white alpha: 0.9);
		border: (BlBorder paint: Color lightGray width: 1);
		addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self placeInWindow ];
		addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self installInWindow ];
		addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | self uninstallFromWindow ]
]

{ #category : 'layout' }
TLBlocLegendElement >> installInWindow [
	"The legend is placed again when the window is resized, and the window is laid out again"

	window := self parent.
	resizeHandler := window addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self placeInWindow ]
]

{ #category : 'layout' }
TLBlocLegendElement >> placeInWindow [
	"The legend stays at the bottom left corner of the window, whatever its size. The window is the parent: a window is a basic layout, which does not place its children"

	| position |
	self parent ifNil: [ ^ self ].
	position := self windowMargin @ (self parent extent y - self extent y - self windowMargin).
	self measuredBounds position = position ifFalse: [ self position: position ]
]

{ #category : 'accessing' }
TLBlocLegendElement >> rows [
	"The rows of all the entries, from top to bottom"

	^ self entries flatCollect: #rows
]

{ #category : 'accessing' }
TLBlocLegendElement >> takeEntriesOf: anotherLegend [
	"The entries of the other legend replace mine: I stay where I am, where a new element would be at the top of the window until it is laid out"

	| newEntries |
	newEntries := anotherLegend entries.
	anotherLegend removeChildren.
	self removeChildren.
	self entries: newEntries
]

{ #category : 'layout' }
TLBlocLegendElement >> uninstallFromWindow [

	(window isNotNil and: [ resizeHandler isNotNil ]) ifTrue: [ window removeEventHandler: resizeHandler ].
	window := nil.
	resizeHandler := nil
]

{ #category : 'accessing' }
TLBlocLegendElement >> windowMargin [
	"The space between the legend and the border of the window"

	^ 10
]
