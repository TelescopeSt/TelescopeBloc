"
I am the superclass of the tests of the navigation of a visualization in a window, panning and zooming. I open a visualization of three nodes in a window and I send mouse events to the root of the window, so no real mouse is needed.
"
Class {
	#name : 'TLBlocConnectorNavigationTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'testing' }
TLBlocConnectorNavigationTest class >> isAbstract [

	^ self == TLBlocConnectorNavigationTest
]

{ #category : 'events' }
TLBlocConnectorNavigationTest >> moveTo: aPoint on: anElement [

	anElement fireEvent: (BlMouseMoveEvent new
			 position: aPoint;
			 screenPosition: aPoint * 2 + (700 @ 500);
			 yourself)
]

{ #category : 'helpers' }
TLBlocConnectorNavigationTest >> originOfTheView [
	"Where the point 0 @ 0 of the visualization is in the window: the panning and the zoom move it"

	^ connector view localPointToGlobal: 0 @ 0
]

{ #category : 'events' }
TLBlocConnectorNavigationTest >> pressAt: aPoint on: anElement [
	"fireEvent: sends the event up to the root of the window like a real mouse, dispatchEvent: would stop at the element. The position is the one in the window, as Bloc gives it. The screen position is the one on the desktop, which is not the same, for example on a display with a scale"

	anElement fireEvent: (BlMouseDownEvent new
			 position: aPoint;
			 screenPosition: aPoint * 2 + (700 @ 500);
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'events' }
TLBlocConnectorNavigationTest >> releaseAt: aPoint on: anElement [

	anElement fireEvent: (BlMouseUpEvent new
			 position: aPoint;
			 screenPosition: aPoint * 2 + (700 @ 500);
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'events' }
TLBlocConnectorNavigationTest >> scroll: aVector at: aPoint [
	"The position is the one in the window, as Bloc gives it. The screen position is the one on the desktop, which is not the same"

	connector view space root fireEvent: (BlMouseWheelEvent new
			 position: aPoint;
			 screenPosition: aPoint + (700 @ 500);
			 vector: aVector;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> scrollDownAt: aPoint [

	self scroll: (BlVector x: 0 y: -1) at: aPoint
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> scrollUpAt: aPoint [

	self scroll: (BlVector x: 0 y: 1) at: aPoint
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> setUp [
	"The visualization is fitted into the window when it opens, which enlarges three small nodes: the tests start from its natural size"

	super setUp.
	visualization layout: TLLinearLayout new.
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Navigation'.
	self settle.
	connector view zoomBy: 1 / connector view zoom around: 0 @ 0.
	self settle
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> settle [
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorNavigationTest >> testZoomInIsSmooth [

	| zoom |
	zoom := connector view zoom.
	connector view zoomIn.
	self assert: connector view zoom equals: zoom.
	self settle.
	self assert: (connector view zoom - (zoom * 1.25)) abs < 0.0001
]

{ #category : 'tests' }
TLBlocConnectorNavigationTest >> testZoomOutIsSmooth [

	| zoom |
	zoom := connector view zoom.
	connector view zoomOut.
	self assert: connector view zoom equals: zoom.
	self settle.
	self assert: (connector view zoom - (zoom / 1.25)) abs < 0.0001
]
