"
I am the Bloc element of a Telescope node. My dimension, my background and my border come from the style sheet of the node, the border being half inside and half outside of the edge, solid, dashed, dotted or double, the outline drawn a second time inside of the first one with a small gap: the colors can depend on the entity of the node, with a block or a gradient. My shape is my outline: a Geometry project shape (a polygon, a rectangle or an ellipse) built from the Telescope shape and my dimension, in my own coordinates. My Bloc geometry is derived from my outline, and the connections use my outline to find where they meet the border of the node. I have no outline when the node has no shape, and then only my label is drawn. The layouts of Telescope place a node by its center: #position: takes the center, but #position stays the top left corner of the element, because Bloc reads it to draw me. I do not clip my children, because the label of a node is drawn outside of the node. I know the elements of the connections which leave me and enter me, as my adjacent nodes are asked by the layouts of Telescope such as the tree layout. I know whether the user dragged me with the mouse, because the click which ends a drag is not a click. A composite node has its children in a group: the element of the group is inside of me, at my padding from my border, and I am as big as it and the padding (#fitToChildren). Without child, or when I am collapsed, I have the dimension of my style again. A dimension of 0 gives an outline of at least one pixel. A node can have a fixed center, which a layout does not change (#defineFixedRelativePosition:): this is what the action which memorizes the position of a node does. My label is made again when the entity of the node changes. When the label of a composite node with children displayed is at its center (#inside), it is in a strip at the top of the node: the node makes room for it above its children (#headerHeight), is as wide as it when it is wider than the children, and centers the children under it. The node makes room once, when the label is measured (#fitToChildrenWhenTheHeaderChanged), and does not follow the children the user moved. A collapsed composite, and a leaf, have their label centered over them. A node which takes all the space of its line (the takeAllSpace or occupyMaximumSpace of its style, which can depend on the entity) answers true to #occupyMaxSpace: the linear layout makes it as high as the tallest node of its line, and asks for #restoreOriginalDimension before it is applied again. Applying its style again keeps the height the layout gave it. #width and #height are the ones of the dimension, because the layouts of Telescope ask them and a Bloc element has no extent before it is laid out. A shape trigger of Telescope (the small shape which runs the action of a shape interaction on click, such as the one which expands a node of the tree explorer) is a node element too, a child of the element of its node, so it follows the node: its center is on the side of the trigger position of the style sheet (on the right by default), and it is placed again when the node changes its dimension. A press on a trigger does not drag it.
"
Class {
	#name : 'TLBlocNodeElement',
	#superclass : 'BlElement',
	#traits : 'TTLBlocEasedColors',
	#classTraits : 'TTLBlocEasedColors classTrait',
	#instVars : [
		'dimension',
		'outline',
		'innerBorder',
		'outgoingConnections',
		'incomingConnections',
		'wasDragged',
		'childrenGroup',
		'ownDimension',
		'shape',
		'borderStyle',
		'fixedCenter',
		'fittedHeaderExtent',
		'occupiesMaxSpace',
		'triggerPosition'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'initialization' }
TLBlocNodeElement >> addInnerBorderOf: aShape [
	"A double border draws the outline a second time, smaller, in the same place. It does not change my outline, which is where the connections meet the node"

	| inset innerOutline |
	outline ifNil: [ ^ self ].
	inset := self border width * 2.
	innerOutline := aShape outlineOfExtent: dimension - (inset * 2).
	innerOutline ifNil: [ ^ self ].
	innerBorder := BlElement new
		               position: inset @ inset;
		               extent: dimension - (inset * 2);
		               geometry: innerOutline asBlocGeometry;
		               border: self border;
		               beOutskirtsCentered;
		               yourself.
	self addChild: innerBorder at: 1
]

