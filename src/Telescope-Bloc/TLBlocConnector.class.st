"
I am the connector of Telescope to Bloc. I generate a Bloc element for each Telescope drawable of a visualization, and I add them to a TLBlocVisualization, the view of the visualization. I create the node elements with their labels, I let the Telescope layouts place them, and I join the nodes with TLBlocNodeConnection lines, with a head and a label, which I update after each layout. The nodes of a sub-group are moved inside a TLBlocGroupElement, and a TLBlocGroup lets the layouts place the group as one node. When a layout is applied again, for example because the layout changed or because nodes were added, the nodes and the groups which were already placed move smoothly to their new place during #animationDuration, 500 milliseconds by default, slowly at first and at the end (see TLBlocSmoothEasing), and the connections follow them. The nodes which an interaction adds, for example with a click, start from the node of the interaction and slide to their place. The visualization is fitted into its window again when a layout which is applied again moves or adds a node. The first layout is not animated, and a zero duration disables the animation. I open the visualization in a Bloc window: my windows use the default host of Bloc, or the host given with #host:, for example BlHeadlessHost default to open them without a display, as the tests do. The interactions are implemented one kind after the other: for now the mouse over, whose action is executed when the mouse enters the element of a node and reversed when it leaves it, so that actions such as TLConnectAction add and remove connections, and the click, whose action is executed when the element is clicked, so that actions such as TLExpandCollapseNodesAction add and remove nodes. The other interactions and the legends are not implemented yet. The user can drag the nodes: the connections follow them, and a layout which is applied again puts them back, with the animation. The menus of Telescope open at the mouse when a node is clicked with the secondary button, as Bloc elements (see TLBlocMenu). When an interaction changes the style of a node or of a connection, for example to highlight it, its element is made again from the style sheet. Closing a visualization closes its window. The pop up action, which Telescope leaves to its connectors, shows its text in a TLBlocPopUpElement near the node, while the mouse is over it or after a click. The legend of a visualization is made of the entries of Telescope, static or dynamic, as TLBlocLegendElement. The right click interaction executes its action when a node is pressed with the secondary button, and the menu of that node then does not open. The handlers of the interactions of a drawable are remembered: when its interactions change, for example because the node moved to another group, they are made again. The children of a composite node are the group of its node: #define:asParentFor: puts the element of the group inside of the element of the node, and the node is as big as its children each time their layout is applied. Collapsing a composite removes the group of its children. A node has no label element when its style says TLNoNodeLabel. A click, a right click or a menu is for the innermost node under the pointer, and a click which ends the drag of a node is not a click: a composite node does not get the clicks of its children. The moved interaction is executed with the center of the node when the user drops it. The first update after the generation does not apply the layouts again, so it does not put back the nodes which the user dragged. The connections which join the same two nodes are spread on both sides of the line between them (#spreadParallelConnections), so that the Bezier curves do not overlap. The double click is handled like the click, by the innermost node. The drop interaction is executed on the node under the pointer when another node is dropped, with the dropped node as the parameter: the dropped node and the nodes which contain it or which it contains are not a target. The external trigger interactions are executed by #triggerExternal:, given the interaction or its id: something outside of the visualization, such as a button of the application, calls it.
"
Class {
	#name : 'TLBlocConnector',
	#superclass : 'TLViewConnector',
	#instVars : [
		'host',
		'connections',
		'animationDuration',
		'placedElements',
		'animation',
		'animationOrigin',
		'pendingStarts',
		'runningMoves',
		'layoutReapplied',
		'interactionHandlers',
		'generatedInteractions',
		'externalInteractions'
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

{ #category : 'generation - legend' }
TLBlocConnector >> addElementLegendInView: legend [
	"The legend is in the window, not in the view, so that the zoom does not move it"

	self view legend: legend
]

{ #category : 'view' }
TLBlocConnector >> addElementLegendItemInView: legendItem [

	self flag: #TODO
]

{ #category : 'view' }
TLBlocConnector >> addElementNodeInView: element [
	self view addChild: element
]

{ #category : 'generation - interaction' }
TLBlocConnector >> addHandlerOn: anEventClass to: anElement for: aTLDrawable do: aBlock [
	"The handlers of the interactions of a drawable are remembered, to remove them when its interactions change"

	| handler |
	handler := anElement addEventHandlerOn: anEventClass do: aBlock.
	(interactionHandlers at: aTLDrawable ifAbsentPut: [ OrderedCollection new ]) add: anElement -> handler.
	^ handler
]

{ #category : 'accessing' }
TLBlocConnector >> animationDuration [
	"The time the elements take to move to the place a layout gives them, when a layout is applied again. A zero duration places them at once"

	^ animationDuration
]

{ #category : 'accessing' }
TLBlocConnector >> animationDuration: aDuration [

	animationDuration := aDuration
]

{ #category : 'layout' }
TLBlocConnector >> applyLayoutOf: aTLGroup on: group [
	"The layouts of an update, one per group, work on the final places: the groups need the real size of what they contain. Where the items were is remembered, and #startPendingAnimation moves them once the update is done. An item is a node element or a TLBlocGroup. A layout which is applied again, and which moves or adds an item, makes the update fit the visualization into its window. The children of a composite node are in a group: its node is as big as them once they are placed. The group is told that its layout is applied, otherwise the first update after the generation applies it again and puts back the nodes which the user dragged"

	| previousPlacements |
	self settleAnimation.
	previousPlacements := self placementsOfPlacedItemsIn: group.
	aTLGroup layout on: group.
	aTLGroup layoutApplicationDone.
	group do: [ :item | placedElements add: item ].
	(previousPlacements isNotEmpty and: [ group anySatisfy: [ :item | (previousPlacements at: item ifAbsent: [ nil ]) ~= item placement ] ]) ifTrue: [ layoutReapplied := true ].
	self rememberStartsOf: group from: previousPlacements.
	self fitCompositeNodeOf: aTLGroup.
	self updateConnections
]

{ #category : 'layout' }
TLBlocConnector >> centerOf: item [
	"The center of a node element or of a TLBlocGroup, where the layouts of Telescope place it. It is not #center of the rectangle, which rounds it to whole pixels"

	| rectangle |
	rectangle := item encompassingRectangle.
	^ rectangle origin + (rectangle extent / 2)
]

{ #category : 'generation - interaction' }
TLBlocConnector >> closePopUpOf: anElement [
	"Only the pop up shown for the element is closed: another one may have been shown since"

	(TLBlocPopUpElement shownIn: anElement space root) ifNotNil: [ :popUp | popUp owner == anElement ifTrue: [ popUp removeFromParent ] ]
]

{ #category : 'updating - shape' }
TLBlocConnector >> closeVisualization [
	"Closes the window of the visualization"

	view space ifNotNil: [ :space | space close ]
]

{ #category : 'layout' }
TLBlocConnector >> compositeNodeOfGroup: aTLGroup [
	"The composite node whose children are in the group, or nil: the group of a visualization has no parent"

	^ aTLGroup parent ifNotNil: [ :parent |
			  parent isCompositeNode
				  ifTrue: [ parent ]
				  ifFalse: [ nil ] ]
]

{ #category : 'view' }
TLBlocConnector >> configView [
	"The connections follow the nodes the user drags"

	^ TLBlocVisualization new
		  onNodesMovedDo: [ self updateConnections ];
		  yourself
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
	"The node has a label unless its style gives none"

	| blocElement |
	blocElement := TLBlocNodeElement new.
	blocElement customizeFromNode: aNode.
	(self labelElementOf: aNode) ifNotNil: [ :label | blocElement addChild: label ].
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
	"The legend is a box with the elements of its entries, one above the other"

	^ TLBlocLegendElement new
		  entries: legendItems;
		  yourself
]

{ #category : 'generation - interaction' }
TLBlocConnector >> createMenuFor: aTLDrawable [
	"The menu of a drawable opens at the mouse when its element is clicked with the secondary button. The position of the event is the one in the window, where the menu is placed. The press is for the innermost node under the pointer. Telescope fills the menu with the entries of the menu interactions of the drawable. A drawable which has a right click interaction does that instead: its menu only reminds that the right click does something"

	| menu element |
	menu := TLBlocMenu new.
	element := self elementFromTLDrawable: aTLDrawable.
	self
		addHandlerOn: BlMouseDownEvent
		to: element
		for: aTLDrawable
		do: [ :event |
				(event button = BlMouseButton secondary and: [
					 (self event: event isForElement: element) and: [ menu isEmpty not and: [ (aTLDrawable allInteractions anySatisfy: [ :interaction | interaction kind = #rightClick ]) not ] ] ]) ifTrue: [
					menu openIn: element space at: event position ] ].
	^ menu
]

{ #category : 'generation - group' }
TLBlocConnector >> define: parentCompositeElement asParentFor: aGroupOfChildren [
	"The element of the group of the children goes inside of the element of the composite node"

	parentCompositeElement adoptChildren: aGroupOfChildren
]

{ #category : 'generation - legend' }
TLBlocConnector >> dynamicLegendEntry: aDynamicEntry swatchFor: aBlock [
	"An entry with a row for each description of the entry, in the order of the descriptions. The swatch of a row comes from the first node with the description"

	| element |
	element := TLBlocLegendEntryElement new.
	aDynamicEntry obtainAssociations keysAndValuesDo: [ :description :nodes | element addRow: (aBlock value: nodes first) label: description asString ].
	^ element
]

{ #category : 'generation - interaction' }
TLBlocConnector >> event: aMouseEvent isForElement: anElement [
	"The mouse events go up from the element under the pointer to its parents, which are the nodes which contain it. An event is for the nearest node or connection from the element under the pointer: the label of a node is for the node, and the children of a composite node are not for the composite"

	| current |
	current := aMouseEvent target.
	[ current isNotNil ] whileTrue: [
			(current class = TLBlocNodeElement or: [ current class = TLBlocNodeConnection ]) ifTrue: [ ^ current == anElement ].
			current := current parent ].
	^ true
]

{ #category : 'layout' }
TLBlocConnector >> executeAnimatingFrom: anElement do: aBlock [
	"The nodes which the action adds appear where the element is, and slide to the place of the layout"

	animationOrigin := self centerOf: anElement.
	aBlock ensure: [ animationOrigin := nil ]
]

{ #category : 'updating' }
TLBlocConnector >> fitAgainWhenTheNodesAreMeasured [
	"The new nodes have no labels measured yet when the visualization is first fitted. It is fitted again when they are: at the next layout of the view, or when the animation is done, because the nodes are not at their final place before. Nothing happens when the auto fit was turned off in the meantime"

	animation
		ifNil: [ view fitOnNextLayoutIfAutoFit ]
		ifNotNil: [ :current | current onFinishedDo: [ view autoFitOnLayout ifTrue: [ view fitIntoWindow ] ] ]
]

{ #category : 'layout' }
TLBlocConnector >> fitCompositeNodeOf: aTLGroup [
	"A composite node has the size of the group of its children, which a layout has just placed"

	(self compositeNodeOfGroup: aTLGroup) ifNotNil: [ :composite | self elementFromTLDrawable: composite ifPresent: [ :compositeElement | compositeElement fitToChildren ] ifNone: [ ] ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateBasicInteraction: aTLInteraction onNode: aTLNode [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateClickInteraction: aTLClickInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the element of the target is clicked, unless the click ends the drag of the node. The click is for the innermost node under the pointer: a composite node does not get the clicks of its children. The action of a pop up is not executed: a click shows the text near the element, and the next click hides it"

	| element |
	element := self elementFromTLDrawable: aTargetDrawable.
	aTLClickInteraction action isPopUp ifTrue: [
			^ self
				  addHandlerOn: BlClickEvent
				  to: element
				  for: aTargetDrawable
				  do: [ :event | ((self event: event isForElement: element) and: [ element wasDragged not ]) ifTrue: [ self togglePopUpOf: aTLClickInteraction action for: aTargetDrawable ] ] ].
	self
		addHandlerOn: BlClickEvent
		to: element
		for: aTargetDrawable
		do: [ :event |
			((self event: event isForElement: element) and: [ element wasDragged not ]) ifTrue: [
				self executeAnimatingFrom: element do: [ self executeInteraction: aTLClickInteraction forDrawable: aTLDrawable ] ] ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateDoubleClickInteraction: aTLDoubleClickInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the element of the target is double clicked. The double click is for the innermost node under the pointer, like the click"

	| element |
	element := self elementFromTLDrawable: aTargetDrawable.
	self
		addHandlerOn: BlDoubleClickEvent
		to: element
		for: aTargetDrawable
		do: [ :event | (self event: event isForElement: element) ifTrue: [ self executeAnimatingFrom: element do: [ self executeInteraction: aTLDoubleClickInteraction forDrawable: aTLDrawable ] ] ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateDropInteraction: aTLDropInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed with the node which the user dropped on the element of the target, as the parameter"

	self
		addHandlerOn: TLBlocNodeDropEvent
		to: (self elementFromTLDrawable: aTargetDrawable)
		for: aTargetDrawable
		do: [ :event | self executeInteraction: aTLDropInteraction parameter: (self tlDrawableFromElement: event dropped) forDrawable: aTLDrawable ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateExternalTriggerInteraction: anExternalTriggerInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The interaction does not wait for an event of the window: something outside of the visualization, such as a button, asks for it with #triggerExternal:. It is remembered with the drawable it is for"

	(externalInteractions at: aTLDrawable ifAbsentPut: [ OrderedCollection new ]) add: anExternalTriggerInteraction
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateInteractionsOf: aDrawable targetingDrawable: aTargetDrawable [
	"The interactions of the drawable are remembered, to know later whether they changed: a node which moved to another group has the interactions of that group"

	super generateInteractionsOf: aDrawable targetingDrawable: aTargetDrawable.
	generatedInteractions at: aDrawable put: aDrawable allInteractions asArray
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMouseOverInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the mouse enters the element of the target, and reversed when it leaves it. The action of a pop up is not executed: the text is shown near the element while the mouse is over it"

	| element |
	element := self elementFromTLDrawable: aTargetDrawable.
	aTLMouseOverInteraction action isPopUp ifTrue: [
			self
				addHandlerOn: BlMouseEnterEvent
				to: element
				for: aTargetDrawable
				do: [ :event | self showPopUpOf: aTLMouseOverInteraction action for: aTargetDrawable ].
			^ self
				  addHandlerOn: BlMouseLeaveEvent
				  to: element
				  for: aTargetDrawable
				  do: [ :event | self closePopUpOf: element ] ].
	self
		addHandlerOn: BlMouseEnterEvent
		to: element
		for: aTargetDrawable
		do: [ :event | self executeAnimatingFrom: element do: [ self executeRegularInteraction: aTLMouseOverInteraction forDrawable: aTLDrawable ] ].
	self
		addHandlerOn: BlMouseLeaveEvent
		to: element
		for: aTargetDrawable
		do: [ :event | self executeReverseInteraction: aTLMouseOverInteraction forDrawable: aTLDrawable ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMovedInteraction: aTLNodeMovedInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed with the center of the node when the user drops it after dragging it"

	self
		addHandlerOn: TLBlocNodeMovedEvent
		to: (self elementFromTLDrawable: aTargetDrawable)
		for: aTargetDrawable
		do: [ :event | self executeInteraction: aTLNodeMovedInteraction parameter: event position forDrawable: aTLDrawable ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateMultiChoiceMenuInteraction: aTLMultiChoiceMenuInteraction onDrawable: aTLDrawable targeting: aTargetDrawable [
	"An entry of the menu of the drawable opens a submenu with the choices of the interaction. Choosing one executes the action with the target and the choice"

	| menu |
	menu := self menuInteractionByDrawable at: aTLDrawable ifAbsentPut: [ self createMenuFor: aTLDrawable ].
	menu
		add: aTLMultiChoiceMenuInteraction title
		choices: [ aTLMultiChoiceMenuInteraction choicesListForDrawable: aTargetDrawable ]
		display: [ :choice | aTLMultiChoiceMenuInteraction displayBlock value: choice ]
		chosen: [ :index | self executeChoice: index interaction: aTLMultiChoiceMenuInteraction forDrawable: aTargetDrawable ]
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeBackgroundLegendEntry: aTLNodeBackgroundLegendEntry [
	"A row for each description, with the background of the first node which has it"

	^ self dynamicLegendEntry: aTLNodeBackgroundLegendEntry swatchFor: [ :node | TLBlocLegendSwatch color: (self elementFromTLDrawable: node) background paint color ]
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeBorderColorLegendEntry: aTLNodeBorderColorLegendEntry [
	"A row for each description, with the border color of the first node which has it"

	^ self dynamicLegendEntry: aTLNodeBorderColorLegendEntry swatchFor: [ :node | TLBlocLegendSwatch borderColor: (self elementFromTLDrawable: node) border paint color ]
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateNodeShapeLegendEntry: aTLNodeShapeLegendEntry [
	"A row for each description, with the shape and the colors of the first node which has it"

	^ self dynamicLegendEntry: aTLNodeShapeLegendEntry swatchFor: [ :node |
			  | element |
			  element := self elementFromTLDrawable: node.
			  TLBlocLegendSwatch shape: (element valueOf: #shape forNode: node) background: element background paint color border: element border paint color ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generatePopupInteraction: aTLPopupInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	self shouldBeImplemented
]

{ #category : 'generation - interaction' }
TLBlocConnector >> generateRightClickInteraction: aTLRightClickInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	"The action of the interaction is executed when the element of the target is pressed with the secondary button. The press is for the innermost node under the pointer: a composite node does not get the presses on its children"

	| element |
	element := self elementFromTLDrawable: aTargetDrawable.
	self
		addHandlerOn: BlMouseDownEvent
		to: element
		for: aTargetDrawable
		do: [ :event |
				(event button = BlMouseButton secondary and: [ self event: event isForElement: element ]) ifTrue: [
					self executeAnimatingFrom: element do: [ self executeInteraction: aTLRightClickInteraction forDrawable: aTLDrawable ] ] ]
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLBorderColorLegendEntry: aTLBorderColorLegendEntry [

	^ self legendEntryWith: (TLBlocLegendSwatch borderColor: aTLBorderColorLegendEntry color) label: aTLBorderColorLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLBorderShapeLegendEntry: aTLBorderShapeLegendEntry [
	"The shape is only an outline: it is a border shape"

	^ self legendEntryWith: (TLBlocLegendSwatch shape: aTLBorderShapeLegendEntry styleSheet shape background: Color transparent border: Color black) label: aTLBorderShapeLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLColorLegendEntry: aTLColorLegendEntry [

	^ self legendEntryWith: (TLBlocLegendSwatch color: aTLColorLegendEntry color) label: aTLColorLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLGradientLegendEntry: aTLGradientLegendEntry [

	^ self legendEntryWith: (TLBlocLegendSwatch gradient: aTLGradientLegendEntry gradient) label: aTLGradientLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLHeightLegendEntry: aTLHeightLegendEntry [

	^ self legendEntryWith: TLBlocLegendSwatch heightArrow label: aTLHeightLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLStyleSheetLegendEntry: aTLStyleSheetLegendEntry [
	"A line with the color and the width of the style sheet of a connection"

	| styleSheet |
	styleSheet := aTLStyleSheetLegendEntry styleSheet.
	^ self
		  legendEntryWith: (TLBlocLegendSwatch line: styleSheet color width: ((styleSheet attributes includesKey: #width)
					    ifTrue: [ styleSheet width ]
					    ifFalse: [ 2 ]))
		  label: aTLStyleSheetLegendEntry label
]

{ #category : 'generation-legendEntry' }
TLBlocConnector >> generateTLWidthLegendEntry: aTLWidthLegendEntry [

	^ self legendEntryWith: TLBlocLegendSwatch widthArrow label: aTLWidthLegendEntry label
]

{ #category : 'accessing' }
TLBlocConnector >> host: aBlHost [
	"The host of the windows I open, for example BlHeadlessHost default to open them without a display. When nil, the windows use the default host of Bloc"

	host := aBlHost
]

{ #category : 'initialization' }
TLBlocConnector >> initialize [

	super initialize.
	connections := OrderedCollection new.
	placedElements := IdentitySet new.
	pendingStarts := IdentityDictionary new.
	interactionHandlers := IdentityDictionary new.
	generatedInteractions := IdentityDictionary new.
	externalInteractions := IdentityDictionary new.
	layoutReapplied := false.
	animationDuration := 500 milliSeconds
]

{ #category : 'generation - node' }
TLBlocConnector >> labelElementOf: aNode [
	"The label of the node, or nil when its style gives none: Telescope says so with the class TLNoNodeLabel, which is not a text to draw"

	| styleSheet |
	styleSheet := aNode effectiveStyleSheet.
	^ ((styleSheet attributes includesKey: #nodeLabel) and: [ (styleSheet obtainValue: #nodeLabel forEntity: aNode entity inNode: aNode) ~~ TLNoNodeLabel ]) ifTrue: [ TLBlocLabelElement forNode: aNode ]
]

{ #category : 'generation - legend' }
TLBlocConnector >> legendEntryWith: aSwatch label: aString [
	"An entry of one row"

	^ TLBlocLegendEntryElement new
		  addRow: aSwatch label: aString;
		  yourself
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

{ #category : 'updating' }
TLBlocConnector >> pairOf: aConnectionElement [
	"The two nodes of the connection, in an order which does not depend on its direction"

	^ aConnectionElement fromNode identityHash <= aConnectionElement toNode identityHash
		  ifTrue: [ aConnectionElement fromNode -> aConnectionElement toNode ]
		  ifFalse: [ aConnectionElement toNode -> aConnectionElement fromNode ]
]

{ #category : 'updating' }
TLBlocConnector >> parallelConnectionsSpacing [
	"The distance in pixels between the control points of two connections which are next to each other: the curves are half of it apart"

	^ 40
]

{ #category : 'layout' }
TLBlocConnector >> placeElement: anAssociation correspondingToTrigger: aTLShapeTrigger relativeToDrawable: aTLSimpleNode [
	self shouldBeImplemented
]

{ #category : 'layout' }
TLBlocConnector >> placementsOfPlacedItemsIn: group [
	"Where the items are before a layout moves them: the last place asked for, which is where an animation in progress has put them"

	| placements |
	placements := IdentityDictionary new.
	group do: [ :item | (placedElements includes: item) ifTrue: [ placements at: item put: item placement ] ].
	^ placements
]

{ #category : 'layout' }
TLBlocConnector >> rememberStartsOf: group from: previousPlacements [
	"The place where an item was before the update, or the origin of the animation for a new item, which appears centered on it. An item which a layout moves several times in an update keeps the first one"

	group do: [ :item |
		(previousPlacements at: item ifAbsent: [ animationOrigin ifNotNil: [ :origin | item placementCenteredAt: origin ] ]) ifNotNil: [ :start | pendingStarts at: item ifAbsentPut: [ start ] ] ]
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

{ #category : 'generation - group' }
TLBlocConnector >> removeGroup: aTLGroup [
	"The children of a composite node are removed with their group: its node is not as big as them any more"

	| composite |
	(shapeByDrawable includesKey: aTLGroup) ifFalse: [ ^ self ].
	composite := self compositeNodeOfGroup: aTLGroup.
	(self elementFromTLDrawable: aTLGroup) element removeFromParent.
	super removeGroup: aTLGroup.
	composite ifNotNil: [ self elementFromTLDrawable: composite ifPresent: #releaseChildren ifNone: [ ] ]
]

{ #category : 'generation - interaction' }
TLBlocConnector >> removeInteractionHandlersOf: aTLDrawable [

	(interactionHandlers removeKey: aTLDrawable ifAbsent: [ #(  ) ]) do: [ :association | association key removeEventHandler: association value ].
	externalInteractions removeKey: aTLDrawable ifAbsent: [ ].
	self menuInteractionByDrawable removeKey: aTLDrawable ifAbsent: [ ]
]

{ #category : 'removing - legend' }
TLBlocConnector >> removeLegend: aTLLegend [

	self view removeLegend.
	self unregisterShapeForDrawable: aTLLegend
]

{ #category : 'layout' }
TLBlocConnector >> settleAnimation [
	"A layout starts while an animation is in progress: the items go to the place the animation was bringing them to, and where they were is remembered"

	animation ifNil: [ ^ self ].
	animation stop.
	animation := nil.
	runningMoves keysAndValuesDo: [ :item :move |
			pendingStarts at: item ifAbsentPut: [ item placement ].
			item placeAt: move value ].
	runningMoves := nil
]

{ #category : 'generation - interaction' }
TLBlocConnector >> showPopUpOf: aPopUpAction for: aTLDrawable [
	"The text of the action for the entity of the drawable, near the element of the drawable, at the position of the action"

	TLBlocPopUpElement
		showText: (aPopUpAction obtain: aPopUpAction textBlock on: aTLDrawable entity) asString
		near: (self elementFromTLDrawable: aTLDrawable)
		position: (aPopUpAction obtainsPositionFrom: aTLDrawable)
]

{ #category : 'updating' }
TLBlocConnector >> spreadParallelConnections [
	"The connections between the same two nodes, in any direction, are told their offset: a connection alone has none and the others are spread on both sides of the line between the nodes. The sign follows the direction of the connection, to the left of it when it is positive, so that two connections in opposite directions are not on the same side"

	| groups |
	groups := Dictionary new.
	connections do: [ :connection | (groups at: (self pairOf: connection) ifAbsentPut: [ OrderedCollection new ]) add: connection ].
	groups keysAndValuesDo: [ :pair :group |
			group doWithIndex: [ :connection :index |
					| offset |
					offset := group size = 1
						          ifTrue: [ 0 ]
						          ifFalse: [ index - (group size + 1 / 2) * self parallelConnectionsSpacing ].
					connection parallelOffset: (connection fromNode == pair key
							 ifTrue: [ offset ]
							 ifFalse: [ offset negated ]) ] ]
]

{ #category : 'layout' }
TLBlocConnector >> startPendingAnimation [
	"The update is done and the items are at their final place. They go back to where they were, and an animation brings them to their place, slowly at first and at the end, with the connections following them. The new items start from the origin of the animation, if there is one. The places are the top left corners of the elements, so that the nodes of a group, which move with it, do not change where the group goes"

	| moves |
	moves := IdentityDictionary new.
	pendingStarts keysAndValuesDo: [ :item :start |
			| target |
			target := item placement.
			target = start ifFalse: [ moves at: item put: start -> target ] ].
	pendingStarts := IdentityDictionary new.
	(moves isEmpty or: [ animationDuration isZero ]) ifTrue: [ ^ self ].
	moves keysAndValuesDo: [ :item :move | item placeAt: move key ].
	runningMoves := moves.
	animation := BlNumberTransition new
		             from: 0;
		             to: 1;
		             duration: animationDuration;
		             easing: TLBlocSmoothEasing new;
		             onStepDo: [ :progress |
				             moves keysAndValuesDo: [ :item :move | item placeAt: move key + (move value - move key * progress) ].
				             self updateConnections ];
		             yourself.
	view addAnimation: animation
]

{ #category : 'generation - interaction' }
TLBlocConnector >> togglePopUpOf: aPopUpAction for: aTLDrawable [

	| element |
	element := self elementFromTLDrawable: aTLDrawable.
	(TLBlocPopUpElement shownIn: element space root)
		ifNil: [ self showPopUpOf: aPopUpAction for: aTLDrawable ]
		ifNotNil: [ :popUp |
				popUp owner == element
					ifTrue: [ popUp removeFromParent ]
					ifFalse: [ self showPopUpOf: aPopUpAction for: aTLDrawable ] ]
]

{ #category : 'interactions' }
TLBlocConnector >> triggerExternal: anInteractionOrItsId [
	"Executes the action of the external trigger interactions, given or found by their id, on all the drawables they are for. The visualization is updated once, after all the actions. Something outside of the visualization, such as a button of the application, calls it"

	| id groups visualization |
	id := anInteractionOrItsId isString
		      ifTrue: [ anInteractionOrItsId ]
		      ifFalse: [ anInteractionOrItsId triggerId ].
	groups := IdentityDictionary new.
	externalInteractions keysAndValuesDo: [ :drawable :interactions |
		interactions do: [ :interaction | interaction triggerId = id ifTrue: [ (groups at: interaction ifAbsentPut: [ OrderedCollection new ]) add: drawable ] ] ].
	groups ifEmpty: [ ^ self ].
	groups keysAndValuesDo: [ :interaction :drawables |
			visualization := drawables first visualization.
			drawables do: [ :drawable | interaction actionOn: drawable ] ].
	visualization update
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

{ #category : 'updating' }
TLBlocConnector >> updateConnections [
	"The connections join the borders of their nodes, which the layouts have just placed. Those which join the same two nodes are spread first, so that a Bezier curve is an arc for them. The connections with segments go around the nodes in their way"

	| nodeElements |
	self spreadParallelConnections.
	nodeElements := view allChildrenBreadthFirstSelect: [ :element | element class == TLBlocNodeElement ].
	connections do: [ :connection | connection updateAvoiding: (connection obstaclesAmong: nodeElements) ]
]

{ #category : 'updating - shape' }
TLBlocConnector >> updateEdgeOf: aConnection [
	"An interaction changed the style of the connection, for example to highlight it: the element is made again from the style sheet, and the connections are drawn again once the update is done"

	(self elementFromTLDrawable: aConnection) customizeFromConnection: aConnection
]

{ #category : 'updating - shape' }
TLBlocConnector >> updateElementNodeOf: aNode [
	"An interaction changed the style or the entity of the node, for example to highlight it or to move it: the element is made again from the style sheet, and its label follows the entity"

	| element |
	element := self elementFromTLDrawable: aNode.
	element customizeFromNode: aNode.
	element replaceLabelWith: (self labelElementOf: aNode)
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateInteractionsOf: aDrawable [
	"The interactions of a drawable are made again when they are not the ones the handlers were made for, for example when a node moved to another group. An update which does not change them, such as a highlight, leaves the handlers as they are"

	| generated |
	generated := generatedInteractions at: aDrawable ifAbsent: [ ^ self ].
	generated = aDrawable allInteractions asArray ifTrue: [ ^ self ].
	self removeInteractionHandlersOf: aDrawable.
	self generateInteractionsOf: aDrawable targetingDrawable: aDrawable
]

{ #category : 'updating - legend' }
TLBlocConnector >> updateLegend: aTLLegend [
	"The legend is made again when something asked for it, for example when the entries changed: it depends on the nodes, which an update may have changed"

	aTLLegend isUpdateRequired ifFalse: [ ^ self ].
	self removeLegend: aTLLegend.
	self generateLegend: aTLLegend.
	aTLLegend updateDone
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateShapeTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : 'updating' }
TLBlocConnector >> updateViewForVisualization: aTLVisualization [
	"The elements are updated one by one, and the layouts have put them at their final place. The visualization is fitted into its window if a layout was applied again and the auto fit is on, then the items which moved are animated, and the connections have to join the nodes again: some were added or removed, and the nodes have moved"

	| reapplied |
	reapplied := layoutReapplied and: [ view autoFitOnLayout ].
	layoutReapplied := false.
	reapplied ifTrue: [ view fitIntoWindow ].
	self startPendingAnimation.
	reapplied ifTrue: [ self fitAgainWhenTheNodesAreMeasured ].
	self updateConnections
]
