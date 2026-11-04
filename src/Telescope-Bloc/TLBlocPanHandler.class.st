"
I pan a Telescope visualization of Bloc: I am installed on the root of the window, and when the primary mouse button is pressed on the background and the mouse moves, I move the visualization by the same distance. A press on a node is left to the node.
"
Class {
	#name : 'TLBlocPanHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'visualization',
		'root',
		'lastPosition'
	],
	#category : 'Telescope-Bloc-Panning',
	#package : 'Telescope-Bloc',
	#tag : 'Panning'
}

{ #category : 'instance creation' }
TLBlocPanHandler class >> on: aVisualization [

	^ self new
		  visualization: aVisualization;
		  yourself
]

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

{ #category : 'api - hooks' }
TLBlocPanHandler >> onInstalledIn: anElement [

	super onInstalledIn: anElement.
	root := anElement
]

{ #category : 'api - hooks' }
TLBlocPanHandler >> onUninstalledIn: anElement [

	super onUninstalledIn: anElement.
	root := nil
]

{ #category : 'installing' }
TLBlocPanHandler >> uninstall [
	"Stops listening to the window the visualization was in"

	root ifNotNil: [ :element | element removeEventHandler: self ]
]

{ #category : 'accessing' }
TLBlocPanHandler >> visualization: aVisualization [

	visualization := aVisualization
]
