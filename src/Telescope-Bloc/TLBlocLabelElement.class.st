"
I display the label of a Telescope node in a Bloc visualization. My placement is a TLPosition: I place myself so that my reversed position meets the anchor of the position on my node. I can wrap my text to a maximum width or cut it with three dots, measuring the text after each layout.
"
Class {
	#name : 'TLBlocLabelElement',
	#superclass : 'BlTextElement',
	#instVars : [
		'placement',
		'wrapping',
		'maximumWidth'
	],
	#category : 'Telescope-Bloc-Label',
	#package : 'Telescope-Bloc',
	#tag : 'Label'
}

{ #category : 'instance creation' }
TLBlocLabelElement class >> forNode: aNode [

	^ self new
		  configureForNode: aNode;
		  yourself
]

{ #category : 'initialization' }
TLBlocLabelElement >> configureForNode: aNode [

	| styleSheet |
	styleSheet := aNode effectiveStyleSheet.

	self text: (styleSheet obtainValue: #nodeLabel forEntity: aNode entity inNode: aNode) asString asRopedText.

	placement := styleSheet obtainValue: #nodeLabelPosition forEntity: aNode entity inNode: aNode.

	wrapping := (styleSheet attributes includesKey: #nodeLabelWrap) ifTrue: [ styleSheet obtainValue: #nodeLabelWrap forEntity: aNode entity inNode: aNode ].
	(#( 'wrap' 'ellipsis' ) includes: wrapping) ifTrue: [ maximumWidth := styleSheet obtainValue: #nodeLabelMaxWidth forEntity: aNode entity inNode: aNode ].
	wrapping = 'wrap' ifTrue: [ self constraintsDo: [ :someConstraints | someConstraints horizontal exact: maximumWidth ] ].

	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self onLayoutComputed ]
]

{ #category : 'wrapping' }
TLBlocLabelElement >> ellipsize [
	"Removes one visible character at a time, until the measured label fits, and marks the cut with three dots"

	| currentText visibleText |
	self extent x <= maximumWidth ifTrue: [ ^ self ].
	currentText := self text asString.
	visibleText := (currentText endsWith: '...')
		               ifTrue: [ currentText allButLast: 3 ]
		               ifFalse: [ currentText ].
	visibleText isEmpty ifTrue: [ ^ self ].
	self text: (visibleText allButLast , '...') asRopedText
]

{ #category : 'placement' }
TLBlocLabelElement >> fractionFor: aSymbol [
	"Answers where a left, center, right, top or bottom position lies along its axis, from 0 to 1"

	^ (#( left top ) includes: aSymbol)
		  ifTrue: [ 0 ]
		  ifFalse: [
				  aSymbol = #center
					  ifTrue: [ 0.5 ]
					  ifFalse: [ 1 ] ]
]

{ #category : 'placement' }
TLBlocLabelElement >> gapFromNode [
	"Gap in pixels between a label and its node. Not named padding, which BlElement already uses for its insets"

	^ 5.0
]

{ #category : 'placement' }
TLBlocLabelElement >> gapVector [
	"Answers the gap between the label and its node, in the direction the label is placed"

	placement vertical = #top ifTrue: [ ^ 0 @ self gapFromNode negated ].
	placement vertical = #bottom ifTrue: [ ^ 0 @ self gapFromNode ].
	placement horizontal = #left ifTrue: [ ^ self gapFromNode negated @ 0 ].
	placement horizontal = #right ifTrue: [ ^ self gapFromNode @ 0 ].
	^ 0 @ 0
]

{ #category : 'placement' }
TLBlocLabelElement >> offsetForNodeExtent: aNodeExtent [
	"The label is placed so that its reversed position meets the node anchor of the position, then pushed away from the node"

	| nodeAnchor labelAnchor |
	nodeAnchor := (self fractionFor: placement horizontal) @ (self fractionFor: placement vertical).
	labelAnchor := placement reversed.
	^ aNodeExtent * nodeAnchor - (self extent * ((self fractionFor: labelAnchor horizontal) @ (self fractionFor: labelAnchor vertical))) + self gapVector
]

{ #category : 'initialization' }
TLBlocLabelElement >> onLayoutComputed [
	"Placement depends on the measured label, so it is recomputed after each layout"

	self placeOutsideNode.
	wrapping = 'ellipsis' ifTrue: [ self ellipsize ]
]

{ #category : 'placement' }
TLBlocLabelElement >> placeOutsideNode [
	"Compares with the measured position, the one Bloc uses to avoid requesting the same layout again. Comparing the laid out bounds never matches, which makes an endless layout loop"

	| offset |
	offset := self offsetForNodeExtent: self parent extent.
	self measuredBounds position = offset ifFalse: [ self position: offset ]
]
