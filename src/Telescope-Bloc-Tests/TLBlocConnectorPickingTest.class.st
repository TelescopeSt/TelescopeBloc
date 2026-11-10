Class {
	#name : 'TLBlocConnectorPickingTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorPickingTest >> blocTargetAt: aPoint [
	"The element which Bloc itself finds under the point, from its bounds in the window"

	^ BlElement >> #findMouseEventTargetAt: valueWithReceiver: connector view arguments: { aPoint }
]

{ #category : 'helpers' }
TLBlocConnectorPickingTest >> hasValidGeometryBoundsInSpace: anElement [
	"Whether Bloc computed the bounds of the element in the window since they last changed"

	^ ((anElement instVarNamed: #boundsCache) instVarNamed: #geometryBoundsInSpace)
		  ifNil: [ false ]
		  ifNotNil: [ :bounds | (bounds instVarNamed: #isValid) ifNil: [ false ] ]
]

{ #category : 'running' }
TLBlocConnectorPickingTest >> setUp [
	"Nodes with a label at different places, connections between them, and a composite node whose children are shown, zoomed and panned: the transformation of the view moves everything in the window"

	super setUp.
	visualization styleSheet
		nodeLabel: #asString position: #top;
		compositeExpandedByDefault: true.
	visualization childrenProperty: [ :number |
			number = 3
				ifTrue: [ #( 31 32 ) ]
				ifFalse: [ #(  ) ] ].
	visualization nodeCreationStrategy beRecursive.
	visualization layout: (TLLinearLayout perLine: 3).
	visualization addNodesFromEntities: (1 to: 6).
	visualization connectFollowingProperty: [ :number | { (number \\ 6 + 1) } ].
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Picking'.
	connector view space settleForDuration: 1 seconds.
	connector view zoomBy: 1.7 around: 120 @ 80.
	connector view panBy: 13 @ -7.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorPickingTest >> testTheElementUnderTheMouseIsFoundWithoutTheBoundsInTheWindow [
	"After a pan, Bloc computes the bounds in the window of all the elements again to find the one under the mouse: with thousands of nodes it takes milliseconds at each move of the mouse"

	| node |
	node := connector view content children detect: [ :child | child class == TLBlocNodeElement ].
	connector view panBy: 5 @ 5.
	connector view space settleForDuration: 1 seconds.
	self deny: (self hasValidGeometryBoundsInSpace: node).
	connector view findMouseEventTargetAt: 1 @ 1.
	self deny: (self hasValidGeometryBoundsInSpace: node)
]

{ #category : 'tests' }
TLBlocConnectorPickingTest >> testTheElementUnderTheMouseIsTheOneBlocFinds [
	"The view looks for the element under the mouse in its own coordinates, which a pan or a zoom does not change, instead of the bounds of each element in the window"

	| found |
	found := Set new.
	0 to: 400 by: 3 do: [ :x |
			0 to: 300 by: 3 do: [ :y |
					| point target |
					point := x @ y.
					target := connector view findMouseEventTargetAt: point.
					self assert: target identicalTo: (self blocTargetAt: point).
					target ifNotNil: [ found add: target class ] ] ].
	self assert: (found includesAll: {
				 TLBlocNodeElement.
				 BlTextElement })
]

{ #category : 'tests' }
TLBlocConnectorPickingTest >> testTheVisualizationAndItsContentAreNeverUnderTheMouse [
	"The view and its content are plain elements: they must let a press on the background reach the root of the space, which pans"

	| view |
	view := connector view.
	0 to: 400 by: 5 do: [ :x |
			0 to: 300 by: 5 do: [ :y |
					| target |
					target := view findMouseEventTargetAt: x @ y.
					self deny: target identicalTo: view.
					self deny: target identicalTo: view content ] ]
]
