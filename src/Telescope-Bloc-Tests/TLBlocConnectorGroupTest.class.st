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
TLBlocConnectorGroupTest >> testGradientDemoGeneratesItsTwoGroupsWithTheirColors [

	| colorElements grayElements |
	visualization := TLDemos exampleGradient.
	visualization generator: connector.
	visualization generateWith: connector.
	self assert: connector view children size equals: 2.
	colorElements := connector view children first children.
	grayElements := connector view children last children.
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
TLBlocConnectorGroupTest >> testNodesOfASubGroupAreInsideTheElementOfTheGroup [

	| group groupElement |
	group := visualization > #first.
	group addNodesFromEntities: (1 to: 3).
	visualization generateWith: connector.
	groupElement := connector elementFromTLDrawable: group.
	self assert: groupElement element children size equals: 3.
	self assert: connector view children size equals: 1.
	self assert: connector view children first identicalTo: groupElement element
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
