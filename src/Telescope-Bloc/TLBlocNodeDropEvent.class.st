"
I am sent to the element of a node when the user drops another node on it: the mouse was released over it after dragging a node. I carry the element of the dropped node, which the drop interactions of Telescope get as the parameter of their action. I am sent after the TLBlocNodeMovedEvent of the dropped node.
"
Class {
	#name : 'TLBlocNodeDropEvent',
	#superclass : 'BlEvent',
	#instVars : [
		'dropped'
	],
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'accessing' }
TLBlocNodeDropEvent >> dropped [
	"The element of the node which the user dropped on the node which receives me"

	^ dropped
]

{ #category : 'accessing' }
TLBlocNodeDropEvent >> dropped: aNodeElement [

	dropped := aNodeElement
]
