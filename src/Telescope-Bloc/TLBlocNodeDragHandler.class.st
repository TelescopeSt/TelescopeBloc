"
I let the user drag the nodes of a Telescope visualization of Bloc with the mouse: I am installed on the root of the window, and when the primary mouse button is pressed on a node or on its label and the mouse goes further than a few pixels, I move the node by the same distance, divided by the zoom of the visualization. A press on the background is for the pan handler. The node knows it was dragged, so that the click which ends the drag does not execute its click interactions. The place of a dragged node is not kept: a layout which is applied again puts it back. When a dragged node is dropped it receives a TLBlocNodeMovedEvent. The node under the pointer is told that a node was dropped on it with a TLBlocNodeDropEvent.
"
Class {
	#name : 'TLBlocNodeDragHandler',
	#superclass : 'TLBlocNavigationHandler',
	#instVars : [
		'node',
		'lastPosition',
		'pendingMove',
		'dragging'
	],
	#category : 'Telescope-Bloc-Navigation',
	#package : 'Telescope-Bloc',
	#tag : 'Navigation'
}

{ #category : 'events' }
TLBlocNodeDragHandler >> eventsToHandle [

	^ {
		  BlMouseDownEvent.
		  BlMouseMoveEvent.
		  BlMouseUpEvent }
]

{ #category : 'events' }
TLBlocNodeDragHandler >> mouseDownEvent: anEvent [
	"A press with the primary button on a node, or on its label, starts a possible drag. The positions are the ones in the window, not the ones on the desktop"

	anEvent button = BlMouseButton primary ifFalse: [ ^ self ].
	node := self nodeElementOf: anEvent target.
	node ifNil: [ ^ self ].
	node wasDragged: false.
	lastPosition := anEvent position.
	pendingMove := 0 @ 0.
	dragging := false
]

{ #category : 'events' }
TLBlocNodeDragHandler >> mouseMoveEvent: anEvent [
	"The node follows the mouse once the mouse went far enough: a click is not a drag. The distance is the one of the window, the visualization may be zoomed"

	node ifNil: [ ^ self ].
	pendingMove := pendingMove + (anEvent position - lastPosition).
	lastPosition := anEvent position.
	dragging ifFalse: [ dragging := pendingMove r >= self threshold ].
	dragging ifFalse: [ ^ self ].
	node wasDragged: true.
	visualization keepPositionWhile: [ node placeAt: node placement + (pendingMove / visualization zoom) ].
	pendingMove := 0 @ 0.
	visualization nodesMoved
]

{ #category : 'events' }
TLBlocNodeDragHandler >> mouseUpEvent: anEvent [
	"The node was dropped when it was dragged: it is told where, for the moved interactions of Telescope, and the node under the pointer is told which node was dropped on it, for its drop interactions"

	| target |
	(node isNotNil and: [ dragging == true ]) ifTrue: [
			node dispatchEvent: (TLBlocNodeMovedEvent new
					 position: node placement + (node dimension / 2);
					 yourself).
			target := visualization dropTargetOf: node at: anEvent position.
			target ifNotNil: [
					target dispatchEvent: (TLBlocNodeDropEvent new
							 dropped: node;
							 yourself) ] ].
	node := nil
]

{ #category : 'dragging' }
TLBlocNodeDragHandler >> nodeElementOf: anElement [
	"The node which contains the element, if any: the target of a press on a label is the label. A trigger is not dragged away from its node: there is no node to drag when the press is on it"

	| current |
	current := anElement.
	[ current isNil or: [ current class = TLBlocNodeElement ] ] whileFalse: [ current := current parent ].
	^ (current isNotNil and: [ current isTrigger ]) ifFalse: [ current ]
]

{ #category : 'private' }
TLBlocNodeDragHandler >> threshold [
	"The distance in pixels the mouse goes before a press becomes a drag"

	^ 3
]
