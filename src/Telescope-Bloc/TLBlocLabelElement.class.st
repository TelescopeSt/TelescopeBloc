"
I display the label of a Telescope node in a Bloc visualization, as a vertical stack of lines, because Bloc neither breaks a text at line feeds nor wraps it. Each line is a text element, centered in me. My placement is a TLPosition: I place myself so that my reversed position meets the anchor of the position on my node, with a gap. I wrap my lines to a maximum width by moving one word at a time to the next line, or I cut my text with three dots, measuring the lines after each layout. The size of my font is the label size of the style sheet of my node, because Telescope computes the width of a node from its label and its label size: I give it again to the text of a line each time the text changes. The position can be given by a block which answers a symbol such as #top.
"
Class {
	#name : 'TLBlocLabelElement',
	#superclass : 'BlElement',
	#instVars : [
		'placement',
		'wrapping',
		'maximumWidth',
		'fontSize'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocLabelElement class >> forNode: aNode [

	^ self new
		  configureForNode: aNode;
		  yourself
]

{ #category : 'initialization' }
TLBlocLabelElement >> addLines: aString [
	"One text element per line, because Bloc does not break a text at line feeds"

	aString lines do: [ :line | self addChild: (self lineElementWith: line) ]
]

{ #category : 'initialization' }
TLBlocLabelElement >> configureForNode: aNode [
	"The size of the font is the label size of the style sheet, which Telescope uses to compute the width of a node from its label. The position of the label can be given by a block, which may answer a symbol such as #top"

	| styleSheet labelValue |
	styleSheet := aNode effectiveStyleSheet.
	labelValue := (styleSheet obtainValue: #nodeLabel forEntity: aNode entity inNode: aNode) asString.
	fontSize := styleSheet obtainValue: #labelSize forEntity: aNode entity inNode: aNode.
	placement := TLPosition for: (styleSheet obtainValue: #nodeLabelPosition forEntity: aNode entity inNode: aNode).
	wrapping := (styleSheet attributes includesKey: #nodeLabelWrap) ifTrue: [ styleSheet obtainValue: #nodeLabelWrap forEntity: aNode entity inNode: aNode ].
	(#( 'wrap' 'ellipsis' ) includes: wrapping) ifTrue: [ maximumWidth := styleSheet obtainValue: #nodeLabelMaxWidth forEntity: aNode entity inNode: aNode ].
	self layout: BlLinearLayout vertical.
	self constraintsDo: [ :labelConstraints |
			labelConstraints horizontal fitContent.
			labelConstraints vertical fitContent ].
	self addLines: (wrapping = 'ellipsis'
			 ifTrue: [ labelValue copyReplaceAll: (String with: Character lf) with: ' ' ]
			 ifFalse: [ labelValue ]).
	self addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self onLayoutComputed ]
]

{ #category : 'private' }
TLBlocLabelElement >> ellipsize [
	"Removes one visible character at a time from the line, until it fits, and marks the cut with three dots"

	| line currentText visibleText |
	self children isEmpty ifTrue: [ ^ self ].
	line := self children first.
	line extent x <= maximumWidth ifTrue: [ ^ self ].
	currentText := line text asString.
	visibleText := (currentText endsWith: '...')
		               ifTrue: [ currentText allButLast: 3 ]
		               ifFalse: [ currentText ].
	visibleText ifEmpty: [ ^ self ] ifNotEmpty: [ line text: (self ropedTextOf: visibleText allButLast , '...') ]
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

{ #category : 'wrapping' }
TLBlocLabelElement >> join: aCollection with: aSeparator [

	^ aCollection ifEmpty: [ '' ] ifNotEmpty: [ aCollection allButFirst inject: aCollection first into: [ :result :string | result , aSeparator , string ] ]
]

{ #category : 'wrapping' }
TLBlocLabelElement >> labelText [
	"The text of the label, its lines separated by line feeds"

	^ self join: (self children collect: [ :child | child text asString ] as: Array) with: (String with: Character lf)
]

{ #category : 'private' }
TLBlocLabelElement >> lineElementWith: aString [
	"A line of the label, centered in the label"

	| line |
	line := BlTextElement new text: (self ropedTextOf: aString).
	line constraintsDo: [ :lineConstraints | lineConstraints linear horizontal alignCenter ].
	^ line
]

{ #category : 'private' }
TLBlocLabelElement >> moveOneOverflowingWord [
	"Moves the last word of the first line that is too wide to the next line. Only one word moves per layout, so that the next layout measures the lines again"

	| overflowing index words |
	overflowing := self children
		               detect: [ :each | each extent x > maximumWidth and: [ each text asString substrings size > 1 ] ]
		               ifNone: [ ^ self ].
	index := self children indexOf: overflowing.
	words := overflowing text asString substrings.
	overflowing text: (self ropedTextOf: (self join: words allButLast with: ' ')).
	self children size > index
		ifTrue: [
				| nextLine |
				nextLine := self children at: index + 1.
				nextLine text: (self ropedTextOf: words last , ' ' , nextLine text asString) ]
		ifFalse: [ self addChild: (self lineElementWith: words last) at: index + 1 ]
]

{ #category : 'placement' }
TLBlocLabelElement >> offsetForNodeExtent: aNodeExtent [
	"The label is placed so that its reversed position meets the node anchor of the position, then pushed away from the node"

	| nodeAnchor labelAnchor |
	nodeAnchor := (self fractionFor: placement horizontal) @ (self fractionFor: placement vertical).
	labelAnchor := placement reversed.
	^ aNodeExtent * nodeAnchor - (self extent * ((self fractionFor: labelAnchor horizontal) @ (self fractionFor: labelAnchor vertical))) + self gapVector
]

{ #category : 'wrapping' }
TLBlocLabelElement >> onLayoutComputed [
	"Placement and wrapping depend on the measured lines, so they are recomputed after each layout"

	self placeOutsideNode.
	wrapping = 'wrap' ifTrue: [ self moveOneOverflowingWord ].
	wrapping = 'ellipsis' ifTrue: [ self ellipsize ]
]

{ #category : 'placement' }
TLBlocLabelElement >> placeOutsideNode [
	"Compares with the measured position, the one Bloc uses to avoid requesting the same layout again. Comparing the laid out bounds never matches, which makes an endless layout loop"

	| offset |
	offset := self offsetForNodeExtent: self parent extent.
	self measuredBounds position = offset ifFalse: [ self position: offset ]
]

{ #category : 'layout' }
TLBlocLabelElement >> rectanglesRelativeTo: anOrigin [
	"The rectangle of the label, from the given origin: it is outside of the node when the node has it at its top or its bottom"

	^ { (anOrigin + self position extent: self extent) }
]

{ #category : 'private' }
TLBlocLabelElement >> ropedTextOf: aString [
	"The text of a line, in the font size of the label: every time the text of a line changes, the size has to be given again"

	^ fontSize
		  ifNil: [ aString asRopedText ]
		  ifNotNil: [ aString asRopedText fontSize: fontSize ]
]
