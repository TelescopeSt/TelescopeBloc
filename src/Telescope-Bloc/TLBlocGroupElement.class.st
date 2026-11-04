"
I am the Bloc element which holds the nodes of a sub-group of a Telescope visualization, so that the nodes are placed in my coordinates and move with me. I do not clip my children, because the labels of the nodes are drawn outside of the nodes. The Telescope layouts do not see me but a TLBlocGroup, which answers for me.
"
Class {
	#name : 'TLBlocGroupElement',
	#superclass : 'BlElement',
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'layout' }
TLBlocGroupElement >> cornersRelativeTo: anOrigin [
	"The top left corners of the nodes and labels of the group, from the given origin"

	| groupOrigin |
	groupOrigin := anOrigin + self measuredBounds position.
	^ self children flatCollect: [ :child | child cornersRelativeTo: groupOrigin ]
]

{ #category : 'initialization' }
TLBlocGroupElement >> initialize [

	super initialize.
	self clipChildren: false
]
