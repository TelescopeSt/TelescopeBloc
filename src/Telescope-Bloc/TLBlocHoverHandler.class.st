"
I tell a Telescope visualization of Bloc which node is under the mouse, so that it outlines it (see TLBlocVisualization>>#hover:). I am installed on the root of the window, where all the mouse moves arrive. The node is the innermost one under the mouse: the child of a composite, not the composite. There is none on the background, and none while the user pans, when the mouse events are for the background.
"
Class {
	#name : 'TLBlocHoverHandler',
	#superclass : 'TLBlocNavigationHandler',
	#category : 'Telescope-Bloc',
	#package : 'Telescope-Bloc'
}

{ #category : 'accessing' }
TLBlocHoverHandler >> eventsToHandle [

	^ {
		  BlMouseMoveEvent.
		  BlMouseLeaveEvent }
]

{ #category : 'mouse handlers' }
TLBlocHoverHandler >> mouseLeaveEvent: anEvent [
	"The mouse left the window"

	anEvent target == root ifTrue: [ visualization hover: nil ]
]

{ #category : 'mouse handlers' }
TLBlocHoverHandler >> mouseMoveEvent: anEvent [

	visualization hover: (visualization nodeElementHolding: anEvent target)
]
