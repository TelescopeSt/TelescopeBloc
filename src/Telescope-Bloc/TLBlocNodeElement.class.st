"
I am the Bloc element of a Telescope node. My dimension, my background and my border come from the style sheet of the node: the colors can depend on the entity of the node, with a block or a gradient. My shape is my outline: a Geometry project shape (a polygon, a rectangle or an ellipse) built from the Telescope shape and my dimension, in my own coordinates. My Bloc geometry is derived from my outline, and my outline knows its intersections with lines, which the connections need. I have no outline when the node has no shape, and then only my label is drawn. The layouts of Telescope place a node by its center: #position: takes the center and #position answers it, while the top left corner of the element is in its measured bounds. I do not clip my children, because the label of a node is drawn outside of the node.
"
Class {
	#name : 'TLBlocNodeElement',
	#superclass : 'BlElement',
	#instVars : [
		'dimension',
		'position',
		'outline'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'layout' }
TLBlocNodeElement >> asBlocElement [
	"The Bloc element that stands for a node or a group: the node itself"

	^ self
]

{ #category : 'layout' }
TLBlocNodeElement >> cornersRelativeTo: anOrigin [
	"The top left corners of the node and of its labels, from the given origin: the corners are what a visualization fits in a window"

	| topLeft |
	topLeft := anOrigin + self measuredBounds position.
	^ { topLeft } , (self children collect: [ :label | topLeft + label position ])
]

{ #category : 'styling' }
TLBlocNodeElement >> customizeFromNode: aNode [
	"The colors of the style sheet can depend on the entity of the node: a block or a gradient gives the color of each node"

	| styleSheet |
	styleSheet := aNode effectiveStyleSheet.
	self background: (self valueOf: #backgroundColor forNode: aNode).
	self dimension: styleSheet width @ styleSheet height.
	outline := styleSheet shape outlineOfExtent: dimension.
	self geometry: (outline
			 ifNil: [ BlEmptyGeometry new ]
			 ifNotNil: [ :shape | shape asBlocGeometry ]).
	self border: (BlBorder paint: (self valueOf: #borderColor forNode: aNode) width: styleSheet borderWidth)
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

{ #category : 'initialization' }
TLBlocNodeElement >> initialize [
	"Labels are drawn outside the node bounds, so the node must not clip its children"

	super initialize.
	self clipChildren: false
]

{ #category : 'accessing' }
TLBlocNodeElement >> isNode [
	^ true
]

{ #category : 'dimension' }
TLBlocNodeElement >> occupyMaxSpace [
	^ false
]

{ #category : 'accessing' }
TLBlocNodeElement >> outline [
	"The Geometry project shape of the node, in the coordinates of the node, or nil when the node has no shape. The Bloc geometry of the node is derived from it, and it knows its intersections with lines"

	^ outline
]

{ #category : 'accessing' }
TLBlocNodeElement >> position [
	"The center the layout of Telescope gave to the node. The top left corner of the element is in its measured bounds"

	^ position
]

{ #category : 'accessing' }
TLBlocNodeElement >> position: aCenter [
	"The layouts of Telescope place a node by its center, and Bloc places an element by its top left corner"

	position := aCenter.
	^ super position: aCenter - (dimension / 2)
]

{ #category : 'styling' }
TLBlocNodeElement >> valueOf: aProperty forNode: aNode [
	"The value of a property of the style sheet of the node, evaluated for the entity of the node"

	^ aNode effectiveStyleSheet obtainValue: aProperty forEntity: aNode entity inNode: aNode
]
