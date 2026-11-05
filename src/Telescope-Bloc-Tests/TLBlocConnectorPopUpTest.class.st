Class {
	#name : 'TLBlocConnectorPopUpTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> demoNode: aGroupName at: anEntity [

	^ (visualization > aGroupName) allNodes detect: [ :node | node entity = anEntity ]
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> mouseEnter: aNode [

	(connector elementFromTLDrawable: aNode) dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 300 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> mouseLeave: aNode [

	(connector elementFromTLDrawable: aNode) dispatchEvent: BlMouseLeaveEvent new.
	connector view space settleForDuration: 300 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> nodeRectangleInWindow: aNode [

	^ (connector elementFromTLDrawable: aNode) boundsInSpace asRectangle
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> openNodeWith: anInteraction [

	| node |
	node := visualization addNodeFromEntity: 1.
	visualization addInteraction: anInteraction.
	connector open: visualization inWindowSized: 400 @ 400 titled: 'Pop up'.
	connector view space settleForDuration: 1 seconds.
	^ node
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> openNodeWithPopUp: aPosition [
	"Opens a visualization of a node, whose pop up says hello: it is placed at the position, or at the default one when it is nil. Answers the node"

	| action |
	action := TLPopUpAction text: [ :entity | 'Hello ' , entity asString ] position: aPosition.
	^ self openNodeWith: action onMouseOver
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> openPopUpDemo [

	visualization := TLDemos examplePopUp.
	visualization generator: connector.
	connector open: visualization inWindowSized: 900 @ 600 titled: 'Pop up'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> popUpRectangle [

	^ self popUps first boundsInSpace asRectangle
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> popUps [

	^ connector view space root children select: [ :child | child class = TLBlocPopUpElement ]
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testClickShowsThePopUpAndASecondClickHidesIt [

	| node |
	node := self openNodeWith: (TLPopUpAction text: [ :entity | 'Hello ' , entity asString ]) onClick.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds.
	self assert: self popUps size equals: 1.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds.
	self assertEmpty: self popUps
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testEachLineOfTheTextIsALine [

	| node |
	node := self openNodeWith: (TLPopUpAction text: [ :entity | 'first' , (String with: Character cr) , 'second' ]) onMouseOver.
	self mouseEnter: node.
	self assert: self popUps first lines asArray equals: #( 'first' 'second' )
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testMouseLeavingRemovesThePopUp [

	| node |
	node := self openNodeWithPopUp: nil.
	self mouseEnter: node.
	self mouseLeave: node.
	self assertEmpty: self popUps
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testMouseOverShowsTheTextOfTheEntity [

	| node |
	node := self openNodeWithPopUp: nil.
	self mouseEnter: node.
	self assert: self popUps size equals: 1.
	self assert: self popUps first lines asArray equals: #( 'Hello 1' )
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testOnlyOnePopUpIsShownAtATime [

	| nodes |
	nodes := (1 to: 2) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization addInteraction: (TLPopUpAction text: [ :entity | 'Hello ' , entity asString ]) onMouseOver.
	connector open: visualization inWindowSized: 400 @ 400 titled: 'Pop up'.
	connector view space settleForDuration: 1 seconds.
	self mouseEnter: nodes first.
	self mouseEnter: nodes last.
	self assert: self popUps size equals: 1.
	self assert: self popUps first lines asArray equals: #( 'Hello 2' )
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpDemoHasOneGroupForTheMouseOverAndOneForTheClick [

	self openPopUpDemo.
	self assert: (visualization > #mouseOver) allNodes size equals: 9.
	self assert: (visualization > #click) allNodes size equals: 9
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpDemoMouseOverDoesNothingInTheSecondGroupAndClickDoesNothingInTheFirst [

	| node |
	self openPopUpDemo.
	self mouseEnter: (self demoNode: #click at: #top -> #left).
	self assertEmpty: self popUps.
	node := self demoNode: #mouseOver at: #top -> #left.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds.
	self assertEmpty: self popUps
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpDemoShowsThePopUpOnAClickInTheSecondGroup [

	| node |
	self openPopUpDemo.
	node := self demoNode: #click at: #bottom -> #right.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds.
	self assert: self popUps size equals: 1.
	(connector elementFromTLDrawable: node) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds.
	self assertEmpty: self popUps
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpDemoShowsThePopUpWhileTheMouseIsOverANodeOfTheFirstGroup [

	| node |
	self openPopUpDemo.
	node := self demoNode: #mouseOver at: #top -> #left.
	self mouseEnter: node.
	self assert: self popUps size equals: 1.
	self assert: self popUps first lines asArray equals: { (#top -> #left) asString }.
	self mouseLeave: node.
	self assertEmpty: self popUps
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpDoesNotCatchTheMouse [

	| node |
	node := self openNodeWithPopUp: nil.
	self mouseEnter: node.
	self deny: self popUps first shouldHandleMouseEvents
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsAboveTheNodeAtTheTop [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: TLPosition top.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: popUp bottom <= nodeRectangle top.
	self assert: (popUp center x - nodeRectangle center x) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsBelowTheNodeByDefault [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: nil.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: popUp top >= nodeRectangle bottom.
	self assert: (popUp center x - nodeRectangle center x) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsBelowTheNodeWhateverTheZoom [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: nil.
	connector view zoomBy: 0.5 around: 0 @ 0.
	connector view space settleForDuration: 300 milliSeconds.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: popUp top >= nodeRectangle bottom.
	self assert: popUp top - nodeRectangle bottom < 20
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsCenteredOnTheNodeWhenInside [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: (TLPosition new
			         inside;
			         yourself).
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: (popUp center - nodeRectangle center) abs < (1 @ 1)
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsOnTheLeftOfTheNodeAtTheLeft [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: TLPosition left.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: popUp right <= nodeRectangle left.
	self assert: (popUp center y - nodeRectangle center y) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpIsOnTheRightOfTheNodeAtTheRight [

	| node popUp nodeRectangle |
	node := self openNodeWithPopUp: TLPosition right.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	nodeRectangle := self nodeRectangleInWindow: node.
	self assert: popUp left >= nodeRectangle right.
	self assert: (popUp center y - nodeRectangle center y) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testPopUpStaysInTheWindow [
	"The visualization is panned so that the node is at the bottom of the window"

	| node popUp window |
	node := self openNodeWithPopUp: TLPosition bottom.
	connector view panBy: 0 @ 180.
	connector view space settleForDuration: 300 milliSeconds.
	self mouseEnter: node.
	popUp := self popUpRectangle.
	window := 0 @ 0 extent: connector view space extent.
	self assert: (window containsRect: popUp)
]

{ #category : 'tests' }
TLBlocConnectorPopUpTest >> testThereIsNoPopUpBeforeTheMouseIsOver [

	self openNodeWithPopUp: nil.
	self assertEmpty: self popUps
]
