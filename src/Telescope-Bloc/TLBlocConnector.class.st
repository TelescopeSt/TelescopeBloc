"
I am the connector of Telescope to Bloc. I generate a Bloc element for each Telescope drawable of a visualization, and I add them to a TLBlocVisualization, the view of the visualization. I create the node elements with their labels, I let the Telescope layouts place them, and I open the visualization in a Bloc window. The nodes of a sub-group are moved inside a TLBlocGroupElement, and a TLBlocGroup lets the layouts place the group as one node. My windows use the default host of Bloc, or the host given with #host:, for example BlHeadlessHost default to open them without a display, as the tests do. The interactions, the legends and the connections between nodes are not implemented yet.
"
Class {
	#name : 'TLBlocConnector',
	#superclass : 'TLViewConnector',
	#instVars : [
		'host'
	],
	#category : 'Telescope-Bloc-Core',
	#package : 'Telescope-Bloc',
	#tag : 'Core'
}

{ #category : 'accessing' }
TLBlocConnector class >> priority [
	^ 50
]

{ #category : 'view' }
TLBlocConnector >> addElementConnectionInView: element [
	self view addChild: element
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
	aTLGroup layout on: group
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
	"The connections are not implemented yet, so no shape is available for their heads"

	^ #(  )
]

{ #category : 'generation - connection' }
TLBlocConnector >> createElementConnection: aTLConnection From: fromNode to: toNode [
	| blConnection |
	blConnection := TLBlocNodeConnection
		createFrom: (self elementFromTLDrawable: fromNode)
		to: (self elementFromTLDrawable: toNode).
	blConnection customizeFrom: aTLConnection effectiveStyleSheet.
	^ blConnection
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
TLBlocConnector >> generateClickInteraction: aClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
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
TLBlocConnector >> generateMouseOverInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
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

{ #category : 'view' }
TLBlocConnector >> removeElementConnectionFromView: element [
	self shouldBeImplemented
]

{ #category : 'drawing - removing' }
TLBlocConnector >> removeElementFromView: element associatedToDrawable: aTLDrawable [
	self shouldBeImplemented
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

{ #category : 'updating - connection' }
TLBlocConnector >> updateEdgeOf: aConnection [
	self shouldBeImplemented
]

{ #category : 'updating - node' }
TLBlocConnector >> updateElementNodeOf: aDrawable [
	self shouldBeImplemented
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateInteractionsOf: aDrawable [
	self shouldBeImplemented
]

{ #category : 'updating - legend' }
TLBlocConnector >> updateLegend: aTLLegend [

	self flag: #TODO
]

{ #category : 'updating - interaction' }
TLBlocConnector >> updateShapeTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : 'view' }
TLBlocConnector >> updateViewForVisualization: aTLVisualization [
	self shouldBeImplemented
]
