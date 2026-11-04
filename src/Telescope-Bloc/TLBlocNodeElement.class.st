"
I am the Bloc element of a Telescope node. My dimension, my background and my border come from the style sheet of the node. My shape is my outline: a Geometry project shape (a polygon, a rectangle or an ellipse) built from the Telescope shape and my dimension, in my own coordinates. My Bloc geometry is derived from my outline, and my outline knows its intersections with lines, which the connections need. I have no outline when the node has no shape, and then only my label is drawn. I do not clip my children, because the label of a node is drawn outside of the node.
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

{ #category : 'accessing' }
TLBlocNodeElement >> customizeFrom: aTLStyleSheet [

	self background: aTLStyleSheet backgroundColor.
	self dimension: aTLStyleSheet width @ aTLStyleSheet height.
	outline := aTLStyleSheet shape outlineOfExtent: dimension.
	self geometry: (outline
			 ifNil: [ BlEmptyGeometry new ]
			 ifNotNil: [ :shape | shape asBlocGeometry ]).
	self border: (BlBorder paint: aTLStyleSheet borderColor width: aTLStyleSheet borderWidth)
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
	^ position
]

{ #category : 'accessing' }
TLBlocNodeElement >> position: aPoint [

	position := aPoint.
	^ super position: aPoint
]
