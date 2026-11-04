"
I am the Bloc element of a connection between two nodes of a Telescope visualization. I am a line from the border of the outline of the source node to the border of the outline of the target node, along the line which joins their centers (see TLBlocConnectionSegment). I am in the view, in the coordinates of which the segment is computed, and my element is the box of the segment. The connector updates me once the layouts have placed the nodes. The color and the width of the line are the ones of the style sheet of the connection. I draw a head at the end of the line, with the shape of the head substyle: a triangle by default, and the color of the line unless the head has its own. I show the label of the connection next to the middle of the line, above it or on its right when it is vertical, and not on it. Every curve style is drawn as a straight line. The arrows at the start and at the middle, the line styles and the interactions are not implemented yet.
"
Class {
	#name : 'TLBlocNodeConnection',
	#superclass : 'BlElement',
	#instVars : [
		'fromNode',
		'toNode',
		'segment',
		'headShape',
		'headColor',
		'head',
		'headOutline',
		'label'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocNodeConnection class >> from: aSourceElement to: aTargetElement [
	"The elements are the ones of two nodes, which are in the same view as the connection"

	^ self new
		  fromNode: aSourceElement toNode: aTargetElement;
		  yourself
]

{ #category : 'layout' }
TLBlocNodeConnection >> centerLabel [
	"The label is next to the middle of the line, not on it. Its extent is known once Bloc has laid it out, so this is also done when it is"

	| offset |
	(label isNil or: [ segment isNil ]) ifTrue: [ ^ self ].
	offset := (segment labelCenterFor: label extent gap: self labelGap) - self measuredBounds position - (label extent / 2).
	label measuredBounds position = offset ifFalse: [ label position: offset ]
]

{ #category : 'layout' }
TLBlocNodeConnection >> cornersRelativeTo: anOrigin [
	"A connection is between its nodes: it does not take part in the fit of the visualization in its window"

	^ #(  )
]

{ #category : 'initialization' }
TLBlocNodeConnection >> createLabelFrom: aStyleSheet [
	"A text next to the middle of the line, placed once it is measured"

	| size text |
	size := (aStyleSheet attributes includesKey: #connectionLabelSize)
		        ifTrue: [ aStyleSheet obtainValue: #connectionLabelSize forEntity: nil inNode: nil ]
		        ifFalse: [ 10 ].
	text := (aStyleSheet obtainValue: #connectionLabel forEntity: nil inNode: nil) asString asRopedText fontSize: size.
	label := BlTextElement new
		         text: text;
		         yourself.
	label addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self centerLabel ].
	self addChild: label
]

{ #category : 'initialization' }
TLBlocNodeConnection >> customizeFromConnection: aTLConnection [
	"The color and the width of the style sheet of the connection are the ones of the line. The head is the shape of the head substyle, a triangle when it has none, with the color of the line unless the head has its own. The label is a text at the middle of the line"

	| styleSheet headStyle |
	styleSheet := aTLConnection effectiveStyleSheet.
	self border: (BlBorder paint: styleSheet color width: styleSheet width).
	headStyle := styleSheet > #head.
	headShape := (headStyle attributes includesKey: #shape)
		             ifTrue: [ headStyle shape ]
		             ifFalse: [ TLTriangle ].
	headColor := (headStyle attributes includesKey: #color)
		             ifTrue: [ headStyle color ]
		             ifFalse: [ styleSheet color ].
	(styleSheet attributes includesKey: #connectionLabel) ifTrue: [ self createLabelFrom: styleSheet ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> end [
	"The point where the line arrives on the target node, in the coordinates of the view. Nil until the connection is updated"

	^ segment ifNotNil: [ :aSegment | aSegment end ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> fromNode [
	"The element of the source node"

	^ fromNode
]

{ #category : 'initialization' }
TLBlocNodeConnection >> fromNode: aSourceElement toNode: aTargetElement [

	fromNode := aSourceElement.
	toNode := aTargetElement
]

{ #category : 'accessing' }
TLBlocNodeConnection >> head [
	"The element of the head of the connection, or nil when the shape of the head draws nothing"

	^ head
]

{ #category : 'layout' }
TLBlocNodeConnection >> headElementFor: anOutline [
	"An element of the color of the head, with the geometry of the outline, which is in the coordinates of the view. The element is in my coordinates"

	| corners topLeft bottomRight element |
	corners := anOutline encompassingRectangle vertices collect: #asPoint as: Array.
	topLeft := (corners collect: #x) min @ (corners collect: #y) min.
	bottomRight := (corners collect: #x) max @ (corners collect: #y) max.
	element := BlElement new.
	element background: headColor.
	element position: topLeft - self measuredBounds position.
	element extent: (bottomRight - topLeft max: 1 @ 1).
	element geometry: (anOutline translatedCopyBy: topLeft negated) asBlocGeometry.
	^ element
]

{ #category : 'accessing' }
TLBlocNodeConnection >> headOutline [
	"The Geometry project shape of the head, in the coordinates of the view, or nil when there is no head"

	^ headOutline
]

{ #category : 'layout' }
TLBlocNodeConnection >> headSize [
	"The length and the width of the head: a thick line has a bigger head"

	^ self border width * 3 max: 10
]

{ #category : 'initialization' }
TLBlocNodeConnection >> initialize [
	"The head and the label are outside of the box of the segment"

	super initialize.
	self clipChildren: false
]

{ #category : 'accessing' }
TLBlocNodeConnection >> label [
	"The text element of the label of the connection, or nil when the connection has no label"

	^ label
]

{ #category : 'layout' }
TLBlocNodeConnection >> labelGap [
	"The space in pixels between the line and its label"

	^ 3
]

{ #category : 'layout' }
TLBlocNodeConnection >> placeSegment [
	"The element is the box of the segment, at least one pixel thick, and its line goes from a corner to the opposite one"

	| topLeft bottomRight |
	topLeft := segment start min: segment end.
	bottomRight := segment start max: segment end.
	self position: topLeft.
	self extent: (bottomRight - topLeft max: 1 @ 1).
	self geometry: (BlLineGeometry from: segment start - topLeft to: segment end - topLeft)
]

{ #category : 'accessing' }
TLBlocNodeConnection >> start [
	"The point where the line leaves the source node, in the coordinates of the view. Nil until the connection is updated"

	^ segment ifNotNil: [ :aSegment | aSegment start ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> toNode [
	"The element of the target node"

	^ toNode
]

{ #category : 'layout' }
TLBlocNodeConnection >> update [
	"Joins the borders of the nodes, once the layouts have placed them. The connection is in the view, in the coordinates of which the segment is computed"

	| view |
	view := self parent.
	segment := TLBlocConnectionSegment from: (fromNode outlineRelativeTo: view) to: (toNode outlineRelativeTo: view).
	self placeSegment.
	self updateHead.
	self centerLabel
]

{ #category : 'layout' }
TLBlocNodeConnection >> updateHead [
	"The head is drawn again at the end of the segment, pointing in its direction. There is none when the shape draws nothing, or when the segment is empty"

	| direction |
	head ifNotNil: [ head removeFromParent ].
	head := nil.
	headOutline := nil.
	direction := segment end - segment start.
	direction = (0 @ 0) ifTrue: [ ^ self ].
	headOutline := headShape
		               headOutlineAt: segment end
		               direction: direction normalized
		               length: self headSize
		               width: self headSize.
	headOutline ifNil: [ ^ self ].
	head := self headElementFor: headOutline.
	self addChild: head
]
