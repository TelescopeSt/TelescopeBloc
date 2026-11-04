"
I am the connector of Telescope to Bloc. I generate a Bloc element for each Telescope drawable of a visualization, and I add them to a TLBlocVisualization, the view of the visualization. I create the node elements with their labels, I let the Telescope layouts place them, and I join the nodes with TLBlocNodeConnection lines, with a head and a label, which I update after each layout. The nodes of a sub-group are moved inside a TLBlocGroupElement, and a TLBlocGroup lets the layouts place the group as one node. I open the visualization in a Bloc window: my windows use the default host of Bloc, or the host given with #host:, for example BlHeadlessHost default to open them without a display, as the tests do. The interactions are implemented one kind after the other: for now the mouse over, whose action is executed when the mouse enters the element of a node and reversed when it leaves it, so that actions such as TLConnectAction add and remove connections, and the click, whose action is executed when the element is clicked, so that actions such as TLExpandCollapseNodesAction add and remove nodes. The other interactions and the legends are not implemented yet.
"
Class {
	#name : 'TLBlocConnector',
	#superclass : 'TLViewConnector',
	#instVars : [
		'host',
		'connections'
	],
	#category : 'Telescope-Bloc-Core',
	#package : 'Telescope-Bloc',
	#tag : 'Core'
}

