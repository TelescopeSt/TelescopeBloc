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

{ #category : 'running' }
TLBlocConnectorNavigationTest >> moveTo: aPoint on: anElement [

	anElement fireEvent: (BlMouseMoveEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> pressAt: aPoint on: anElement [
	"fireEvent: sends the event up to the root of the window like a real mouse, dispatchEvent: would stop at the element"

	anElement fireEvent: (BlMouseDownEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> releaseAt: aPoint on: anElement [

	anElement fireEvent: (BlMouseUpEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 button: BlMouseButton primary;
			 yourself)
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> scroll: aVector at: aPoint [

	connector view space root fireEvent: (BlMouseWheelEvent new
			 position: aPoint;
			 screenPosition: aPoint;
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

	super setUp.
	visualization layout: TLLinearLayout new.
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Navigation'.
	self settle
]

{ #category : 'running' }
TLBlocConnectorNavigationTest >> settle [

	connector view space settleForDuration: 1 seconds
]
