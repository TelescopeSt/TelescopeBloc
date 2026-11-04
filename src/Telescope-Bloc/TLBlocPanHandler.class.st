"
I pan a Telescope visualization of Bloc: I am installed on the root of the window, and when the primary mouse button is pressed on the background and the mouse moves, I move the visualization by the same distance. A press on a node is left to the node.
"
Class {
	#name : 'TLBlocPanHandler',
	#superclass : 'TLBlocNavigationHandler',
	#instVars : [
		'lastPosition'
	],
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'api - accessing' }
TLBlocPanHandler >> eventsToHandle [

	^ {
		  BlMouseDownEvent.
		  BlMouseMoveEvent.
		  BlMouseUpEvent }
]

{ #category : 'events' }
TLBlocPanHandler >> mouseDownEvent: anEvent [
	"Panning starts only on the background: a press on a node is not for me"

	(anEvent button = BlMouseButton primary and: [ anEvent target == anEvent currentTarget ]) ifTrue: [ lastPosition := anEvent screenPosition ]
]

{ #category : 'events' }
TLBlocPanHandler >> mouseMoveEvent: anEvent [

	lastPosition ifNotNil: [ :previousPosition |
			visualization panBy: anEvent screenPosition - previousPosition.
			lastPosition := anEvent screenPosition ]
]

{ #category : 'events' }
TLBlocPanHandler >> mouseUpEvent: anEvent [

	lastPosition := nil
]
