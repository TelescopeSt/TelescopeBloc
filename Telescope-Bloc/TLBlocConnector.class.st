Class {
	#name : #TLBlocConnector,
	#superclass : #TLViewConnector,
	#instVars : [
		'blocVisualization',
		'zoom'
	],
	#category : #'Telescope-Bloc'
}

{ #category : #accessing }
TLBlocConnector class >> priority [
	^ 50
]

{ #category : #zoom }
TLBlocConnector >> adaptZoomFromEvent: aCharacter [
	aCharacter = Character arrowUp
		ifTrue: [ ^ ((1 / self zoomLevel) @ (1 / self zoomLevel)) ].
	aCharacter = Character arrowDown
		ifTrue: [  ^ (self zoomLevel @ self zoomLevel) ]
]

{ #category : #view }
TLBlocConnector >> addElementConnectionInView: element [
	self view addChild: element
]

{ #category : #view }
TLBlocConnector >> addElementInteractionInView: element [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> addElementLegendInView: legend [
	self flag: #TODO
]

{ #category : #view }
TLBlocConnector >> addElementLegendItemInView: legendItem [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> addElementNodeInView: element [
	self view addChild: element
]

{ #category : #layout }
TLBlocConnector >> applyLayoutOf: aTLGroup on: group [
	aTLGroup layout on: group
]

{ #category : #initialization }
TLBlocConnector >> closeVisualization [
	self shouldBeImplemented
]

{ #category : #'generation - connection' }
TLBlocConnector >> createElementConnection: aTLConnection From: fromNode to: toNode [
	^ TLBlocConnectionElement createFrom: fromNode to: toNode
]

{ #category : #'generation - interaction' }
TLBlocConnector >> createElementFromTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : #'generation - legend' }
TLBlocConnector >> createElementLegendItemFrom: aTLLegendItem [
	self shouldBeImplemented
]

{ #category : #'generation - node' }
TLBlocConnector >> createElementNodeFromNode: aNode [
	| blocElement |
	blocElement := TLBlocNodeElement new.
	blocElement customizeFrom: aNode effectiveStyleSheet.
	^ blocElement 
]

{ #category : #'generation - group' }
TLBlocConnector >> createGroup: aTLGroup with: anObject [
	^ anObject 
]

{ #category : #'generation - legend' }
TLBlocConnector >> createLegendFrom: legendItems [
	self flag: #TODO 
]

{ #category : #'generation - interaction' }
TLBlocConnector >> createMenuFor: aTLDrawable [
	self shouldBeImplemented
]

{ #category : #'generation - node' }
TLBlocConnector >> define: parentCompositeElement asParentFor: aCollectionOfChildrenElements [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateBasicInteraction: aTLInteraction onNode: aTLNode [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateClickInteraction: aClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateDoubleClickInteraction: aDoubleClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : #'generation - interactions' }
TLBlocConnector >> generateDropInteraction: aTLDropInteraction onDrawable: aTLSimpleNode targetingDrawable: aTLSimpleNode3 [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateExternalTriggerInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateMouseOverInteraction: aTLMouseOverInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateMovedInteraction: aTLNodeMovedInteraction onDrawable: aDrawable targetingDrawable: aTargetDrawable [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateMultiChoiceMenuInteraction: aTLMultiChoiceMenuInteraction onDrawable: aTLDrawable targeting: anotherDrawable [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateNodeBackgroundLegendEntry: aTLNodeBackgroundLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateNodeBorderLegendEntry: aLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateNodeShapeLegendEntry: aTLNodeShapeLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generatePopupInteraction: aTLPopupInteraction onDrawable: aTLDrawable targetingDrawable: aTargetDrawable [
	self shouldBeImplemented
]

{ #category : #'generation - interaction' }
TLBlocConnector >> generateRightClickInteraction: aRightClickInteraction onDrawable: aTLDrawable targetingDrawable: anObject [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLBorderColorLegendEntry: aTLBorderColorLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLBorderShapeLegendEntry: aTLBorderShapeLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLColorLegendEntry: aTLColorLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLGradientLegendEntry: aTLGradientLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLHeightLegendEntry: aTLHeightLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLStyleSheetLegendEntry: aTLStyleSheetLegendEntry [
	self shouldBeImplemented
]

{ #category : #'generation-legendEntry' }
TLBlocConnector >> generateTLWidthLegendEntry: aTLWidthLegendEntry [
	self shouldBeImplemented
]

{ #category : #initialization }
TLBlocConnector >> image [ priorSource: 16841869
]

{ #category : #opening }
TLBlocConnector >> open: aTLVisualization inWindowSized: aDimension titled: aString [
	self flag: #TODO. "generation of visualization should be done by abstract connector"
	self view: TLBlocVisualization new.
	aTLVisualization generateWith: self.	
	self openInWindow: blocVisualization named: aString  extent: aDimension
]

{ #category : #opening }
TLBlocConnector >> openInWindow: anElement named: aTitleString extent: aPoint [
	"Open a given element in a window of a provided extent and specified title"

	| aSpace |
	aSpace := BlSpace new
		extent: aPoint;
		title: aTitleString.
	aSpace root background: Color white.
	aSpace root addChild: anElement.
	aSpace root
		addEventHandler:
			(BlEventHandler
				on: BlMouseWheelEvent
				do: [ :evt | 
					aSpace root transform
						inherit;
						origin: (BlAffineTransformationPositionOrigin position: evt position x @ evt position y);
						scaleBy: (self adaptZoomFromEvent: evt direction);
						apply ]).
	aSpace show
]

{ #category : #layout }
TLBlocConnector >> placeElement: anAssociation correspondingToTrigger: aTLShapeTrigger relativeToDrawable: aTLSimpleNode [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> removeElementConnectionFromView: element [
	self shouldBeImplemented
]

{ #category : #'drawing - removing' }
TLBlocConnector >> removeElementFromView: element associatedToDrawable: aTLDrawable [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> removeElementLegendItemFromView: element [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> removeElementnteractionFromView: element [
	self shouldBeImplemented
]

{ #category : #'removing - legend' }
TLBlocConnector >> removeLegend: aTLLegend [
	self shouldBeImplemented
]

{ #category : #'updating - shape' }
TLBlocConnector >> update: shape withCompositeLabelShape: aTLCompositeLabelShape [
	self shouldBeImplemented
]

{ #category : #'updating - shape' }
TLBlocConnector >> update: shape withEllipseShape: aTLEllipseShape [
	self shouldBeImplemented
]

{ #category : #'updating - shape' }
TLBlocConnector >> update: shape withLabelShape: aTLLabelShape [
	self shouldBeImplemented
]

{ #category : #'updating - shape' }
TLBlocConnector >> update: shape withRectangleShape: aTLRectangleShape [
	self shouldBeImplemented
]

{ #category : #'updating - connection' }
TLBlocConnector >> updateEdgeOf: aConnection [
	self shouldBeImplemented
]

{ #category : #'updating - node' }
TLBlocConnector >> updateElementNodeOf: aDrawable [
	self shouldBeImplemented
]

{ #category : #'updating - interaction' }
TLBlocConnector >> updateInteractionsOf: aDrawable [
	self shouldBeImplemented
]

{ #category : #'updating - legend' }
TLBlocConnector >> updateLegend: aTLLegend [
	self shouldBeImplemented
]

{ #category : #'updating - interaction' }
TLBlocConnector >> updateShapeTrigger: aTLShapeTrigger [
	self shouldBeImplemented
]

{ #category : #view }
TLBlocConnector >> updateViewForVisualization: aTLVisualization [
	self shouldBeImplemented
]

{ #category : #accessing }
TLBlocConnector >> zoomLevel [
	^ 0.75
]
