"
I am the Bloc element of a connection between two nodes of a Telescope visualization. I am a line from the border of the outline of the source node to the border of the outline of the target node, along the line which joins their centers (see TLBlocConnectionSegment). I am in the view, in the coordinates of which the segment is computed, and my element is the box of the segment. The connector updates me once the layouts have placed the nodes. The color, the width and the line style of the line are the ones of the style sheet of the connection: solid, dashed, dotted or double, two lines on both sides of the segment, so that a double line ends where a single one does. I draw a head at the end of the line, with the shape of the head substyle: a triangle by default, and the color of the line unless the head has its own. I show the label of the connection next to the middle of the line, above it or on its right when it is vertical, and not on it. The line is the route of the curve style of the style sheet: a straight line, an arc when other connections join the same nodes (Bezier, the default of Telescope), or segments with right angles. The arrows at the start and at the middle, and the interactions are not implemented yet. #customizeFromConnection: can be called again when an interaction changed the style of the connection. A connection from a node to itself is a loop above the node (see TLBlocConnectionLoop), whatever its curve style: the loops of the same node are turned around it so that they do not overlap. Besides the head at the end of the line, a connection has the arrows which the substyles base (at the start, pointing into the source), middle and middleReversed (centered on the middle of the line, pointing along it or backwards) ask for when they have a shape: they are TLBlocConnectionArrow, with the color of the line unless their substyle has its own.
"
Class {
	#name : 'TLBlocNodeConnection',
	#superclass : 'BlElement',
	#instVars : [
		'fromNode',
		'toNode',
		'segment',
		'headShape',
		'headColor',
		'head',
		'headOutline',
		'label',
		'lineStyle',
		'lines',
		'lineWidth',
		'curveStyle',
		'parallelOffset',
		'arrows',
		'placesWhenJoined'
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

{ #category : 'arrows' }
TLBlocNodeConnection >> arrowNamed: aSymbol [
	"The arrow which the substyle of that name asks for, or nil when it has no shape"

	^ arrows
		  detect: [ :arrow | arrow name = aSymbol ]
		  ifNone: [ nil ]
]

{ #category : 'arrows' }
TLBlocNodeConnection >> arrows [
	"The arrows at the start and at the middle of the line, which the substyles base, middle and middleReversed of the style ask for. The head at the end is not one of them"

	^ arrows
]

{ #category : 'updating' }
TLBlocNodeConnection >> avoidsOtherNodes [
	"Whether the route goes around the nodes in its way, and so depends on their labels, which are measured after the first layout: only the segments do"

	^ curveStyle == TLSegmentsCurve
]

{ #category : 'layout' }
TLBlocNodeConnection >> bottomRightOf: somePoints [

	^ (somePoints collect: #x) max @ (somePoints collect: #y) max
]

{ #category : 'layout' }
TLBlocNodeConnection >> centerLabel [
	"The label is next to the middle of the line, not on it. Its extent is known once Bloc has laid it out, so this is also done when it is"

	| offset |
	(label isNil or: [ segment isNil ]) ifTrue: [ ^ self ].
	offset := (segment labelCenterFor: label extent gap: self labelGap) - self measuredBounds position - (label extent / 2).
	label measuredBounds position = offset ifFalse: [ label position: offset ]
]

{ #category : 'initialization' }
TLBlocNodeConnection >> createLabelFrom: aStyleSheet [
	"A text next to the middle of the line, placed once it is measured"

	| size text |
	size := (aStyleSheet attributes includesKey: #connectionLabelSize)
		        ifTrue: [ aStyleSheet obtainValue: #connectionLabelSize forEntity: nil inNode: nil ]
		        ifFalse: [ 10 ].
	text := (aStyleSheet obtainValue: #connectionLabel forEntity: nil inNode: nil) asString asRopedText fontSize: size.
	label := BlTextElement new
		         text: text;
		         yourself.
	label addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self centerLabel ].
	self addChild: label
]

{ #category : 'updating' }
TLBlocNodeConnection >> customizeFromConnection: aTLConnection [
	"The color, the width, the line style and the curve style of the style sheet of the connection are the ones of the line, solid by default. The head is the shape of the head substyle, a triangle when it has none, with the color of the line unless the head has its own. The arrows at the start and at the middle are the shapes of the substyles base, middle and middleReversed, when they have one. The label is a text at the middle of the line. It can be called again when an interaction changed the style: the previous label is removed, and #update draws the line, the head and the arrows again"

	| styleSheet headStyle |
	styleSheet := aTLConnection effectiveStyleSheet.
	label ifNotNil: [ :previous | previous removeFromParent ].
	label := nil.
	arrows do: [ :arrow | self removeElementOf: arrow ].
	lineStyle := (styleSheet attributes includesKey: #connectionLineStyle)
		             ifTrue: [ styleSheet connectionLineStyle ]
		             ifFalse: [ TLSolidLineStyle ].
	curveStyle := styleSheet curveStyle.
	lineWidth := styleSheet width.
	self border: (lineStyle blocBorderPaint: styleSheet color width: styleSheet width).
	headStyle := styleSheet > #head.
	headShape := (headStyle attributes includesKey: #shape)
		             ifTrue: [ headStyle shape ]
		             ifFalse: [ TLTriangle ].
	headColor := (headStyle attributes includesKey: #color)
		             ifTrue: [ headStyle color ]
		             ifFalse: [ styleSheet color ].
	arrows := TLBlocConnectionArrow arrowsFrom: styleSheet lineColor: styleSheet color.
	(styleSheet attributes includesKey: #connectionLabel) ifTrue: [ self createLabelFrom: styleSheet ]
]

{ #category : 'arrows' }
TLBlocNodeConnection >> elementFor: anOutline colored: aColor [
	"An element of the color, with the geometry of the outline, which is in the coordinates of the view. The element is in my coordinates"

	| corners topLeft bottomRight element |
	corners := anOutline encompassingRectangle vertices collect: #asPoint as: Array.
	topLeft := (corners collect: #x) min @ (corners collect: #y) min.
	bottomRight := (corners collect: #x) max @ (corners collect: #y) max.
	element := BlElement new.
	element background: aColor.
	element position: topLeft - self measuredBounds position.
	element extent: (bottomRight - topLeft max: 1 @ 1).
	element geometry: (anOutline translatedCopyBy: topLeft negated) asBlocGeometry.
	^ element
]

{ #category : 'layout' }
TLBlocNodeConnection >> encompassingRectangle [
	"The box of the segment, in the coordinates of the view"

	^ self measuredBounds position extent: self extent
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

{ #category : 'accessing' }
TLBlocNodeConnection >> head [
	"The element of the head of the connection, or nil when the shape of the head draws nothing"

	^ head
]

{ #category : 'arrows' }
TLBlocNodeConnection >> headElementFor: anOutline [
	"An element of the color of the head, with the geometry of the outline, which is in the coordinates of the view. The element is in my coordinates"

	^ self elementFor: anOutline colored: headColor
]

{ #category : 'accessing' }
TLBlocNodeConnection >> headOutline [
	"The Geometry project shape of the head, in the coordinates of the view, or nil when there is no head"

	^ headOutline
]

{ #category : 'layout' }
TLBlocNodeConnection >> headSize [
	"The length and the width of the head: a thick line has a bigger head"

	^ lineWidth * 3 max: 10
]

{ #category : 'initialization' }
TLBlocNodeConnection >> initialize [
	"The head and the label are outside of the box of the route. A connection alone between its nodes has no offset, and no arrow at its start or middle"

	super initialize.
	lines := #(  ).
	arrows := #(  ).
	parallelOffset := 0.
	self clipChildren: false
]

{ #category : 'updating' }
TLBlocNodeConnection >> isJoiningTheNodesWhereTheyAre [
	"Whether the nodes are where they were when I joined them: false if I never did, or if something moved or resized a node since, for example a composite node which fits its children"

	^ self parent isNotNil and: [ placesWhenJoined = self placesOfTheNodes ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> label [
	"The text element of the label of the connection, or nil when the connection has no label"

	^ label
]

{ #category : 'layout' }
TLBlocNodeConnection >> labelGap [
	"The space in pixels between the line and its label"

	^ 3
]

{ #category : 'layout' }
TLBlocNodeConnection >> lineElementFor: aRoute relativeTo: aPoint [
	"A line with the border of the connection, in its own box, at the place of the route in my coordinates"

	| topLeft |
	topLeft := self topLeftOf: aRoute points.
	^ BlElement new
		  position: topLeft - aPoint;
		  extent: ((self bottomRightOf: aRoute points) - topLeft max: 1 @ 1);
		  geometry: (aRoute geometryRelativeTo: topLeft);
		  border: self border;
		  yourself
]

{ #category : 'layout' }
TLBlocNodeConnection >> lineGap [
	"The space in pixels between the two lines of a double line, from center to center: the width of a line and of the gap, each a third of the width of the connection"

	^ self border width * 2
]

{ #category : 'layout' }
TLBlocNodeConnection >> lines [
	"The two lines of a double line, which are the children of the element, or none for the other line styles"

	^ lines
]

{ #category : 'updating' }
TLBlocNodeConnection >> obstaclesAmong: someNodeElements [
	"The rectangles, in the coordinates of the view, of the nodes which can be in the way of the connection: not the nodes it joins, not their children, and not the composites which contain them"

	| view sourceRectangle targetRectangle |
	view := self parent.
	sourceRectangle := self rectangleOfNode: fromNode in: view.
	targetRectangle := self rectangleOfNode: toNode in: view.
	^ (someNodeElements reject: [ :node | node == fromNode or: [ node == toNode ] ])
		  collect: [ :node | self rectangleOfNode: node in: view ]
		  thenSelect: [ :rectangle |
				  (rectangle containsPoint: sourceRectangle center) not and: [
					  (rectangle containsPoint: targetRectangle center) not and: [ (sourceRectangle containsRect: rectangle) not and: [ (targetRectangle containsRect: rectangle) not ] ] ] ]
]

{ #category : 'accessing' }
TLBlocNodeConnection >> parallelOffset [
	^ parallelOffset
]

{ #category : 'accessing' }
TLBlocNodeConnection >> parallelOffset: aNumber [
	"The distance which spreads the connections between the same two nodes, to the left of the direction of this connection when it is positive. A Bezier curve is an arc when it is not 0"

	parallelOffset := aNumber
]

{ #category : 'layout' }
TLBlocNodeConnection >> placeLinesRelativeTo: aPoint [
	"A single line is the geometry of the element. A double line is two children, because they are outside of the box of the route. An empty route has no side"

	lines do: [ :line | line removeFromParent ].
	lines := #(  ).
	lineStyle hasParallelLineInBloc ifFalse: [ ^ self geometry: (segment geometryRelativeTo: aPoint) ].
	self geometry: BlEmptyGeometry new.
	segment start = segment end ifTrue: [ ^ self ].
	lines := { 1. -1 } collect: [ :side | self lineElementFor: (segment translatedBy: segment upwardNormal * (self lineGap / 2 * side)) relativeTo: aPoint ].
	lines reverseDo: [ :line | self addChild: line at: 1 ]
]

{ #category : 'layout' }
TLBlocNodeConnection >> placeSegment [
	"The element is the box of the points of the route, at least one pixel thick, and its line is the geometry of the route. A double line has no line of its own: it is two lines on both sides of the route"

	| topLeft |
	topLeft := self topLeftOf: segment points.
	self position: topLeft.
	self extent: ((self bottomRightOf: segment points) - topLeft max: 1 @ 1).
	self placeLinesRelativeTo: topLeft
]

{ #category : 'updating' }
TLBlocNodeConnection >> placesOfTheNodes [
	"Where the nodes are in the view, and how big: what the route depends on"

	^ {
		  (fromNode topLeftRelativeTo: self parent).
		  fromNode dimension.
		  (toNode topLeftRelativeTo: self parent).
		  toNode dimension }
]

{ #category : 'updating' }
TLBlocNodeConnection >> rectangleOfNode: aNodeElement in: aView [
	"The rectangle of the node and of its label, in the coordinates of the view"

	^ aNodeElement rectangleWithLabelRelativeTo: aView
]

{ #category : 'layout' }
TLBlocNodeConnection >> rectanglesRelativeTo: anOrigin [
	"The box of the route and the label, from the given origin: a curve goes out of the box of its nodes, and the visualization has to fit it in the window"

	| topLeft |
	topLeft := anOrigin + self measuredBounds position.
	^ { (topLeft extent: self extent) } , (label
		   ifNil: [ #(  ) ]
		   ifNotNil: [ :aLabel | { (topLeft + aLabel measuredBounds position extent: aLabel extent) } ])
]

{ #category : 'arrows' }
TLBlocNodeConnection >> removeElementOf: anArrow [

	anArrow element ifNotNil: [ :arrowElement | arrowElement removeFromParent ].
	anArrow element: nil
]

{ #category : 'accessing' }
TLBlocNodeConnection >> route [
	"The route of the line in the coordinates of the view, which the curve style gave: nil until the connection is updated"

	^ segment
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
TLBlocNodeConnection >> topLeftOf: somePoints [

	^ (somePoints collect: #x) min @ (somePoints collect: #y) min
]

{ #category : 'updating' }
TLBlocNodeConnection >> update [
	"Joins the borders of the nodes, once the layouts have placed them, with no other node in the way"

	self updateAvoiding: #(  )
]

{ #category : 'arrows' }
TLBlocNodeConnection >> updateArrows [
	"The arrows are drawn again on the route. They are the size of the head"

	arrows do: [ :arrow |
			self removeElementOf: arrow.
			arrow placeOn: segment size: self headSize.
			arrow outline ifNotNil: [ :arrowOutline |
					arrow element: (self elementFor: arrowOutline colored: arrow color).
					self addChild: arrow element ] ]
]

{ #category : 'updating' }
TLBlocNodeConnection >> updateAvoiding: someRectangles [
	"Joins the borders of the nodes, once the layouts have placed them. The connection is in the view, in the coordinates of which the route is computed. The route is the one of the curve style: a straight line, an arc when other connections join the same nodes, or segments with right angles which go around the rectangles of the other nodes, in the coordinates of the view. A connection from a node to itself is a loop, whatever its curve style. The head and the arrows are drawn on the route"

	| view |
	view := self parent.
	segment := fromNode == toNode
		           ifTrue: [ TLBlocConnectionLoop around: (fromNode outlineRelativeTo: view) offset: parallelOffset ]
		           ifFalse: [
				           curveStyle
					           blocRouteFrom: (fromNode outlineRelativeTo: view)
					           to: (toNode outlineRelativeTo: view)
					           offset: parallelOffset
					           obstacles: someRectangles ].
	placesWhenJoined := self placesOfTheNodes.
	self placeSegment.
	self updateHead.
	self updateArrows.
	self centerLabel
]

{ #category : 'layout' }
TLBlocNodeConnection >> updateHead [
	"The head is drawn again at the end of the route, pointing along it. There is none when the shape draws nothing, or when the route is empty"

	| direction |
	head ifNotNil: [ head removeFromParent ].
	head := nil.
	headOutline := nil.
	direction := segment endDirection.
	direction ifNil: [ ^ self ].
	headOutline := headShape
		               headOutlineAt: segment end
		               direction: direction
		               length: self headSize
		               width: self headSize.
	headOutline ifNil: [ ^ self ].
	head := self headElementFor: headOutline.
	self addChild: head
]
