"
I test the groups of nodes drawn by the Bloc connector: the nodes of a sub-group are inside the element of the group, the layouts of Telescope place the group as one node, and a node is placed by its center. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorGroupTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorGroupTest >> clickNodeOfEntity: anEntity [

	(connector elementFromTLDrawable: (self nodeOfEntity: anEntity)) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1500 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> groupElement: aName [

	^ (connector elementFromTLDrawable: visualization > aName) element
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> nodeOfEntity: anEntity [

	^ visualization allNodes detect: [ :node | node entity = anEntity ]
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> openGroupsWithMovingNodes [
	"The demo of the nodes which move to the other group when they are clicked: a to d in the first group, e to h in the second one"

	(visualization > #group1)
		layout: TLLinearLayout topToBottom;
		addNodesFromEntities: ($a to: $d);
		addInteraction: (TLMoveConnectableAction destination: visualization > #group2) onClick.
	(visualization > #group2)
		layout: TLLinearLayout topToBottom;
		addNodesFromEntities: ($e to: $h);
		addInteraction: (TLMoveConnectableAction destination: visualization > #group1) onClick.
	visualization layout: TLLinearLayout leftToRight.
	connector open: visualization inWindowSized: 500 @ 400 titled: 'Groups'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> rectangleOfGroup: aName [

	^ (connector elementFromTLDrawable: visualization > aName) encompassingRectangle
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testGradientDemoGeneratesItsTwoGroupsWithTheirColors [

	| colorElements grayElements |
	visualization := TLDemos exampleGradient.
	visualization generator: connector.
	visualization generateWith: connector.
	self assert: connector view content children size equals: 2.
	colorElements := connector view content children first children.
	grayElements := connector view content children last children.
	self assert: colorElements size equals: 60.
	self assert: grayElements size equals: 10.
	self assert: colorElements first background paint color equals: MDLColor red.
	self assert: grayElements first background paint color equals: MDLColor white.
	self assert: grayElements last background paint color equals: MDLColor black
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testGroupHasTheDimensionOfItsNodes [

	| group |
	group := visualization > #first.
	group addNodesFromEntities: (1 to: 3).
	visualization generateWith: connector.
	"Three nodes of 15 pixels with a gap of 15 between them"
	self assert: (connector elementFromTLDrawable: group) dimension equals: 75 @ 15
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testGroupsDoNotOverlapAfterANodeMoved [

	self openGroupsWithMovingNodes.
	self clickNodeOfEntity: $a.
	self deny: ((connector elementFromTLDrawable: visualization > #group1) encompassingRectangle intersects: (connector elementFromTLDrawable: visualization > #group2) encompassingRectangle)
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testGroupsStayNextToEachOtherWhenTheLayoutOfOneChangesWithAnimation [

	| layouts |
	connector animationDuration: 300 milliSeconds.
	layouts := {
		           (TLLinearLayout angle: 90).
		           (TLTreeLayout angle: 180).
		           TLCircularLayout new }.
	(visualization > #group1)
		layout: TLLinearLayout topToBottom;
		addNodesFromEntities: layouts;
		addInteraction: (TLCustomAction block: [ :node | visualization > #group2 layout: node entity ]) onClick.
	(visualization > #group1) styleSheet
		width: 200;
		height: 50.
	(visualization > #group2)
		addNodesFromEntities: (1 to: 30);
		layout: TLCircularLayout.
	visualization layout: TLLinearLayout leftToRight.
	connector open: visualization inWindowSized: 800 @ 600 titled: 'Groups'.
	connector view space settleForDuration: 1 seconds.
	(visualization > #group1) allNodes do: [ :node |
			| left right |
			(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
			connector view space settleForDuration: 1500 milliSeconds.
			left := self rectangleOfGroup: #group1.
			right := self rectangleOfGroup: #group2.
			self deny: (left intersects: right).
			self assert: right left - left right < 20.
			self assert: (left center y - right center y) abs < 5 ]
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodeIsPlacedByItsCenter [

	| tall short |
	tall := visualization addNodeFromEntity: 1.
	tall styleSheet height: 40.
	short := visualization addNodeFromEntity: 2.
	short styleSheet height: 20.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Centers'.
	connector view space settleForDuration: 1 seconds.
	self assert: (connector elementFromTLDrawable: tall) bounds center y closeTo: (connector elementFromTLDrawable: short) bounds center y
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodeKeepsTheBlocMeaningOfItsPosition [
	"Bloc reads the position of an element to draw it, so it must stay the top left corner of the element, whatever the center the layout of Telescope gave"

	| node element |
	node := visualization addNodeFromEntity: 1.
	node styleSheet
		width: 40;
		height: 40.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Position'.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: node.
	self assert: element position equals: element bounds position.
	self assert: element position equals: 0 @ 0
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodeMovedToAnotherGroupIsInsideTheElementOfThatGroup [

	self openGroupsWithMovingNodes.
	self clickNodeOfEntity: $a.
	self assert: (connector elementFromTLDrawable: (self nodeOfEntity: $a)) parent identicalTo: (self groupElement: #group2).
	self assert: (self groupElement: #group1) children size equals: 3.
	self assert: (self groupElement: #group2) children size equals: 5
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodeMovedToAnotherGroupIsLaidOutWithTheNodesOfThatGroup [

	| moved other |
	self openGroupsWithMovingNodes.
	self clickNodeOfEntity: $a.
	moved := (connector elementFromTLDrawable: (self nodeOfEntity: $a)) measuredBounds.
	other := (connector elementFromTLDrawable: (self nodeOfEntity: $e)) measuredBounds.
	self assert: (moved position x - other position x) abs < 0.01.
	self assert: (moved position y - other position y) abs > 1
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodeMovedToAnotherGroupStartsFromWhereItWasWithAnimation [

	| element start |
	connector animationDuration: 2 seconds.
	self openGroupsWithMovingNodes.
	element := connector elementFromTLDrawable: (self nodeOfEntity: $a).
	start := element boundsInSpace center.
	(connector elementFromTLDrawable: (self nodeOfEntity: $a)) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 100 milliSeconds.
	self assert: (element boundsInSpace center - start) r < 40
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodesMovedBackAndForthEndInTheirGroups [

	self openGroupsWithMovingNodes.
	self clickNodeOfEntity: $a.
	self clickNodeOfEntity: $e.
	self clickNodeOfEntity: $a.
	self assert: (connector elementFromTLDrawable: (self nodeOfEntity: $a)) parent identicalTo: (self groupElement: #group1).
	self assert: (connector elementFromTLDrawable: (self nodeOfEntity: $e)) parent identicalTo: (self groupElement: #group1).
	self assert: (self groupElement: #group1) children size equals: 5.
	self assert: (self groupElement: #group2) children size equals: 3
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testNodesOfASubGroupAreInsideTheElementOfTheGroup [

	| group groupElement |
	group := visualization > #first.
	group addNodesFromEntities: (1 to: 3).
	visualization generateWith: connector.
	groupElement := connector elementFromTLDrawable: group.
	self assert: groupElement element children size equals: 3.
	self assert: connector view content children size equals: 1.
	self assert: connector view content children first identicalTo: groupElement element
]

{ #category : 'tests' }
TLBlocConnectorGroupTest >> testTwoSubGroupsDoNotOverlap [

	| first second firstRectangle secondRectangle |
	first := visualization > #first.
	first addNodesFromEntities: (1 to: 3).
	second := visualization > #second.
	second addNodesFromEntities: (1 to: 3).
	visualization generateWith: connector.
	firstRectangle := (connector elementFromTLDrawable: first) encompassingRectangle.
	secondRectangle := (connector elementFromTLDrawable: second) encompassingRectangle.
	self deny: (firstRectangle intersects: secondRectangle)
]
