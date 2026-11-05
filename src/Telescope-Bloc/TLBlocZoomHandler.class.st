"
I zoom a Telescope visualization of Bloc with the mouse wheel: scrolling up zooms in and scrolling down zooms out, around the position of the mouse.
"
Class {
	#name : 'TLBlocZoomHandler',
	#superclass : 'TLBlocNavigationHandler',
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'api - accessing' }
TLBlocZoomHandler >> eventsToHandle [

	^ { BlMouseWheelEvent }
]

{ #category : 'events' }
TLBlocZoomHandler >> mouseWheelEvent: anEvent [
	"The zoom keeps the point under the mouse fixed. The position of the event is the one in the window, the screen position is the one on the desktop"

	visualization
		zoomBy: (anEvent isScrollUp
				 ifTrue: [ self zoomStep ]
				 ifFalse: [ self zoomStep reciprocal ])
		around: anEvent position
]

{ #category : 'accessing' }
TLBlocZoomHandler >> zoomStep [
	"The factor of one notch of the wheel"

	^ 1.1
]
