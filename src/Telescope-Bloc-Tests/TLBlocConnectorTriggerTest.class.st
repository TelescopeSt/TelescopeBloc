Class {
	#name : 'TLBlocConnectorTriggerTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> dragFrom: anElement at: aPoint by: aVector [
	"Presses on the element, moves the mouse and releases it, like the user"

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
TLBlocConnectorTriggerTest >> openNodeWithTrigger: aTriggerStyle counting: aCounter [
	"Opens a visualization of the node 1, with a trigger which increments the counter for the node. The style of the trigger is a block, or a symbol. Answers the node"

	| node |
	visualization styleSheet
		width: 40;
		height: 40;
		nodeLabel: #asString.
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: ((TLCustomAction block: [ :target | aCounter at: 1 put: (aCounter at: 1) + 1 ]) withTriggerStyle: aTriggerStyle) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	^ node
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> plainTrigger [

	^ [ :style :element |  ]
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testClickingTheNodeDoesNotExecuteTheActionOfTheTrigger [

	| counter node |
	counter := Array with: 0.
	node := self openNodeWithTrigger: self plainTrigger counting: counter.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: counter first equals: 0
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testClickingTheTriggerDoesNotClickTheNode [
	"The click on the trigger bubbles to the node: it is only for the trigger"

	| nodeCounter triggerCounter node |
	nodeCounter := Array with: 0.
	triggerCounter := Array with: 0.
	visualization styleSheet
		width: 40;
		height: 40.
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: (TLCustomAction block: [ :target | nodeCounter at: 1 put: (nodeCounter at: 1) + 1 ]) onClick.
	visualization addInteraction: ((TLCustomAction block: [ :target | triggerCounter at: 1 put: (triggerCounter at: 1) + 1 ]) withTriggerStyle: self plainTrigger) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	(self triggerElementOf: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: triggerCounter first equals: 1.
	self assert: nodeCounter first equals: 0
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testClickingTheTriggerExecutesTheActionOnTheNode [

	| counter node |
	counter := Array with: 0.
	node := self openNodeWithTrigger: self plainTrigger counting: counter.
	(self triggerElementOf: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 500 milliSeconds.
	self assert: counter first equals: 1
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testClickingTheTriggerOfTheTreeExplorerExpandsTheNode [

	| root count |
	visualization := TLTreeExplorer root: Collection expandProperty: #subclasses.
	visualization generator: connector.
	connector open: visualization inWindowSized: 800 @ 600 titled: 'Tree'.
	connector view space settleForDuration: 2 seconds.
	root := visualization allNodes first.
	count := visualization allNodes size.
	(self triggerElementOf: root) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 2 seconds.
	self assert: visualization allNodes size > count
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testCompositeDefaultCollapseInteractionShowsPlusThenMinus [

	| composite trigger |
	visualization styleSheet
		width: 40;
		height: 30;
		compositeExpandedByDefault: false.
	visualization childrenProperty: [ :number |
			number < 10
				ifTrue: [
						{
							(number * 10 + 1).
							(number * 10 + 2) } ]
				ifFalse: [ #(  ) ] ].
	composite := visualization addNodeFromEntity: 1.
	visualization addCompositeDefaultCollapseInteraction.
	connector open: visualization inWindowSized: 500 @ 300 titled: 'Composite'.
	connector view space settleForDuration: 1 seconds.
	trigger := self triggerElementOf: composite.
	self assert: trigger labelElement labelText equals: '+'.
	trigger dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (self triggerElementOf: composite) labelElement labelText equals: '-'
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testNodeWithAShapeInteractionHasAnElementForItsTrigger [

	| node trigger |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	trigger := self triggerElementOf: node.
	self assert: trigger isNotNil.
	self assert: trigger parent identicalTo: (connector elementFromTLDrawable: node)
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testPressingOnTheTriggerDoesNotDragItAway [

	| node trigger before |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	trigger := self triggerElementOf: node.
	before := trigger position.
	self dragFrom: trigger at: 2 @ 2 by: 60 @ 60.
	self assert: trigger position equals: before
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testRemovingTheShapeInteractionRemovesTheTrigger [

	| node element interaction |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	element := connector elementFromTLDrawable: node.
	interaction := node allInteractions detect: [ :each | each class = TLShapeInteraction ].
	connector removeShapeInteraction: interaction forDrawable: node.
	self assert: (element children select: [ :child | child class = TLBlocNodeElement ]) isEmpty
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTreeExplorerNodesHaveATrigger [

	visualization := TLTreeExplorer root: Collection expandProperty: #subclasses.
	visualization generator: connector.
	connector open: visualization inWindowSized: 800 @ 600 titled: 'Tree'.
	connector view space settleForDuration: 2 seconds.
	self assert: (connector view children select: [ :child | child class = TLBlocNodeElement ]) isNotEmpty.
	self assert:
		((connector view children select: [ :child | child class = TLBlocNodeElement ]) allSatisfy: [ :element | (element children select: [ :child | child class = TLBlocNodeElement ]) size = 1 ])
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerFollowsItsNodeWhenItIsMoved [

	| node element trigger before after |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	element := connector elementFromTLDrawable: node.
	trigger := self triggerElementOf: node.
	before := trigger boundsInSpace origin - element boundsInSpace origin.
	element placeAt: element placement + (50 @ 30).
	connector view space settleForDuration: 500 milliSeconds.
	after := trigger boundsInSpace origin - element boundsInSpace origin.
	self assert: (after - before) abs < (0.01 @ 0.01)
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerHasTheDefaultStyleOfTriggers [
	"Small, round, light blue and without label"

	| node trigger |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	trigger := self triggerElementOf: node.
	self assert: trigger dimension equals: 8 @ 8.
	self assert: trigger background paint color equals: Color lightBlue.
	self assert: trigger labelElement isNil
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerIsAtTheRightOfItsNodeByDefault [
	"Centered on the middle of the right side"

	| node element trigger |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	element := connector elementFromTLDrawable: node.
	trigger := self triggerElementOf: node.
	self assert: trigger boundsInSpace center x closeTo: element boundsInSpace right.
	self assert: trigger boundsInSpace center y closeTo: element boundsInSpace center y
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerIsPartOfTheContentWhichTheViewFits [

	| node element |
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	element := connector elementFromTLDrawable: node.
	self assert: (element rectanglesRelativeTo: 0 @ 0) size >= 2
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerLabelFollowsTheStateOfItsNode [

	| clicks node |
	clicks := Array with: 0.
	visualization styleSheet
		width: 40;
		height: 40.
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: ((TLCustomAction block: [ :target |
				  clicks at: 1 put: (clicks at: 1) + 1.
				  target requireUpdate ]) withTriggerStyle: [ :style :element |
				 style nodeLabel: (clicks first > 0
						  ifTrue: [ '-' ]
						  ifFalse: [ '+' ]) ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	self assert: (self triggerElementOf: node) labelElement labelText equals: '+'.
	(self triggerElementOf: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (self triggerElementOf: node) labelElement labelText equals: '-'
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerPositionOfTheStyleSheetPlacesTheTrigger [

	| node element trigger |
	visualization styleSheet triggerPosition: #top.
	node := self openNodeWithTrigger: self plainTrigger counting: (Array with: 0).
	element := connector elementFromTLDrawable: node.
	trigger := self triggerElementOf: node.
	self assert: trigger boundsInSpace center x closeTo: element boundsInSpace center x.
	self assert: trigger boundsInSpace center y closeTo: element boundsInSpace top
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerStaysOnItsAnchorWhenItsNodeIsResized [
	"A node which takes all the space of its line gets taller: its trigger stays on the middle of its side"

	| elements trigger triggerNodeElement |
	visualization styleSheet
		width: 20;
		height: [ :entity | entity * 10 ];
		takeAllSpace: [ :entity | entity = 1 ].
	visualization layout: ((TLLinearLayout perLine: 2)
			 gap: 10;
			 yourself).
	elements := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization addInteraction: ((TLCustomAction block: [ :target |  ]) withTriggerStyle: self plainTrigger) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	triggerNodeElement := connector elementFromTLDrawable: elements first.
	trigger := self triggerElementOf: elements first.
	self assert: triggerNodeElement dimension y equals: 20.
	self assert: trigger boundsInSpace center y closeTo: triggerNodeElement boundsInSpace center y
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerStaysOnItsAnchorWhenItsStyleChangesItsSize [

	| node element trigger clicks |
	clicks := Array with: 0.
	visualization styleSheet
		width: 40;
		height: 40.
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: ((TLCustomAction block: [ :target |
				  clicks at: 1 put: (clicks at: 1) + 1.
				  target requireUpdate ]) withTriggerStyle: [ :style :element |
				 style
					 width: (clicks first > 0
							  ifTrue: [ 20 ]
							  ifFalse: [ 8 ]);
					 height: (clicks first > 0
							  ifTrue: [ 20 ]
							  ifFalse: [ 8 ]) ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	(self triggerElementOf: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	element := connector elementFromTLDrawable: node.
	trigger := self triggerElementOf: node.
	self assert: trigger dimension equals: 20 @ 20.
	self assert: trigger boundsInSpace center x closeTo: element boundsInSpace right.
	self assert: trigger boundsInSpace center y closeTo: element boundsInSpace center y
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerStyleBlockChangesTheStyleOfTheTrigger [

	| node trigger |
	node := self
		        openNodeWithTrigger: [ :style :element |
				        style
					        backgroundColor: Color red;
					        width: 12;
					        height: 12 ]
		        counting: (Array with: 0).
	trigger := self triggerElementOf: node.
	self assert: trigger background paint color equals: Color red.
	self assert: trigger dimension equals: 12 @ 12
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerStyleIsMadeAgainWhenItsNodeIsUpdated [
	"The style of a trigger can depend on the state of its node"

	| clicks node |
	clicks := Array with: 0.
	visualization styleSheet
		width: 40;
		height: 40.
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: ((TLCustomAction block: [ :target |
				  clicks at: 1 put: (clicks at: 1) + 1.
				  target requireUpdate ]) withTriggerStyle: [ :style :element |
				 style backgroundColor: (clicks first > 0
						  ifTrue: [ Color blue ]
						  ifFalse: [ Color red ]) ]) onClick.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Trigger'.
	connector view space settleForDuration: 1 seconds.
	self assert: (self triggerElementOf: node) background paint color equals: Color red.
	(self triggerElementOf: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 1 seconds.
	self assert: (self triggerElementOf: node) background paint color equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> testTriggerWhoseStyleHasALabelShowsIt [

	| node trigger |
	node := self openNodeWithTrigger: [ :style :element | style nodeLabel: '+' ] counting: (Array with: 0).
	trigger := self triggerElementOf: node.
	self assert: trigger labelElement isNotNil.
	self assert: trigger labelElement labelText equals: '+'
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> triggerElementOf: aNode [
	"The element of the trigger of the first shape interaction of the node"

	| interaction |
	interaction := aNode allInteractions detect: [ :each | each class = TLShapeInteraction ].
	^ connector elementFromTLDrawable: (connector findTriggerFor: interaction forDrawable: aNode)
]

{ #category : 'tests' }
TLBlocConnectorTriggerTest >> triggerOf: aNode [

	| interaction |
	interaction := aNode allInteractions detect: [ :each | each class = TLShapeInteraction ].
	^ connector findTriggerFor: interaction forDrawable: aNode
]
