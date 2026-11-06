"
I zoom a Telescope visualization of Bloc with the mouse wheel or the trackpad: scrolling up zooms in and scrolling down zooms out, around the position of the mouse. The zoom is proportional to the distance of the scroll and moves to its target in a short animation.
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
	"The zoom keeps the point under the mouse fixed. The position of the event is the one in the window, the screen position is the one on the desktop. The distance of the scroll is the number of steps: a mouse wheel sends one step by notch, a trackpad sends many events of a part of a step"

	visualization zoomSmoothlyBy: (self zoomStep raisedTo: anEvent vector y) around: anEvent position
]

{ #category : 'accessing' }
TLBlocZoomHandler >> zoomStep [
	"The factor of one step of the scroll, which is one notch of a mouse wheel"

	^ 1.1
]
