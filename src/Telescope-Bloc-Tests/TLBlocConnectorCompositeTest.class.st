Class {
	#name : 'TLBlocConnectorCompositeTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> countClicksOfEntities: someEntities [
	"Opens the composites 30 > 6 > 2 and 3, 5, where a click on the nodes of the given entities increments their own counter. Answers a dictionary of the counters"

	| counters |
	counters := Dictionary new.
	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: true.
	visualization addNodeFromEntity: 30.
	someEntities do: [ :entity |
			counters at: entity put: 0.
			(self nodeOfEntity: entity) addInteraction: (TLCustomAction block: [ :node | counters at: entity put: (counters at: entity) + 1 ]) onClick ].
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	^ counters
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> dragFrom: anElement at: aPoint by: aVector [
	"Presses on the element, moves the mouse and releases it, like the user. The positions are the ones of the window"

	| root start |
	root := connector view space root.
	start := anElement boundsInSpace origin + aPoint.
	anElement fireEvent: (BlMouseDownEvent new
			 position: start;
			 screenPosition: start;
			 button: BlMouseButton primary;
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: start + (aVector / 2);
			 screenPosition: start + (aVector / 2);
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: start + aVector;
			 screenPosition: start + aVector;
			 yourself).
	root fireEvent: (BlMouseUpEvent new
			 position: start + aVector;
			 screenPosition: start + aVector;
			 button: BlMouseButton primary;
			 yourself).
	connector view space settleForDuration: 500 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> elementOfEntity: anEntity [

	^ connector elementFromTLDrawable: (self nodeOfEntity: anEntity)
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> labelRectangleOfEntity: anEntity [

	| label |
	label := (self elementOfEntity: anEntity) children detect: [ :child | child class = TLBlocLabelElement ].
	^ label boundsInSpace asRectangle
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> nodeOfEntity: anEntity [

	^ visualization allNodesRecursively detect: [ :node | node entity = anEntity ]
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> openCompositeAndASiblingWithDropRecorder: aCollection [
	"The composite node 30 and the node 7 are in the visualization, and the composite is the only one which has a drop interaction, which records the entity of the dropped node"

	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: true.
	(visualization addNodeFromEntity: 30) addInteraction: (TLCustomWithParameterAction block: [ :target :dropped | aCollection add: dropped entity ]) onDrop.
	visualization addNodeFromEntity: 7.
	connector open: visualization inWindowSized: 800 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> openWithComposite: anEntity expanded: aBoolean [

	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: aBoolean.
	visualization addNodeFromEntity: anEntity.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> openWithComposite: anEntity expanded: aBoolean labelPosition: aPosition [
	"The labels of all the nodes are at the position, and the label of the composite 6 is long"

	self prepareComposites.
	visualization styleSheet
		compositeExpandedByDefault: aBoolean;
		nodeLabelPosition: aPosition;
		nodeLabel: [ :number |
				number = 6
					ifTrue: [ 'A composite with a long label' ]
					ifFalse: [ number asString ] ].
	visualization addNodeFromEntity: anEntity.
	connector open: visualization inWindowSized: 800 @ 600 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> prepareComposites [
	"The entity 30 has the children 6 and 5, and 6 has the children 2 and 3: the nodes of the other entities have no child. Telescope gives the same property to the children"

	visualization styleSheet
		nodeLabel: #asString;
		width: 40;
		height: 40.
	visualization childrenProperty: [ :number |
			number = 30
				ifTrue: [ #( 6 5 ) ]
				ifFalse: [
						number = 6
							ifTrue: [ #( 2 3 ) ]
							ifFalse: [ #(  ) ] ] ].
	visualization nodeCreationStrategy beRecursive
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> rectangleOfEntity: anEntity [

	^ (self elementOfEntity: anEntity) boundsInSpace asRectangle
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testChildrenAreCenteredWhenTheInsideLabelMakesTheCompositeWider [

	| composite children |
	self openWithComposite: 6 expanded: true labelPosition: #inside.
	composite := self rectangleOfEntity: 6.
	children := (self rectangleOfEntity: 2) merge: (self rectangleOfEntity: 3).
	self assert: children center x closeTo: composite center x
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testChildrenFollowTheChildrenLayout [

	| first second |
	self prepareComposites.
	visualization styleSheet childrenLayout: TLLinearLayout topToBottom.
	visualization styleSheet compositeExpandedByDefault: true.
	visualization addNodeFromEntity: 6.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	first := self rectangleOfEntity: 2.
	second := self rectangleOfEntity: 3.
	self assert: (first left - second left) abs < 1.
	self assert: (first top - second top) abs > 10
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testChildrenOfACompositeAreInsideItsElement [

	| composite |
	self openWithComposite: 6 expanded: true.
	composite := self elementOfEntity: 6.
	self assert: composite childrenElement isNotNil.
	self assert: composite childrenElement parent identicalTo: composite.
	#( 2 3 ) do: [ :child | self assert: (self elementOfEntity: child) parent identicalTo: composite childrenElement ]
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickAfterADragIsAClickAgainAfterThePress [

	| counters child |
	counters := self countClicksOfEntities: #( 2 ).
	child := self elementOfEntity: 2.
	self dragFrom: child at: 3 @ 3 by: 20 @ 20.
	self dragFrom: child at: 3 @ 3 by: 0 @ 0.
	child fireEvent: BlClickEvent new.
	self assert: (counters at: 2) equals: 1
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickEndingTheDragOfAChildDoesNotClickItsComposite [
	"The click which ends a drag is not a click"

	| counters child |
	counters := self countClicksOfEntities: #( 6 2 ).
	child := self elementOfEntity: 2.
	self dragFrom: child at: 3 @ 3 by: 20 @ 20.
	child fireEvent: BlClickEvent new.
	self assert: (counters at: 2) equals: 0.
	self assert: (counters at: 6) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickOnAChildWithoutInteractionDoesNotClickItsParents [

	| counters |
	counters := self countClicksOfEntities: #( 30 6 ).
	(self elementOfEntity: 2) fireEvent: BlClickEvent new.
	self assert: (counters at: 6) equals: 0.
	self assert: (counters at: 30) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickOnAnInnerCompositeDoesNotClickItsParent [
	"The click is for the innermost node under the pointer: it does not go through the nodes which contain it"

	| counters |
	counters := self countClicksOfEntities: #( 30 6 ).
	(self elementOfEntity: 6) fireEvent: BlClickEvent new.
	self assert: (counters at: 6) equals: 1.
	self assert: (counters at: 30) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickOnTheLabelOfANodeIsForThatNode [
	"The label is an element of the node: the click on it is the click of the node, and only of it"

	| counters |
	counters := self countClicksOfEntities: #( 30 6 ).
	(self elementOfEntity: 6) children last fireEvent: BlClickEvent new.
	self assert: (counters at: 6) equals: 1.
	self assert: (counters at: 30) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickOnTheParentStillClicksIt [

	| counters |
	counters := self countClicksOfEntities: #( 30 6 ).
	(self elementOfEntity: 30) fireEvent: BlClickEvent new.
	self assert: (counters at: 30) equals: 1.
	self assert: (counters at: 6) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testClickingExpandsAndCollapsesAComposite [

	| composite |
	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: false.
	visualization addNodeFromEntity: 6.
	visualization addInteraction: TLExpandCollapseCompositeNodeAction onCompositeNodeWithChildren onClick.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	composite := self elementOfEntity: 6.
	composite dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: composite childrenElement isNotNil.
	self assert: composite extent > (40 @ 40).
	self assert: (self elementOfEntity: 2) parent identicalTo: composite childrenElement.
	composite dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: composite childrenElement isNil.
	self assert: composite extent equals: 40 @ 40
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testCollapsedCompositeHasNoChildrenElement [

	self openWithComposite: 6 expanded: false.
	self assert: (self elementOfEntity: 6) childrenElement isNil.
	self assert: (self elementOfEntity: 6) extent equals: 40 @ 40
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testCompositeIsAsWideAsItsInsideLabel [
	"The label is longer than the children"

	self openWithComposite: 6 expanded: true labelPosition: #inside.
	self assert: (self rectangleOfEntity: 6) width >= ((self labelRectangleOfEntity: 6) width + (10 * connector view zoom)).
	self assert: ((self rectangleOfEntity: 6) containsRect: ((self rectangleOfEntity: 2) merge: (self rectangleOfEntity: 3)))
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testCompositeIsBiggerThanItsChildren [

	| composite children |
	self openWithComposite: 6 expanded: true.
	composite := self rectangleOfEntity: 6.
	children := (self rectangleOfEntity: 2) merge: (self rectangleOfEntity: 3).
	self assert: (composite containsRect: children).
	self assert: children left - composite left >= 5.
	self assert: composite right - children right >= 5.
	self assert: children top - composite top >= 5.
	self assert: composite bottom - children bottom >= 5
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testCompositeWithoutChildrenHasTheDimensionOfItsStyle [

	self openWithComposite: 2 expanded: true.
	self assert: (self elementOfEntity: 2) extent equals: 40 @ 40.
	self assert: (self elementOfEntity: 2) childrenElement isNil
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testCompositesCanBeNested [

	| inner outer |
	self openWithComposite: 30 expanded: true.
	outer := self elementOfEntity: 30.
	inner := self elementOfEntity: 6.
	self assert: inner parent identicalTo: outer childrenElement.
	self assert: (self elementOfEntity: 2) parent identicalTo: inner childrenElement.
	self assert: ((self rectangleOfEntity: 30) containsRect: (self rectangleOfEntity: 6)).
	self assert: ((self rectangleOfEntity: 6) containsRect: (self rectangleOfEntity: 2))
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testConnectionBetweenChildrenJoinsThemInsideTheComposite [

	| composite connection |
	self openWithComposite: 6 expanded: true.
	(self nodeOfEntity: 2) connectTo: (self nodeOfEntity: 3).
	visualization update.
	connector view space settleForDuration: 1 seconds.
	connection := connector connections first.
	self deny: connection start equals: connection end.
	self assert: connection measuredBounds position x >= (self elementOfEntity: 6) measuredBounds position x
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testDraggingAChildDoesNotMoveItsComposite [

	| composite before |
	self openWithComposite: 6 expanded: true.
	composite := self elementOfEntity: 6.
	before := self rectangleOfEntity: 6.
	self dragFrom: (self elementOfEntity: 2) at: 3 @ 3 by: 20 @ 20.
	self assert: (self rectangleOfEntity: 6) equals: before
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testDraggingACompositeMovesItsChildren [

	| before |
	self openWithComposite: 6 expanded: true.
	before := self rectangleOfEntity: 2.
	self dragFrom: (self elementOfEntity: 6) at: 3 @ 3 by: 40 @ 30.
	self assert: ((self rectangleOfEntity: 2) origin - before origin - (40 @ 30)) abs < (1 @ 1)
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testExpandingACompositeWithAnInsideLabelMakesRoomForTheLabel [

	| composite |
	self prepareComposites.
	visualization styleSheet
		compositeExpandedByDefault: false;
		nodeLabelPosition: #inside.
	visualization addNodeFromEntity: 6.
	visualization addInteraction: TLExpandCollapseCompositeNodeAction onCompositeNodeWithChildren onClick.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	composite := self elementOfEntity: 6.
	composite dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (self labelRectangleOfEntity: 6) bottom <= (self rectangleOfEntity: 2) top.
	composite dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (self labelRectangleOfEntity: 6) center closeTo: (self rectangleOfEntity: 6) center
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACollapsedCompositeIsCenteredOverIt [

	self openWithComposite: 6 expanded: false labelPosition: #inside.
	self assert: (self labelRectangleOfEntity: 6) center closeTo: (self rectangleOfEntity: 6) center
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACompositeDoesNotOverlapItsChildrenWhenNested [

	self openWithComposite: 30 expanded: true labelPosition: #inside.
	self assert: (self labelRectangleOfEntity: 30) bottom <= (self rectangleOfEntity: 6) top.
	self assert: (self labelRectangleOfEntity: 30) bottom <= (self rectangleOfEntity: 5) top.
	self assert: (self labelRectangleOfEntity: 6) bottom <= (self rectangleOfEntity: 2) top
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACompositeIsAboveItsChildren [

	self openWithComposite: 6 expanded: true labelPosition: #inside.
	self assert: (self labelRectangleOfEntity: 6) bottom <= (self rectangleOfEntity: 2) top.
	self assert: (self labelRectangleOfEntity: 6) bottom <= (self rectangleOfEntity: 3) top
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACompositeIsCenteredAtItsTop [

	| composite label zoom |
	self openWithComposite: 6 expanded: true labelPosition: #inside.
	zoom := connector view zoom.
	composite := self rectangleOfEntity: 6.
	label := self labelRectangleOfEntity: 6.
	self assert: label center x closeTo: composite center x.
	self assert: label top - composite top closeTo: 10 * zoom
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACompositeIsInsideItsBorder [

	self openWithComposite: 6 expanded: true labelPosition: #inside.
	self assert: ((self rectangleOfEntity: 6) containsRect: (self labelRectangleOfEntity: 6))
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfACompositeStaysWhereItIsOnceSettled [

	| before |
	self openWithComposite: 6 expanded: true labelPosition: #inside.
	before := {
		          (self rectangleOfEntity: 6).
		          (self labelRectangleOfEntity: 6).
		          (self rectangleOfEntity: 2) }.
	connector view space settleForDuration: 1 seconds.
	self
		assert: {
				(self rectangleOfEntity: 6).
				(self labelRectangleOfEntity: 6).
				(self rectangleOfEntity: 2) }
		equals: before
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testInsideLabelOfALeafNodeIsCenteredOverIt [

	self openWithComposite: 6 expanded: true labelPosition: #inside.
	self assert: (self labelRectangleOfEntity: 2) center closeTo: (self rectangleOfEntity: 2) center
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testLabelBelowACompositeLeavesNoStripAtItsTop [

	| composite children |
	self openWithComposite: 6 expanded: true labelPosition: #bottom.
	composite := self rectangleOfEntity: 6.
	children := (self rectangleOfEntity: 2) merge: (self rectangleOfEntity: 3).
	self assert: children top - composite top closeTo: 10 * connector view zoom.
	self assert: (self labelRectangleOfEntity: 6) top >= composite bottom
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testMovingAChildInsideItsCompositeIsNotADropOnTheComposite [

	| drops |
	drops := OrderedCollection new.
	self openCompositeAndASiblingWithDropRecorder: drops.
	self dragFrom: (self elementOfEntity: 2) at: 3 @ 3 by: 10 @ 10.
	self assertEmpty: drops
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testNodeDroppedOnAChildIsNotGivenToTheComposite [
	"The innermost node under the pointer is the target"

	| drops sibling root start target child |
	drops := OrderedCollection new.
	self openCompositeAndASiblingWithDropRecorder: drops.
	sibling := visualization nodes detect: [ :node | node entity = 7 ].
	child := self elementOfEntity: 2.
	root := connector view space root.
	start := (connector elementFromTLDrawable: sibling) boundsInSpace center.
	target := child boundsInSpace center.
	(connector elementFromTLDrawable: sibling) fireEvent: (BlMouseDownEvent new
			 position: start;
			 screenPosition: start;
			 button: BlMouseButton primary;
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: start + target / 2;
			 screenPosition: start + target / 2;
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: target;
			 screenPosition: target;
			 yourself).
	root fireEvent: (BlMouseUpEvent new
			 position: target;
			 screenPosition: target;
			 button: BlMouseButton primary;
			 yourself).
	connector view space settleForDuration: 500 milliSeconds.
	self assertEmpty: drops
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testNodeDroppedOnTheAreaOfACompositeIsGivenToTheComposite [
	"The pointer is over the composite, and not over one of its children"

	| drops sibling root start target composite |
	drops := OrderedCollection new.
	self openCompositeAndASiblingWithDropRecorder: drops.
	sibling := visualization nodes detect: [ :node | node entity = 7 ].
	composite := connector elementFromTLDrawable: (visualization nodes detect: [ :node | node entity = 30 ]).
	root := connector view space root.
	start := (connector elementFromTLDrawable: sibling) boundsInSpace center.
	target := composite boundsInSpace origin + (3 @ 3).
	(connector elementFromTLDrawable: sibling) fireEvent: (BlMouseDownEvent new
			 position: start;
			 screenPosition: start;
			 button: BlMouseButton primary;
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: start + target / 2;
			 screenPosition: start + target / 2;
			 yourself).
	root fireEvent: (BlMouseMoveEvent new
			 position: target;
			 screenPosition: target;
			 yourself).
	root fireEvent: (BlMouseUpEvent new
			 position: target;
			 screenPosition: target;
			 button: BlMouseButton primary;
			 yourself).
	connector view space settleForDuration: 500 milliSeconds.
	self assert: drops asArray equals: #( 7 )
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testRightClickOnAnInnerCompositeDoesNotRightClickItsParent [

	| counters |
	counters := Dictionary new.
	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: true.
	visualization addNodeFromEntity: 30.
	#( 30 6 ) do: [ :entity |
			counters at: entity put: 0.
			(self nodeOfEntity: entity) addInteraction: (TLCustomAction block: [ :node | counters at: entity put: (counters at: entity) + 1 ]) onRightClick ].
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	(self elementOfEntity: 6) fireEvent: (BlMouseDownEvent new
			 position: 5 @ 5;
			 screenPosition: 5 @ 5;
			 button: BlMouseButton secondary;
			 yourself).
	self assert: (counters at: 6) equals: 1.
	self assert: (counters at: 30) equals: 0
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testSegmentsConnectionOfCompositeChildrenIsNotBlockedByTheirComposite [
	"The composite which contains both nodes is not an obstacle"

	| connection element |
	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: true.
	visualization addNodeFromEntity: 6.
	connection := (self nodeOfEntity: 2) connectTo: (self nodeOfEntity: 3).
	connection styleSheet curveStyle: TLSegmentsCurve.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: connection.
	self assert: element route points size equals: 4.
	self assert: element route start x equals: element route end x
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testTwoCompositesDoNotOverlap [
	"Two nodes of the visualization, the first one with children: the layout of the visualization places them by their size"

	| big small |
	self prepareComposites.
	visualization styleSheet compositeExpandedByDefault: true.
	big := visualization addNodeFromEntity: 30.
	small := visualization addNodeFromEntity: 6.
	connector open: visualization inWindowSized: 600 @ 500 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	self deny: ((connector elementFromTLDrawable: big) boundsInSpace asRectangle intersects: (connector elementFromTLDrawable: small) boundsInSpace asRectangle)
]

{ #category : 'tests' }
TLBlocConnectorCompositeTest >> testViewContentIncludesTheChildrenOfAComposite [

	| child childRectangle |
	self openWithComposite: 6 expanded: true.
	child := self elementOfEntity: 2.
	childRectangle := (child topLeftRelativeTo: connector view) extent: child extent.
	self assert: (connector view contentRectangle containsRect: childRectangle)
]
