"
I am the Bloc element of a Telescope node. My dimension, my background and my border come from the style sheet of the node, the border being half inside and half outside of the edge, solid, dashed, dotted or double, the outline drawn a second time inside of the first one with a small gap: the colors can depend on the entity of the node, with a block or a gradient. My shape is my outline: a Geometry project shape (a polygon, a rectangle or an ellipse) built from the Telescope shape and my dimension, in my own coordinates. My Bloc geometry is derived from my outline, and the connections use my outline to find where they meet the border of the node. I have no outline when the node has no shape, and then only my label is drawn. The layouts of Telescope place a node by its center: #position: takes the center, but #position stays the top left corner of the element, because Bloc reads it to draw me. I do not clip my children, because the label of a node is drawn outside of the node. I know the elements of the connections which leave me and enter me, as my adjacent nodes are asked by the layouts of Telescope such as the tree layout.
"
Class {
	#name : 'TLBlocNodeElement',
	#superclass : 'BlElement',
	#instVars : [
		'dimension',
		'outline',
		'innerBorder',
		'outgoingConnections',
		'incomingConnections'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'initialization' }
TLBlocNodeElement >> addInnerBorderOf: aShape [
	"A double border draws the outline a second time, smaller, in the same place. It does not change my outline, which is where the connections meet the node"

	| inset innerOutline |
	outline ifNil: [ ^ self ].
	inset := self border width * 2.
	innerOutline := aShape outlineOfExtent: dimension - (inset * 2).
	innerOutline ifNil: [ ^ self ].
	innerBorder := BlElement new
		               position: inset @ inset;
		               extent: dimension - (inset * 2);
		               geometry: innerOutline asBlocGeometry;
		               border: self border;
		               beOutskirtsCentered;
		               yourself.
	self addChild: innerBorder at: 1
]