{ #category : 'composite' }
TLBlocNodeElement >> adoptChildren: aTLBlocGroup [
	"The children of a composite node are in their own group: its element goes inside of mine, and I am as big as it"

	childrenGroup := aTLBlocGroup.
	aTLBlocGroup element removeFromParent.
	self addChild: aTLBlocGroup element at: 1.
	self fitToChildren
]

{ #category : 'colors' }
TLBlocNodeElement >> applyColors: someColors [
	"The background and the border"

	self background: someColors first.
	self border: (self border copyWithPaint: someColors second)
]

{ #category : 'layout' }
TLBlocNodeElement >> asBlocElement [
	"The Bloc element that stands for a node or a group: the node itself"

	^ self
]

{ #category : 'composite' }
TLBlocNodeElement >> childrenElement [
	"The element which holds the children of a composite node, inside of me, or nil when I have no child displayed"

	^ childrenGroup ifNotNil: [ :group | group element ]
]

{ #category : 'composite' }
TLBlocNodeElement >> childrenPadding [
	"The space in pixels between the children of a composite node and its border"

	^ 10
]

{ #category : 'styling' }
TLBlocNodeElement >> customizeFromNode: aNode [
	"See #customizeFromNode:styleSheet:, with the effective style sheet of the node"

	self customizeFromNode: aNode styleSheet: aNode effectiveStyleSheet
]

{ #category : 'styling' }
TLBlocNodeElement >> customizeFromNode: aNode styleSheet: styleSheet [
	"The style sheet is the effective one of the node, given because merging the style sheets of the parents of a node costs. The colors, the dimension and the shape of the style sheet can depend on the entity of the node: a block, or a gradient for the colors, gives the value of each node. It can be called again when an interaction changed the style: the previous inner border is removed, a composite node is still as big as its children, and a node which takes all the space of its line keeps the height the layout gave it. The border is drawn with the line style of the style sheet, solid by default, half inside and half outside of the edge of the node"

	| previous backgroundColor borderColor |
	previous := dimension.
	self beOutskirtsCentered.
	backgroundColor := self valueOf: #backgroundColor in: styleSheet forNode: aNode.
	self background: backgroundColor.
	shape := self valueOf: #shape in: styleSheet forNode: aNode.
	borderStyle := (styleSheet attributes includesKey: #borderStyle)
		               ifTrue: [ styleSheet borderStyle ]
		               ifFalse: [ TLSolidLineStyle ].
	borderColor := self valueOf: #borderColor in: styleSheet forNode: aNode.
	self border: (borderStyle blocBorderPaint: borderColor width: styleSheet borderWidth).
	self showColors: {
			backgroundColor.
			borderColor }.
	ownDimension := (self valueOf: #width in: styleSheet forNode: aNode) @ (self valueOf: #height in: styleSheet forNode: aNode).
	occupiesMaxSpace := (self valueOf: #takeAllSpace in: styleSheet forNode: aNode) == true.
	self dimension: ((occupiesMaxSpace and: [ previous isNotNil ])
			 ifTrue: [ ownDimension x @ (previous y max: ownDimension y) ]
			 ifFalse: [ ownDimension ]).
	self fitToChildren
]

{ #category : 'layout' }
TLBlocNodeElement >> defineFixedRelativePosition: aCenter [
	"The node keeps this center, in the coordinates of its parent, whatever the layouts do"

	fixedCenter := aCenter.
	self position: aCenter
]

{ #category : 'accessing' }
TLBlocNodeElement >> dimension [
	^ dimension
]

{ #category : 'accessing' }
TLBlocNodeElement >> dimension: aDimension [
	"The dimension of the node, and with it its extent and its outline, where the connections meet the node. A layout changes it for the nodes which take all the space of their line. The triggers of the node follow it, and a trigger stays centered on its anchor"

	dimension := aDimension.
	self extent: aDimension.
	shape ifNotNil: [ self updateOutline ].
	self placeTriggers.
	self isTrigger ifTrue: [ self placeOnItsNode ]
]

{ #category : 'layout' }
TLBlocNodeElement >> encompassingRectangle [
	"The rectangle of the node in the coordinates of its parent"

	^ self measuredBounds position extent: dimension
]

{ #category : 'children' }
TLBlocNodeElement >> fitParentCompositesToTheirChildren [
	"A node moved inside of a composite node, which always fits its children, and so do the composite nodes around that one"

	| composite |
	composite := self parentComposite.
	[ composite isNil ] whileFalse: [
			composite fitToChildrenWhereTheyAre.
			composite := composite parentComposite ]
]

{ #category : 'children' }
TLBlocNodeElement >> fitToChildren [
	"I am as big as my children and the space around them, which is also my padding, and a strip at the top for my label when it is inside of me, and as wide as that label. Their group is placed under the strip, centered when I am wider than they are. Without child I keep the dimension of my style"

	| rectangle padding target |
	childrenGroup ifNil: [ ^ self ].
	fittedHeaderExtent := self headerExtent.
	childrenGroup isEmpty ifTrue: [ ^ self resizeTo: ownDimension ].
	rectangle := childrenGroup localRectangle.
	padding := self childrenPadding.
	self resizeTo: (rectangle extent x max: self headerWidth) + (padding * 2) @ (rectangle extent y + (padding * 2) + self headerHeight).
	target := dimension x - rectangle extent x / 2 - rectangle origin x @ (padding + self headerHeight - rectangle origin y).
	childrenGroup element measuredBounds position = target ifFalse: [ childrenGroup element position: target ]
]

{ #category : 'children' }
TLBlocNodeElement >> fitToChildrenWhenTheHeaderChanged [
	"The label of the strip is measured after the layout: the node makes room for it, once, and does not follow the children which the user moved"

	self headerExtent = fittedHeaderExtent ifFalse: [ self fitToChildren ]
]

{ #category : 'children' }
TLBlocNodeElement >> fitToChildrenWhereTheyAre [
	"I fit my children as #fitToChildren does, but they stay where they are in the view: when fitting moves their group inside of me, I move the opposite way. This is for a child which the user drags, that must stay under the mouse"

	| groupPosition |
	childrenGroup ifNil: [ ^ self ].
	groupPosition := childrenGroup element measuredBounds position.
	self fitToChildren.
	self placeAt: self placement + (groupPosition - childrenGroup element measuredBounds position)
]

{ #category : 'triggers' }
TLBlocNodeElement >> fractionOf: aSide [
	"Where a side lies along its axis, from 0 to 1"

	(#( left top ) includes: aSide) ifTrue: [ ^ 0 ].
	^ aSide = #center
		  ifTrue: [ 0.5 ]
		  ifFalse: [ 1 ]
]

{ #category : 'children' }
TLBlocNodeElement >> headerExtent [
	"The extent of the label in the strip at the top of a composite node, or 0 @ 0 when there is none"

	^ self headerLabel
		  ifNil: [ 0 @ 0 ]
		  ifNotNil: [ :label | label extent ]
]

{ #category : 'children' }
TLBlocNodeElement >> headerHeight [
	"The height of the strip at the top of a composite node, for its label: the label and a gap, or 0 when it has no label in the strip"

	^ self headerLabel
		  ifNil: [ 0 ]
		  ifNotNil: [ :label | label extent y + label gapFromNode ]
]

{ #category : 'children' }
TLBlocNodeElement >> headerLabel [
	"The label which is in the strip at the top of a composite node: the label of a composite node with children displayed, which is at the center of the node. Otherwise nil: the other labels are outside of the node, and a node without children displayed has its label centered over it"

	| label |
	(childrenGroup isNil or: [ childrenGroup isEmpty ]) ifTrue: [ ^ nil ].
	label := self labelElement.
	^ (label isNotNil and: [ label isCenteredOnNode ])
		  ifTrue: [ label ]
		  ifFalse: [ nil ]
]

{ #category : 'children' }
TLBlocNodeElement >> headerOffsetOfLabel [
	"Where the label of the strip is in the node: centered, at the padding from the top"

	^ dimension x - self headerLabel extent x / 2 @ self childrenPadding
]

{ #category : 'children' }
TLBlocNodeElement >> headerWidth [

	^ self headerLabel
		  ifNil: [ 0 ]
		  ifNotNil: [ :label | label extent x ]
]

{ #category : 'accessing' }
TLBlocNodeElement >> height [
	"The height of the node, which is the one of its dimension, as its width"

	^ dimension y
]

{ #category : 'layout' }
TLBlocNodeElement >> incomingAdjacentNodes [
	"The elements of the nodes connected to this node, which the layouts of Telescope ask for, such as the tree layout"

	^ incomingConnections collect: #fromNode
]

{ #category : 'accessing' }
TLBlocNodeElement >> incomingConnections [
	^ incomingConnections
]

{ #category : 'initialization' }
TLBlocNodeElement >> initialize [
	"Labels are drawn outside the node bounds, so the node must not clip its children. A node does not take all the space of its line until its style says so, and has no dimension until it is styled"

	super initialize.
	outgoingConnections := OrderedCollection new.
	incomingConnections := OrderedCollection new.
	occupiesMaxSpace := false.
	dimension := 0 @ 0.
	self clipChildren: false
]

{ #category : 'initialization' }
TLBlocNodeElement >> innerBorder [
	"The second outline of a double border, inside of the first one, or nil for the other line styles"

	^ innerBorder
]

{ #category : 'accessing' }
TLBlocNodeElement >> isNode [
	^ true
]

{ #category : 'triggers' }
TLBlocNodeElement >> isTrigger [
	"A trigger is a small node element on the side of another node, which executes an action when it is clicked"

	^ triggerPosition isNotNil
]

{ #category : 'children' }
TLBlocNodeElement >> labelElement [
	"The label of the node, or nil when it has none"

	^ self children
		  detect: [ :child | child class = TLBlocLabelElement ]
		  ifNone: [ nil ]
]

{ #category : 'accessing' }
TLBlocNodeElement >> occupyMaxSpace [
	"Whether the node takes all the space of its line in a layout, as high as the tallest node of the line: the takeAllSpace of its style"

	^ occupiesMaxSpace
]

{ #category : 'layout' }
TLBlocNodeElement >> outgoingAdjacentNodes [
	"The elements of the nodes this node is connected to, which the layouts of Telescope ask for, such as the tree layout"

	^ outgoingConnections collect: #toNode
]

{ #category : 'accessing' }
TLBlocNodeElement >> outgoingConnections [
	^ outgoingConnections
]

{ #category : 'accessing' }
TLBlocNodeElement >> outline [
	"The Geometry project shape of the node, in the coordinates of the node, or nil when the node has no shape. The Bloc geometry of the node is derived from it, and it knows its intersections with lines"

	^ outline
]

{ #category : 'layout' }
TLBlocNodeElement >> outlineRelativeTo: anAncestor [
	"A copy of the outline of the node, in the coordinates of an ancestor, without moving the outline of the node. A node without a shape has the rectangle of its dimension"

	^ (outline ifNil: [ GRectangle origin: 0 @ 0 corner: dimension ]) translatedCopyBy: (self topLeftRelativeTo: anAncestor)
]

{ #category : 'children' }
TLBlocNodeElement >> parentComposite [
	"The composite node which contains me, or nil when I am not inside of one: my parent is the element of its group of children"

	^ self parent ifNotNil: [ :container |
			  container parent ifNotNil: [ :candidate |
					  (candidate class == TLBlocNodeElement and: [ candidate childrenElement == container ]) ifTrue: [ candidate ] ] ]
]

{ #category : 'triggers' }
TLBlocNodeElement >> placeAsTriggerAt: aTLPosition [
	"I am a trigger of my parent, a node: my center is at the anchor of the position on the border of the parent, the center of its right side for #right. I am placed again when the parent changes its dimension"

	triggerPosition := aTLPosition.
	self placeOnItsNode
]

{ #category : 'layout' }
TLBlocNodeElement >> placeAt: aTopLeft [
	"Places the element by its top left corner, as Bloc does, where #position: places it by its center, as the layouts of Telescope do"

	super position: aTopLeft
]

{ #category : 'triggers' }
TLBlocNodeElement >> placeOnItsNode [

	| owner anchor |
	owner := self parent.
	(triggerPosition isNil or: [ owner isNil ]) ifTrue: [ ^ self ].
	anchor := owner dimension * ((self fractionOf: triggerPosition horizontal) @ (self fractionOf: triggerPosition vertical)).
	self placeAt: anchor - (dimension / 2)
]

{ #category : 'triggers' }
TLBlocNodeElement >> placeTriggers [
	"The triggers follow the dimension of the node"

	self triggerElements do: [ :trigger | trigger placeOnItsNode ]
]

{ #category : 'layout' }
TLBlocNodeElement >> placement [
	"The top left corner of the element, as it was last asked, in the coordinates of its parent"

	^ self measuredBounds position
]

{ #category : 'layout' }
TLBlocNodeElement >> placementCenteredAt: aCenter [
	"The top left corner the element has when it is centered on the given point"

	^ aCenter - (dimension / 2)
]

{ #category : 'layout' }
TLBlocNodeElement >> position: aCenter [
	"The layouts of Telescope place a node by its center, and Bloc places an element by its top left corner. Only the setter is the one of Telescope: Bloc reads #position to draw the element, so it must keep answering the top left corner. A node with a fixed position stays there: the layout counts it to place the others, but does not move it"

	^ super position: (fixedCenter ifNil: [ aCenter ]) - (dimension / 2)
]

{ #category : 'layout' }
TLBlocNodeElement >> rectangleWithLabelRelativeTo: anAncestor [
	"The rectangle of the dimension of the node, in the coordinates of an ancestor, and of its label, which a line should not cross either. The label is placed after it is measured: its place is computed from its size and not read, so that the rectangle is right as soon as the label is measured"

	| topLeft rectangle |
	topLeft := self topLeftRelativeTo: anAncestor.
	rectangle := topLeft extent: dimension.
	^ self labelElement
		  ifNil: [ rectangle ]
		  ifNotNil: [ :nodeLabel | rectangle merge: (topLeft + (nodeLabel offsetForNodeExtent: dimension) extent: nodeLabel extent) ]
]

{ #category : 'layout' }
TLBlocNodeElement >> rectanglesRelativeTo: anOrigin [
	"The rectangles of the node, of its labels and of its children, from the given origin: their union is what a visualization fits in a window"

	| topLeft |
	topLeft := anOrigin + self measuredBounds position.
	^ { (topLeft extent: dimension) } , ((self children reject: [ :child | child == innerBorder ]) flatCollect: [ :child | child rectanglesRelativeTo: topLeft ])
]

{ #category : 'connections' }
TLBlocNodeElement >> registerConnection: aConnectionElement [
	"The connection leaves this node, enters it, or both when it is a loop"

	aConnectionElement fromNode == self ifTrue: [ outgoingConnections add: aConnectionElement ].
	aConnectionElement toNode == self ifTrue: [ incomingConnections add: aConnectionElement ]
]

{ #category : 'composite' }
TLBlocNodeElement >> releaseChildren [
	"The children are not displayed any more: I have the dimension of my style again"

	childrenGroup ifNotNil: [ :group | group element removeFromParent ].
	childrenGroup := nil.
	self resizeTo: ownDimension
]

{ #category : 'initialization' }
TLBlocNodeElement >> replaceLabelWith: aLabelElementOrNil [
	"The label of the node changed with its entity or its style. A label which looks the same is kept as it is: a style change which does not concern it, such as a highlight of the background, does not make the label again"

	| current |
	current := self children
		           detect: [ :child | child class = TLBlocLabelElement ]
		           ifNone: [ nil ].
	(current isNotNil and: [ aLabelElementOrNil isNotNil and: [ current looksLike: aLabelElementOrNil ] ]) ifTrue: [ ^ self ].
	current ifNotNil: #removeFromParent.
	aLabelElementOrNil ifNotNil: [ :label | self addChild: label ]
]

{ #category : 'accessing' }
TLBlocNodeElement >> resizeTo: aDimension [
	"Changes the dimension, and with it the outline where the connections meet the node. Nothing is done when it does not change: a new size asks for a new layout"

	dimension = aDimension ifFalse: [ self dimension: aDimension ]
]

{ #category : 'accessing' }
TLBlocNodeElement >> restoreOriginalDimension [
	"The dimension of the style again, which a layout asks before it is applied again: a composite node is as big as its children"

	childrenGroup
		ifNil: [ self resizeTo: ownDimension ]
		ifNotNil: [ self fitToChildren ]
]

{ #category : 'layout' }
TLBlocNodeElement >> topLeftRelativeTo: anAncestor [
	"The top left corner of the node, in the coordinates of an ancestor: the view, whatever the groups between them"

	| topLeft current |
	topLeft := self measuredBounds position.
	current := self parent.
	[ current isNotNil and: [ current ~~ anAncestor ] ] whileTrue: [
			topLeft := topLeft + current measuredBounds position.
			current := current parent ].
	^ topLeft
]

{ #category : 'triggers' }
TLBlocNodeElement >> triggerElements [
	"The triggers of the node, which are its children"

	^ self children select: [ :child | child class = TLBlocNodeElement and: [ child isTrigger ] ]
]

{ #category : 'connections' }
TLBlocNodeElement >> unregisterConnection: aConnectionElement [
	outgoingConnections remove: aConnectionElement ifAbsent: [  ].
	incomingConnections remove: aConnectionElement ifAbsent: [  ]
]

{ #category : 'initialization' }
TLBlocNodeElement >> updateOutline [
	"The outline and the geometry come from the shape and the dimension. A dimension of 0, which a property such as a number of attributes can give, would make a shape which cannot exist: the outline is at least one pixel wide and high. A double border draws the outline a second time, which is made again too"

	innerBorder ifNotNil: [ :previous | previous removeFromParent ].
	innerBorder := nil.
	outline := shape outlineOfExtent: (dimension max: 1 @ 1).
	self geometry: (outline
			 ifNil: [ BlEmptyGeometry new ]
			 ifNotNil: #asBlocGeometry).
	borderStyle hasParallelLineInBloc ifTrue: [ self addInnerBorderOf: shape ]
]

{ #category : 'styling' }
TLBlocNodeElement >> valueOf: aProperty forNode: aNode [
	"The value of a property of the style sheet of the node, evaluated for the entity of the node"

	^ self valueOf: aProperty in: aNode effectiveStyleSheet forNode: aNode
]

{ #category : 'styling' }
TLBlocNodeElement >> valueOf: aProperty in: aStyleSheet forNode: aNode [
	"The value of a property of a style sheet, which is the effective one of the node, evaluated for the entity of the node. Merging the style sheets of the parents of a node costs, so the one the caller has is given"

	^ aStyleSheet obtainValue: aProperty forEntity: aNode entity inNode: aNode
]

{ #category : 'dragging' }
TLBlocNodeElement >> wasDragged [
	"Whether the user dragged me with the mouse since the last press on me: the click which ends a drag is not for my interactions"

	^ wasDragged ifNil: [ false ]
]

{ #category : 'dragging' }
TLBlocNodeElement >> wasDragged: aBoolean [

	wasDragged := aBoolean
]

{ #category : 'accessing' }
TLBlocNodeElement >> width [
	"The width of the node, which is the one of its dimension: the layouts of Telescope ask it, and a Bloc element has no extent before it is laid out. Bloc advises not to redefine it: the extent of a node is always its dimension, so it does not change what Bloc sees"

	^ dimension x
]
