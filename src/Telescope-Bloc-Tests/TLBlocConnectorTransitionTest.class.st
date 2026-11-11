Class {
	#name : 'TLBlocConnectorTransitionTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> backgroundOf: aNode [

	^ (connector elementFromTLDrawable: aNode) background paint color
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> connectionElement [

	^ connector view content children detect: [ :child | child class = TLBlocNodeConnection ]
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> dimensionsOf: anElement during: aNumber [
	"The dimensions of the element at each of a number of frames"

	^ (1 to: aNumber) collect: [ :index |
			  connector view space settleForDuration: 20 milliSeconds.
			  anElement dimension ]
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> openCollapsedComposite [
	"Opens the composite node 6, collapsed, whose children are 2 and 3, and which a click expands or collapses. Answers its element"

	| node |
	visualization styleSheet
		nodeLabel: #asString;
		compositeExpandedByDefault: false.
	visualization childrenProperty: [ :number |
			number = 6
				ifTrue: [ #( 2 3 ) ]
				ifFalse: [ #(  ) ] ].
	visualization nodeCreationStrategy beRecursive.
	node := visualization addNodeFromEntity: 6.
	visualization addInteraction: TLExpandCollapseCompositeNodeAction onClick.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Transitions'.
	self settle.
	^ connector elementFromTLDrawable: node
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> openWithChildrenOnClick [
	"Opens the nodes 1 and 2: a click on a node adds a child, the entity multiplied by ten. Answers the first node"

	| nodes |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization addInteraction: (TLExpandCollapseNodesAction property: [ :entity | { (entity * 10) } ]) onClick.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Transitions'.
	self settle.
	^ nodes first
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> openWithHighlight: aBlock [
	"Opens the nodes 1 and 2 connected, where the mouse over a node or over the connection changes the style. Answers the node 1"

	| nodes highlight |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	(nodes first connectTo: nodes second) addInteraction: (TLStyleCustomizationAction custom: aBlock) onMouseOver.
	highlight := (TLStyleCustomizationAction custom: aBlock) onMouseOver.
	visualization addInteraction: highlight.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Transitions'.
	self settle.
	^ nodes first
]

{ #category : 'running' }
TLBlocConnectorTransitionTest >> setUp [

	super setUp.
	connector animationDuration: 300 milliSeconds
]

{ #category : 'helpers' }
TLBlocConnectorTransitionTest >> settle [

	connector view space settleForDuration: 2 seconds
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testCollapsedCompositeShrinksProgressively [

	| composite collapsed expanded dimensions |
	composite := self openCollapsedComposite.
	collapsed := composite dimension.
	composite dispatchEvent: BlClickEvent new.
	self settle.
	expanded := composite dimension.
	composite dispatchEvent: BlClickEvent new.
	self assert: composite dimension equals: expanded.
	dimensions := self dimensionsOf: composite during: 20.
	self settle.
	self assert: composite dimension equals: collapsed.
	self assert: (dimensions anySatisfy: [ :dimension | (dimension x between: collapsed x + 1 and: expanded x - 1) and: [ dimension y between: collapsed y + 1 and: expanded y - 1 ] ])
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testColorOfANodeComesBackProgressivelyWhenTheMouseLeaves [

	| node before |
	node := self openWithHighlight: [ :style | style backgroundColor: Color red ].
	before := self backgroundOf: node.
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseEnterEvent new.
	self settle.
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseLeaveEvent new.
	self assert: (self backgroundOf: node) equals: Color red.
	self settle.
	self assert: (self backgroundOf: node) equals: before
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testColorsChangeAtOnceWithoutAnimation [

	| node |
	connector animationDuration: 0 seconds.
	node := self openWithHighlight: [ :style | style backgroundColor: Color red ].
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseEnterEvent new.
	self assert: (self backgroundOf: node) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testCompositeResizesAtOnceWithoutAnimation [

	| composite collapsed |
	connector animationDuration: 0 seconds.
	composite := self openCollapsedComposite.
	collapsed := composite dimension.
	composite dispatchEvent: BlClickEvent new.
	self assert: composite dimension x > collapsed x
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testExpandedCompositeEndsAsBigAsItsChildren [
	"Fitting it to its children again does not change it"

	| composite expanded |
	composite := self openCollapsedComposite.
	composite dispatchEvent: BlClickEvent new.
	self settle.
	expanded := composite dimension.
	composite fitToChildren.
	self assert: composite dimension equals: expanded
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testExpandedCompositeGrowsProgressively [

	| composite collapsed dimensions |
	composite := self openCollapsedComposite.
	collapsed := composite dimension.
	composite dispatchEvent: BlClickEvent new.
	self assert: composite dimension equals: collapsed.
	dimensions := self dimensionsOf: composite during: 20.
	self settle.
	self assert: (composite dimension x > collapsed x and: [ composite dimension y > collapsed y ]).
	self assert:
		(dimensions anySatisfy: [ :dimension | (dimension x between: collapsed x + 1 and: composite dimension x - 1) and: [ dimension y between: collapsed y + 1 and: composite dimension y - 1 ] ])
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testHighlightColorOfAConnectionChangesProgressively [

	| element before |
	self openWithHighlight: [ :style | style color: Color red ].
	element := self connectionElement.
	before := element border paint color.
	element dispatchEvent: BlMouseEnterEvent new.
	self assert: element border paint color equals: before.
	self settle.
	self assert: element border paint color equals: Color red.
	self assert: element head background paint color equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testHighlightColorOfANodeChangesProgressively [

	| node before |
	node := self openWithHighlight: [ :style | style backgroundColor: Color red ].
	before := self backgroundOf: node.
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseEnterEvent new.
	self assert: (self backgroundOf: node) equals: before.
	self settle.
	self assert: (self backgroundOf: node) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testLeavingDuringTheHighlightGoesBackToTheColorOfTheNode [
	"The mouse leaves before the color reached the one of the highlight: it goes back from where it is"

	| node before |
	node := self openWithHighlight: [ :style | style backgroundColor: Color red ].
	before := self backgroundOf: node.
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseEnterEvent new.
	(connector elementFromTLDrawable: node) dispatchEvent: BlMouseLeaveEvent new.
	self settle.
	self assert: (self backgroundOf: node) equals: before
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testNodeAddedByAnInteractionFadesIn [

	| node added |
	node := self openWithChildrenOnClick.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	added := connector elementFromTLDrawable: (visualization allNodes detect: [ :each | each entity = 10 ]).
	self assert: added opacity < 1.
	self settle.
	self assert: added opacity equals: 1
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testNodesDoNotFadeInWithoutAnimation [

	| node added |
	connector animationDuration: 0 seconds.
	node := self openWithChildrenOnClick.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	added := connector elementFromTLDrawable: (visualization allNodes detect: [ :each | each entity = 10 ]).
	self assert: added opacity equals: 1
]

{ #category : 'tests' }
TLBlocConnectorTransitionTest >> testNodesOfTheOpeningDoNotFadeIn [
	"The whole visualization appears at once when its window opens"

	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Transitions'.
	visualization allNodes do: [ :node | self assert: (connector elementFromTLDrawable: node) opacity equals: 1 ]
]
