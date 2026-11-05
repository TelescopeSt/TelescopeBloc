"
I am sent to the element of a node when the user drops it after dragging it. I carry the center of the node in the coordinates of its parent, which the moved interactions of Telescope get as the parameter of their action.
"
Class {
	#name : 'TLBlocNodeMovedEvent',
	#superclass : 'BlEvent',
	#instVars : [
		'position'
	],
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'accessing' }
TLBlocNodeMovedEvent >> position [
	"The center of the node where the user dropped it, in the coordinates of its parent: the view, or the group or the composite node which holds it"

	^ position
]

{ #category : 'accessing' }
TLBlocNodeMovedEvent >> position: aPoint [

	position := aPoint
]
