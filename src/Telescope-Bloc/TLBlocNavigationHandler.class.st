"
I am the superclass of the handlers that navigate in a Telescope visualization of Bloc, panning and zooming. I am installed on the root of the window, where the mouse events of the background arrive, and I act on the visualization.
"
Class {
	#name : 'TLBlocNavigationHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'visualization',
		'root'
	],
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'instance creation' }
TLBlocNavigationHandler class >> on: aVisualization [

	^ self new
		  visualization: aVisualization;
		  yourself
]

{ #category : 'installing' }
TLBlocNavigationHandler >> onInstalledIn: anElement [

	super onInstalledIn: anElement.
	root := anElement
]

{ #category : 'installing' }
TLBlocNavigationHandler >> onUninstalledIn: anElement [

	super onUninstalledIn: anElement.
	root := nil
]

{ #category : 'installing' }
TLBlocNavigationHandler >> uninstall [
	"Stops listening to the window the visualization was in"

	root ifNotNil: [ :element | element removeEventHandler: self ]
]

{ #category : 'accessing' }
TLBlocNavigationHandler >> visualization: aVisualization [

	visualization := aVisualization
]
