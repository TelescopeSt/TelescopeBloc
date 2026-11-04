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

	visualization
		zoomBy: (anEvent isScrollUp
				 ifTrue: [ self zoomStep ]
				 ifFalse: [ self zoomStep reciprocal ])
		around: anEvent screenPosition
]

{ #category : 'accessing' }
TLBlocZoomHandler >> zoomStep [
	"The factor of one notch of the wheel"

	^ 1.1
]
