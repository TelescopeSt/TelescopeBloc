"
I pan a Telescope visualization of Bloc: I am installed on the root of the window, and when the primary mouse button is pressed on the background and the mouse moves, I move the visualization by the same distance. A press on a node is left to the node. The pan starts with the first move, not with the press, and ends when the button is released: I tell the visualization, which draws its content in a composition layer meanwhile.
"
Class {
	#name : 'TLBlocPanHandler',
	#superclass : 'TLBlocNavigationHandler',
	#instVars : [
		'lastPosition',
		'panning'
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

{ #category : 'initialization' }
TLBlocPanHandler >> initialize [

	super initialize.
	panning := false
]

{ #category : 'events' }
TLBlocPanHandler >> mouseDownEvent: anEvent [
	"Panning starts only on the background: a press on a node is not for me. The positions are the ones in the window, not the ones on the desktop"

	(anEvent button = BlMouseButton primary and: [ anEvent target == anEvent currentTarget ]) ifTrue: [ lastPosition := anEvent position ]
]

{ #category : 'events' }
TLBlocPanHandler >> mouseMoveEvent: anEvent [
	"The pan starts with the first move, not with the press: a click on the background does not prepare the visualization for a pan"

	lastPosition ifNotNil: [ :previousPosition |
			panning ifFalse: [
					panning := true.
					visualization startPanning ].
			visualization panBy: anEvent position - previousPosition.
			lastPosition := anEvent position ]
]

{ #category : 'events' }
TLBlocPanHandler >> mouseUpEvent: anEvent [

	panning ifTrue: [ visualization stopPanning ].
	panning := false.
	lastPosition := nil
]
