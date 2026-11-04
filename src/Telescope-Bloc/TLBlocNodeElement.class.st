"
I am the Bloc element of a Telescope node. My dimension, my shape, my background and my border come from the style sheet of the node. I do not clip my children, because the label of a node is drawn outside of the node.
"
Class {
	#name : 'TLBlocNodeElement',
	#superclass : 'BlElement',
	#instVars : [
		'dimension',
		'position'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'accessing' }
TLBlocNodeElement >> customizeFrom: aTLStyleSheet [ 
	self background: aTLStyleSheet backgroundColor.
	self dimension: aTLStyleSheet width @ aTLStyleSheet height.
	self geometry: aTLStyleSheet shape obtainTLBlocShape.
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
TLBlocNodeElement >> position [
	^ position
]

{ #category : 'accessing' }
TLBlocNodeElement >> position: aPoint [

	position := aPoint.
	^ super position: aPoint
]
