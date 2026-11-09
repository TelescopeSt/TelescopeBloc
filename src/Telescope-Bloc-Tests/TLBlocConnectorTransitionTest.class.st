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
