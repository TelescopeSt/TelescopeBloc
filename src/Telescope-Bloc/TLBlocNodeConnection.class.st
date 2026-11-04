"
I am the Bloc element of a connection between two nodes of a Telescope visualization. I am a line from the border of the outline of the source node to the border of the outline of the target node, along the line which joins their centers (see TLBlocConnectionSegment). I am in the view, in the coordinates of which the segment is computed, and my element is the box of the segment. The connector updates me once the layouts have placed the nodes. The color and the width of the line are the ones of the style sheet of the connection. The heads, the curve styles and the labels of the connections are not implemented yet.
"
Class {
	#name : 'TLBlocNodeConnection',
	#superclass : 'BlElement',
	#instVars : [
		'fromNode',
		'toNode',
		'segment'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocNodeConnection class >> from: aSourceElement to: aTargetElement [
	"The elements are the ones of two nodes, which are in the same view as the connection"

	^ self new
		  fromNode: aSourceElement toNode: aTargetElement;
		  yourself
]

{ #category : 'layout' }
TLBlocNodeConnection >> cornersRelativeTo: anOrigin [
	"A connection is between its nodes: it does not take part in the fit of the visualization in its window"

	^ #(  )
]

{ #category : 'initialization' }
TLBlocNodeConnection >> customizeFromConnection: aTLConnection [
	"The color and the width of the style sheet of the connection are the ones of the line"

	| styleSheet |
	styleSheet := aTLConnection effectiveStyleSheet.
	self border: (BlBorder paint: styleSheet color width: styleSheet width)
]

{ #category : 'accessing' }
TLBlocNodeConnection >> end [
	"The point where the line arrives on the target node, in the coordinates of the view. Nil until the connection is updated"

	^ segment ifNotNil: [ :aSegment | aSegment end ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> fromNode [
	"The element of the source node"

	^ fromNode
]

{ #category : 'initialization' }
TLBlocNodeConnection >> fromNode: aSourceElement toNode: aTargetElement [

	fromNode := aSourceElement.
	toNode := aTargetElement
]

{ #category : 'layout' }
TLBlocNodeConnection >> placeSegment [
	"The element is the box of the segment, at least one pixel thick, and its line goes from a corner to the opposite one"

	| topLeft bottomRight |
	topLeft := segment start min: segment end.
	bottomRight := segment start max: segment end.
	self position: topLeft.
	self extent: (bottomRight - topLeft max: 1 @ 1).
	self geometry: (BlLineGeometry from: segment start - topLeft to: segment end - topLeft)
]

{ #category : 'accessing' }
TLBlocNodeConnection >> start [
	"The point where the line leaves the source node, in the coordinates of the view. Nil until the connection is updated"

	^ segment ifNotNil: [ :aSegment | aSegment start ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> toNode [
	"The element of the target node"

	^ toNode
]

{ #category : 'layout' }
TLBlocNodeConnection >> update [
	"Joins the borders of the nodes, once the layouts have placed them. The connection is in the view, in the coordinates of which the segment is computed"

	| view |
	view := self parent.
	segment := TLBlocConnectionSegment from: (fromNode outlineRelativeTo: view) to: (toNode outlineRelativeTo: view).
	self placeSegment
]