{ #category : 'layout' }
TLBlocNodeElement >> asBlocElement [
	"The Bloc element that stands for a node or a group: the node itself"

	^ self
]

{ #category : 'initialization' }
TLBlocNodeElement >> customizeFromNode: aNode [
	"The colors, the dimension and the shape of the style sheet can depend on the entity of the node: a block, or a gradient for the colors, gives the value of each node. The border is drawn with the line style of the style sheet, solid by default, half inside and half outside of the edge of the node"

	| styleSheet borderStyle shape |
	styleSheet := aNode effectiveStyleSheet.
	self beOutskirtsCentered.
	self background: (self valueOf: #backgroundColor forNode: aNode).
	self dimension: (self valueOf: #width forNode: aNode) @ (self valueOf: #height forNode: aNode).
	shape := self valueOf: #shape forNode: aNode.
	outline := shape outlineOfExtent: dimension.
	self geometry: (outline
			 ifNil: [ BlEmptyGeometry new ]
			 ifNotNil: #asBlocGeometry).
	borderStyle := (styleSheet attributes includesKey: #borderStyle)
		               ifTrue: [ styleSheet borderStyle ]
		               ifFalse: [ TLSolidLineStyle ].
	self border: (borderStyle blocBorderPaint: (self valueOf: #borderColor forNode: aNode) width: styleSheet borderWidth).
	borderStyle hasParallelLineInBloc ifTrue: [ self addInnerBorderOf: shape ]
]

{ #category : 'accessing' }
TLBlocNodeElement >> dimension [
	^ dimension
]

{ #category : 'accessing' }
TLBlocNodeElement >> dimension: aDimension [

	dimension := aDimension.
	self extent: aDimension
]

{ #category : 'layout' }
TLBlocNodeElement >> encompassingRectangle [
	"The rectangle of the node in the coordinates of its parent"

	^ self measuredBounds position extent: dimension
]

{ #category : 'layout' }
TLBlocNodeElement >> incomingAdjacentNodes [
	"The elements of the nodes connected to this node, which the layouts of Telescope ask for, such as the tree layout"

	^ incomingConnections collect: #fromNode
]

{ #category : 'initialization' }
TLBlocNodeElement >> initialize [
	"Labels are drawn outside the node bounds, so the node must not clip its children"

	super initialize.
	outgoingConnections := OrderedCollection new.
	incomingConnections := OrderedCollection new.
	self clipChildren: false
]

{ #category : 'initialization' }
TLBlocNodeElement >> innerBorder [
	"The second outline of a double border, inside of the first one, or nil for the other line styles"

	^ innerBorder
]

{ #category : 'accessing' }
TLBlocNodeElement >> isNode [
	^ true
]

{ #category : 'dimension' }
TLBlocNodeElement >> occupyMaxSpace [
	^ false
]

{ #category : 'layout' }
TLBlocNodeElement >> outgoingAdjacentNodes [
	"The elements of the nodes this node is connected to, which the layouts of Telescope ask for, such as the tree layout"

	^ outgoingConnections collect: #toNode
]

{ #category : 'accessing' }
TLBlocNodeElement >> outline [
	"The Geometry project shape of the node, in the coordinates of the node, or nil when the node has no shape. The Bloc geometry of the node is derived from it, and it knows its intersections with lines"

	^ outline
]

{ #category : 'layout' }
TLBlocNodeElement >> outlineRelativeTo: anAncestor [
	"A copy of the outline of the node, in the coordinates of an ancestor, without moving the outline of the node. A node without a shape has the rectangle of its dimension"

	^ (outline ifNil: [ GRectangle origin: 0 @ 0 corner: dimension ]) translatedCopyBy: (self topLeftRelativeTo: anAncestor)
]

{ #category : 'layout' }
TLBlocNodeElement >> placeAt: aTopLeft [
	"Places the element by its top left corner, as Bloc does, where #position: places it by its center, as the layouts of Telescope do"

	super position: aTopLeft
]

{ #category : 'layout' }
TLBlocNodeElement >> placement [
	"The top left corner of the element, as it was last asked, in the coordinates of its parent"

	^ self measuredBounds position
]

{ #category : 'layout' }
TLBlocNodeElement >> placementCenteredAt: aCenter [
	"The top left corner the element has when it is centered on the given point"

	^ aCenter - (dimension / 2)
]

{ #category : 'accessing' }
TLBlocNodeElement >> position: aCenter [
	"The layouts of Telescope place a node by its center, and Bloc places an element by its top left corner. Only the setter is the one of Telescope: Bloc reads #position to draw the element, so it must keep answering the top left corner"

	^ super position: aCenter - (dimension / 2)
]

{ #category : 'layout' }
TLBlocNodeElement >> rectanglesRelativeTo: anOrigin [
	"The rectangles of the node and of its labels, from the given origin: their union is what a visualization fits in a window"

	| topLeft |
	topLeft := anOrigin + self measuredBounds position.
	^ { (topLeft extent: dimension) } , (self children collect: [ :label | topLeft + label position extent: label extent ])
]

{ #category : 'connections' }
TLBlocNodeElement >> registerConnection: aConnectionElement [
	"The connection leaves this node, enters it, or both when it is a loop"

	aConnectionElement fromNode == self ifTrue: [ outgoingConnections add: aConnectionElement ].
	aConnectionElement toNode == self ifTrue: [ incomingConnections add: aConnectionElement ]
]

{ #category : 'layout' }
TLBlocNodeElement >> topLeftRelativeTo: anAncestor [
	"The top left corner of the node, in the coordinates of an ancestor: the view, whatever the groups between them"

	| topLeft current |
	topLeft := self measuredBounds position.
	current := self parent.
	[ current isNotNil and: [ current ~~ anAncestor ] ] whileTrue: [
			topLeft := topLeft + current measuredBounds position.
			current := current parent ].
	^ topLeft
]

{ #category : 'connections' }
TLBlocNodeElement >> unregisterConnection: aConnectionElement [
	outgoingConnections remove: aConnectionElement ifAbsent: [  ].
	incomingConnections remove: aConnectionElement ifAbsent: [  ]
]

{ #category : 'styling' }
TLBlocNodeElement >> valueOf: aProperty forNode: aNode [
	"The value of a property of the style sheet of the node, evaluated for the entity of the node"

	^ aNode effectiveStyleSheet obtainValue: aProperty forEntity: aNode entity inNode: aNode
]
