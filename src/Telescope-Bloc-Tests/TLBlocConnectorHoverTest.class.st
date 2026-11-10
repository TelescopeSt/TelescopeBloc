"
I test the feedback a visualization gives under the mouse: the outline of the node under the mouse, and the cursor (a hand over a node which can be clicked, a move cursor while a node is dragged). The mouse moves go through the mouse processor of the window, which finds the element under the mouse and updates the cursor as with a real mouse.
"
Class {
	#name : 'TLBlocConnectorHoverTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests',
	#package : 'Telescope-Bloc-Tests'
}

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> centerOf: anEntity [
	"The center of the node in the window"

	^ (self elementOf: anEntity) bounds inSpace center
]

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> cursor [

	^ connector view space currentCursor
]

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> elementOf: anEntity [

	^ connector elementFromTLDrawable: (visualization allNodesRecursively detect: [ :node | node entity = anEntity ])
]

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> moveMouseTo: aPoint [
	"The mouse processor of the window finds the element under the mouse, sends it the event and updates the cursor, as for a real mouse"

	connector view space mouseProcessor handleMouseMove: (BlMouseMoveEvent new
			 position: aPoint;
			 screenPosition: aPoint;
			 yourself)
]

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> pointNearTheTopLeftOf: anEntity [
	"A point of the node in the window which is not on its children"

	^ (self elementOf: anEntity) bounds inSpace asRectangle origin + (6 @ 6)
]

{ #category : 'running' }
TLBlocConnectorHoverTest >> setUp [
	"A composite node which can be clicked, whose child is shown and cannot be clicked, and a node which cannot be clicked"

	super setUp.
	visualization styleSheet
		compositeExpandedByDefault: true;
		width: 40;
		height: 40.
	visualization childrenProperty: [ :entity |
			entity = 1
				ifTrue: [ #( 11 ) ]
				ifFalse: [ #(  ) ] ].
	visualization nodeCreationStrategy beRecursive.
	visualization layout: TLLinearLayout new.
	(visualization addNodeFromEntity: 1) addInteraction: (TLCustomAction block: [ :node |  ]) onClick.
	visualization addNodeFromEntity: 2.
	connector open: visualization inWindowSized: 300 @ 300 titled: 'Hover'.
	self settle
]

{ #category : 'helpers' }
TLBlocConnectorHoverTest >> settle [

	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testADraggedNodeShowsTheMoveCursorUntilItIsDropped [

	| start |
	start := self centerOf: 2.
	(self elementOf: 2) fireEvent: (BlMouseDownEvent new
			 position: start;
			 screenPosition: start;
			 button: BlMouseButton primary;
			 yourself).
	self moveMouseTo: start + (20 @ 0).
	self assert: self cursor equals: Cursor move.
	connector view space root fireEvent: (BlMouseUpEvent new
			 position: start + (20 @ 0);
			 screenPosition: start + (20 @ 0);
			 button: BlMouseButton primary;
			 yourself).
	self moveMouseTo: start + (21 @ 0).
	self assert: self cursor equals: Cursor normal
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testANodeWhichCanBeClickedShowsAHand [

	self moveMouseTo: (self pointNearTheTopLeftOf: 1).
	self assert: self cursor equals: Cursor webLink
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testANodeWhichCannotBeClickedShowsTheNormalCursor [

	self moveMouseTo: (self pointNearTheTopLeftOf: 1).
	self moveMouseTo: (self centerOf: 2).
	self assert: self cursor equals: Cursor normal
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testNothingIsOutlinedWhilePanning [
	"While the user pans, the mouse is not over the nodes"

	self moveMouseTo: (self centerOf: 2).
	connector view startPanning.
	self moveMouseTo: (self centerOf: 2) + (1 @ 0).
	self assert: connector view hoveredNode isNil.
	self assert: (self elementOf: 2) effect isNullEffect.
	connector view stopPanning
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheBackgroundShowsTheNormalCursor [

	self moveMouseTo: (self pointNearTheTopLeftOf: 1).
	self moveMouseTo: 5 @ 295.
	self assert: (self cursor isNil or: [ self cursor = Cursor normal ])
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheChildOfANodeWhichCanBeClickedDoesNotShowAHand [
	"The click on the child is for the child, not for its composite"

	self moveMouseTo: (self pointNearTheTopLeftOf: 1).
	self moveMouseTo: (self centerOf: 11).
	self assert: self cursor equals: Cursor normal
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheInnermostNodeIsOutlined [
	"The child of a composite is outlined, not the composite"

	self moveMouseTo: (self centerOf: 11).
	self assert: connector view hoveredNode identicalTo: (self elementOf: 11).
	self assert: (self elementOf: 1) effect isNullEffect
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheNodeUnderTheMouseIsOutlined [

	self moveMouseTo: (self centerOf: 2).
	self assert: connector view hoveredNode identicalTo: (self elementOf: 2).
	self assert: (self elementOf: 2) effect class equals: TLBlocHoverOutlineEffect.
	self assert: (self elementOf: 1) effect isNullEffect
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheOutlineFollowsTheMouse [

	self moveMouseTo: (self centerOf: 2).
	self moveMouseTo: (self pointNearTheTopLeftOf: 1).
	self assert: connector view hoveredNode identicalTo: (self elementOf: 1).
	self assert: (self elementOf: 1) effect class equals: TLBlocHoverOutlineEffect.
	self assert: (self elementOf: 2) effect isNullEffect
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheOutlineHasTheColorOfTheTheme [

	connector view theme: TLBlocDarkTheme new.
	self moveMouseTo: (self centerOf: 2).
	self assert: (self elementOf: 2) effect color equals: TLBlocDarkTheme new hoverOutlineColor
]

{ #category : 'tests' }
TLBlocConnectorHoverTest >> testTheOutlineIsRemovedOnTheBackground [

	self moveMouseTo: (self centerOf: 2).
	self moveMouseTo: 5 @ 295.
	self assert: connector view hoveredNode isNil.
	self assert: (self elementOf: 2) effect isNullEffect
]