{ #category : 'accessing' }
TLBlocConnector class >> priority [
	^ 50
]

{ #category : 'generation - connection' }
TLBlocConnector >> addElementConnectionInView: element [
	self view addChild: element.
	connections add: element.
	element fromNode registerConnection: element.
	element toNode registerConnection: element
]

{ #category : 'view' }
TLBlocConnector >> addElementInteractionInView: element [
	self shouldBeImplemented
]

{ #category : 'view' }
TLBlocConnector >> addElementLegendInView: legend [
	self flag: #TODO
]

{ #category : 'view' }
TLBlocConnector >> addElementLegendItemInView: legendItem [

	self flag: #TODO
]

{ #category : 'view' }
TLBlocConnector >> addElementNodeInView: element [
	self view addChild: element
]

{ #category : 'layout' }
TLBlocConnector >> applyLayoutOf: aTLGroup on: group [

	aTLGroup layout on: group.
	self updateConnections
]

{ #category : 'initialization' }
TLBlocConnector >> closeVisualization [
	self shouldBeImplemented
]

{ #category : 'accessing' }
TLBlocConnector >> configView [

	^ TLBlocVisualization new
]

{ #category : 'accessing' }
TLBlocConnector >> connectionHeadShapesAvailableForConnector [
	"Every shape can be the head of a connection, since the head is drawn from the outline of the shape"

	^ TLSimpleShape allSubclasses
]

{ #category : 'accessing' }
TLBlocConnector >> connections [
	^ connections
]

{ #category : 'generation - connection' }
TLBlocConnector >> createElementConnection: aTLConnection From: fromNode to: toNode [

	^ (TLBlocNodeConnection from: (self elementFromTLDrawable: fromNode) to: (self elementFromTLDrawable: toNode))
		  customizeFromConnection: aTLConnection;
		  yourself
]

{ #category : 'generation - interaction' }
TLBlocConnector >> createElementFromTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : 'generation - legend' }
TLBlocConnector >> createElementLegendItemFrom: aTLLegendItem [

	self flag: #TODO
]

{ #category : 'generation - node' }
TLBlocConnector >> createElementNodeFromNode: aNode [

	| blocElement styleSheet |
	blocElement := TLBlocNodeElement new.
	styleSheet := aNode effectiveStyleSheet.
	blocElement customizeFromNode: aNode.
	(styleSheet attributes includesKey: #nodeLabel) ifTrue: [ blocElement addChild: (TLBlocLabelElement forNode: aNode) ].
	^ blocElement
]

{ #category : 'generation - group' }
TLBlocConnector >> createGroup: aTLGroup with: anObject [
	"The root group stays flat in the view. The nodes of a sub-group are moved inside the element of the group, which is added to the view and placed as one node by the layout of its parent"

	| group |
	aTLGroup parent ifNil: [ ^ anObject ].
	group := TLBlocGroup withElements: anObject.
	self addElementNodeInView: group asBlocElement.
	^ group
]

{ #category : 'generation - legend' }
TLBlocConnector >> createLegendFrom: legendItems [
	self flag: #TODO 
]

{ #category : 'generation - interaction' }
TLBlocConnector >> createMenuFor: aTLDrawable [
	self shouldBeImplemented
]

{ #category : 'generation - node' }
TLBlocConnector >> define: parentCompositeElement asParentFor: aCollectionOfChildrenElements [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateBasicInteraction: aTLInteraction onNode: aTLNode [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateClickInteraction: aTLClickInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the element of the target is clicked"

	(self elementFromTLDrawable: aTargetDrawable) addEventHandlerOn: BlClickEvent do: [ :event | self executeInteraction: aTLClickInteraction forDrawable: aTLDrawable ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateDoubleClickInteraction: aDoubleClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : 'generation - interactions' }
TLBlocConnector >> generateDropInteraction: aTLDropInteraction onDrawable: aTLSimpleNode targetingDrawable: aTLSimpleNode3 [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateExternalTriggerInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMouseOverInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the mouse enters the element of the target, and reversed when it leaves it"

	(self elementFromTLDrawable: aTargetDrawable)
		addEventHandlerOn: BlMouseEnterEvent do: [ :event | self executeRegularInteraction: aTLMouseOverInteraction forDrawable: aTLDrawable ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self executeReverseInteraction: aTLMouseOverInteraction forDrawable: aTLDrawable ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMovedInteraction: aTLNodeMovedInteraction onDrawable: aDrawable targetingDrawable: aTargetDrawable [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMultiChoiceMenuInteraction: aTLMultiChoiceMenuInteraction onDrawable: aTLDrawable targeting: anotherDrawable [
	self shouldBeImplemented
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeBackgroundLegendEntry: aTLNodeBackgroundLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeBorderColorLegendEntry: aLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeShapeLegendEntry: aTLNodeShapeLegendEntry [

	self flag: #TODO
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generatePopupInteraction: aTLPopupInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateRightClickInteraction: aRightClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLBorderColorLegendEntry: aTLBorderColorLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLBorderShapeLegendEntry: aTLBorderShapeLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLColorLegendEntry: aTLColorLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLGradientLegendEntry: aTLGradientLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLHeightLegendEntry: aTLHeightLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLStyleSheetLegendEntry: aTLStyleSheetLegendEntry [

	self flag: #TODO
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLWidthLegendEntry: aTLWidthLegendEntry [

	self flag: #TODO
]

{ #category : 'accessing' }
TLBlocConnector >> host: aBlHost [
	"The host of the windows I open, for example BlHeadlessHost default to open them without a display. When nil, the windows use the default host of Bloc"

	host := aBlHost
]

{ #category : 'initialization' }
TLBlocConnector >> initialize [

	super initialize.
	connections := OrderedCollection new
]

{ #category : 'accessing' }
TLBlocConnector >> nodesShapesAvailableForConnector [
	"The shapes a node can have: all but the ones that are only for connections"

	^ TLSimpleShape allSubclasses select: [ :each | each isAvailableForBlocNode ]
]

{ #category : 'opening' }
TLBlocConnector >> open: aTLVisualization inWindowSized: aDimension titled: aString [

	aTLVisualization generateWith: self.
	self openInWindow: self view named: aString extent: aDimension
]

{ #category : 'opening' }
TLBlocConnector >> openInWindow: anElement named: aTitleString extent: aPoint [
	"Open a given element in a window of a provided extent and specified title"

	| aSpace |
	aSpace := BlSpace new
		          extent: aPoint;
		          title: aTitleString.
	host ifNotNil: [ aSpace host: host ].
	aSpace root background: Color white.
	aSpace root addChild: anElement.
	aSpace show
]

{ #category : 'layout' }
TLBlocConnector >> placeElement: anAssociation correspondingToTrigger: aTLShapeTrigger relativeToDrawable: aTLSimpleNode [
	self shouldBeImplemented
]

{ #category : 'updating' }
TLBlocConnector >> removeElementConnectionFromView: element [
	connections remove: element ifAbsent: [  ].
	element fromNode unregisterConnection: element.
	element toNode unregisterConnection: element.
	element removeFromParent
]

{ #category : 'updating' }
TLBlocConnector >> removeElementFromView: element associatedToDrawable: aTLDrawable [

	element removeFromParent
]

{ #category : 'view' }
TLBlocConnector >> removeElementLegendItemFromView: element [

	self flag: #TODO
]

{ #category : 'view' }
TLBlocConnector >> removeElementnteractionFromView: element [
	self shouldBeImplemented
]

{ #category : 'removing - legend' }
TLBlocConnector >> removeLegend: aTLLegend [

	self flag: #TODO
]

{ #category : 'updating - shape' }
TLBlocConnector >> update: shape withCompositeLabelShape: aTLCompositeLabelShape [
	self shouldBeImplemented
]

{ #category : 'updating - shape' }
TLBlocConnector >> update: shape withEllipseShape: aTLEllipseShape [
	self shouldBeImplemented
]

{ #category : 'updating - shape' }
TLBlocConnector >> update: shape withLabelShape: aTLLabelShape [
	self shouldBeImplemented
]

{ #category : 'updating - shape' }
TLBlocConnector >> update: shape withRectangleShape: aTLRectangleShape [
	self shouldBeImplemented
]

{ #category : 'layout' }
TLBlocConnector >> updateConnections [
	"The connections join the borders of their nodes, which the layouts have just placed"

	connections do: [ :connection | connection update ]
]

{ #category : 'updating' }
TLBlocConnector >> updateEdgeOf: aConnection [
	"The element of a connection is not changed by an update yet, except for the place where it joins its nodes"

	self flag: #TODO
]

{ #category : 'updating' }
TLBlocConnector >> updateElementNodeOf: aDrawable [
	"The element of a node is not changed by an update yet"

	self flag: #TODO
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateInteractionsOf: aDrawable [
	"The handlers of the interactions are added when the element is generated"

	self flag: #TODO
]

{ #category : 'updating - legend' }
TLBlocConnector >> updateLegend: aTLLegend [

	self flag: #TODO
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateShapeTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : 'updating' }
TLBlocConnector >> updateViewForVisualization: aTLVisualization [
	"The elements are updated one by one, but the connections have to join the nodes again: some were added or removed, and the nodes may have moved"

	self updateConnections
]
