Class {
	#name : 'TLBlocConnectorMenuTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorMenuTest >> click: aLabel in: aMenuElement [

	(aMenuElement items detect: [ :item | item label = aLabel ]) dispatchEvent: BlClickEvent new.
	connector view space settleForDuration: 300 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> dishes [

	^ #( 'french fries' 'potatoes' 'mashed potatoes' 'baked potatoes' )
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> hover: aLabel in: aMenuElement [

	(aMenuElement items detect: [ :item | item label = aLabel ]) dispatchEvent: BlMouseEnterEvent new.
	connector view space settleForDuration: 300 milliSeconds
]

{ #category : 'helpers' }
TLBlocConnectorMenuTest >> isHighlighted: anItem [

	^ anItem background paint color = anItem theme menuHoverColor
]

{ #category : 'helpers' }
TLBlocConnectorMenuTest >> item: aLabel in: aMenuElement [

	^ aMenuElement items detect: [ :item | item label = aLabel ]
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> labelsOf: aMenuElement [

	^ aMenuElement items collect: #label as: Array
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> menuElements [

	^ self popup
		  ifNil: [ #(  ) ]
		  ifNotNil: [ :popup | popup children select: [ :child | child class = TLBlocMenuElement ] ]
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> nodeElement: anEntity [

	^ connector elementFromTLDrawable: (visualization allNodes detect: [ :node | node entity = anEntity ])
]

{ #category : 'helpers' }
TLBlocConnectorMenuTest >> openMenuWithASubmenu [
	"Opens the menu of a node, with an entry Count and an entry with a submenu of dishes. Answers the menu element. It opens at the left of the window, so that the submenu has room at its right"

	visualization addNodesFromEntities: #( #Henry ).
	visualization addInteraction: (TLMenuInteraction new
			 title: 'Count';
			 action: (TLCustomAction block: [ :node |  ]);
			 yourself).
	visualization addInteraction: ((TLCustomWithParameterAction block: [ :node :dish |  ]) withMultipleChoices: [ :node | self dishes ] menu: 'Choose your dish').
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Menu'.
	connector view space settleForDuration: 1 seconds.
	self rightClickOn: (self nodeElement: #Henry) at: 40 @ 100.
	^ self menuElements first
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> openWithChoices: aBlock [
	"Opens a visualization of two nodes, whose menu has a choice of dishes: the block receives the node and the choice"

	visualization addNodesFromEntities: #( #Henry #John ).
	visualization addInteraction: ((TLCustomWithParameterAction block: aBlock) withMultipleChoices: [ :node | self dishes ] menu: 'Choose your dish').
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Menu'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> popup [

	^ connector view space root children
		  detect: [ :child | child class = TLBlocMenuPopup ]
		  ifNone: [ nil ]
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> pressOn: anElement button: aButton at: aPoint [
	"The position is the one in the window, as Bloc gives it. The screen position is the one on the desktop, which is not the same"

	anElement fireEvent: (BlMouseDownEvent new
			 position: aPoint;
			 screenPosition: aPoint + (700 @ 500);
			 button: aButton;
			 yourself).
	connector view space settleForDuration: 300 milliSeconds
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> rightClickOn: anElement at: aPoint [

	self pressOn: anElement button: BlMouseButton secondary at: aPoint
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testArrowOfASubmenuIsOnTheRightOfItsLine [

	| menu item arrow |
	menu := self openMenuWithASubmenu.
	item := self item: 'Choose your dish' in: menu.
	arrow := item children last.
	self assert: (item width - item padding right - arrow bounds inParent right) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testChoosingADishClosesTheMenus [

	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self hover: 'Choose your dish' in: self menuElements first.
	self click: 'potatoes' in: self menuElements last.
	self assertEmpty: self menuElements.
	self assert: self popup isNil
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testChoosingADishExecutesTheActionWithTheNodeAndTheDish [

	| chosen |
	chosen := OrderedCollection new.
	self openWithChoices: [ :node :dish | chosen add: node entity -> dish ].
	self rightClickOn: (self nodeElement: #John) at: 100 @ 100.
	self hover: 'Choose your dish' in: self menuElements first.
	self click: 'potatoes' in: self menuElements last.
	self assert: chosen asArray equals: { (#John -> 'potatoes') }
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testClickingTheEntryOfASubmenuDoesNotCloseTheMenus [

	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self click: 'Choose your dish' in: self menuElements first.
	self assert: self menuElements size equals: 2
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testHoveringAnotherEntryClosesTheSubmenu [

	| count |
	count := 0.
	visualization addNodesFromEntities: #( #Henry ).
	visualization addInteraction: (TLMenuInteraction new
			 title: 'Count';
			 action: (TLCustomAction block: [ :node | count := count + 1 ]);
			 yourself).
	visualization addInteraction: ((TLCustomWithParameterAction block: [ :node :dish |  ]) withMultipleChoices: [ :node | self dishes ] menu: 'Choose your dish').
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Menu'.
	connector view space settleForDuration: 1 seconds.
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self hover: 'Choose your dish' in: self menuElements first.
	self assert: self menuElements size equals: 2.
	self hover: 'Count' in: self menuElements first.
	self assert: self menuElements size equals: 1.
	self assert: count equals: 0
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testHoveringTheEntryShowsTheChoicesNextToIt [

	| menu submenu |
	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 40 @ 100.
	menu := self menuElements first.
	self hover: 'Choose your dish' in: menu.
	self assert: self menuElements size equals: 2.
	submenu := self menuElements last.
	self assert: (self labelsOf: submenu) equals: self dishes.
	self deny: (submenu bounds inSpace asRectangle intersects: menu bounds inSpace asRectangle)
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testHoveringTheSameEntryAgainKeepsTheSubmenu [

	| submenu |
	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self hover: 'Choose your dish' in: self menuElements first.
	submenu := self menuElements last.
	self hover: 'Choose your dish' in: self menuElements first.
	self assert: self menuElements size equals: 2.
	self assert: self menuElements last identicalTo: submenu
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testLineOfAClosedSubmenuIsNotHighlightedAnyMore [

	| menu item |
	menu := self openMenuWithASubmenu.
	item := self item: 'Choose your dish' in: menu.
	self hover: 'Choose your dish' in: menu.
	item dispatchEvent: BlMouseLeaveEvent new.
	self hover: 'Count' in: menu.
	self deny: (self isHighlighted: item)
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testLineOfTheOpenSubmenuStaysHighlighted [
	"The mouse leaves the line to go into the submenu: the line still shows which submenu is open"

	| menu item |
	menu := self openMenuWithASubmenu.
	item := self item: 'Choose your dish' in: menu.
	self hover: 'Choose your dish' in: menu.
	item dispatchEvent: BlMouseLeaveEvent new.
	self assert: (self isHighlighted: item)
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testMenuHasAShadow [
	"Like the pop ups, a menu stands above the visualization"

	| menu |
	menu := self openMenuWithASubmenu.
	self assert: menu effect class equals: BlGaussianShadowEffect
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testMenuIsNotNarrowerThanItsMinimumWidth [

	| menu |
	menu := self openMenuWithASubmenu.
	self assert: menu width >= TLBlocMenuElement minimumWidth
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testMenuOpensWhereTheMouseIs [

	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 120.
	self assert: self menuElements first measuredBounds position equals: 100 @ 120
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testMenuStaysInTheWindow [

	| menu |
	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 395 @ 295.
	menu := self menuElements first.
	self assert: menu measuredBounds position x + menu extent x <= 400.
	self assert: menu measuredBounds position y + menu extent y <= 300
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testPressingOutsideTheMenusClosesThemWithoutExecutingAnything [

	| chosen |
	chosen := OrderedCollection new.
	self openWithChoices: [ :node :dish | chosen add: dish ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self pressOn: self popup button: BlMouseButton primary at: 300 @ 250.
	self assert: self popup isNil.
	self assertEmpty: chosen
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testPrimaryButtonDoesNotOpenTheMenu [

	self openWithChoices: [ :node :dish |  ].
	self pressOn: (self nodeElement: #Henry) button: BlMouseButton primary at: 5 @ 5.
	self assertEmpty: self menuElements
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testRightClickOnANodeOpensItsMenuWithTheTitleOfTheInteraction [

	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self assert: self menuElements size equals: 1.
	self assert: (self labelsOf: self menuElements first) equals: #( 'Choose your dish' )
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testRightClickingAgainReplacesTheMenu [

	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self rightClickOn: (self nodeElement: #John) at: 200 @ 150.
	self assert: self menuElements size equals: 1.
	self assert: self menuElements first measuredBounds position equals: 200 @ 150
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testSimpleMenuInteractionIsAnEntryOfTheSameMenu [

	| count |
	count := 0.
	visualization addNodesFromEntities: #( #Henry ).
	visualization addInteraction: (TLMenuInteraction new
			 title: 'Count';
			 action: (TLCustomAction block: [ :node | count := count + 1 ]);
			 yourself).
	visualization addInteraction: ((TLCustomWithParameterAction block: [ :node :dish |  ]) withMultipleChoices: [ :node | self dishes ] menu: 'Choose your dish').
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Menu'.
	connector view space settleForDuration: 1 seconds.
	self rightClickOn: (self nodeElement: #Henry) at: 100 @ 100.
	self assert: self menuElements size equals: 1.
	self assert: ((self labelsOf: self menuElements first) includesAll: #( 'Count' 'Choose your dish' )).
	self click: 'Count' in: self menuElements first.
	self assert: count equals: 1.
	self assert: self popup isNil
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testSubmenuIsAlignedWithItsLineAndContinuesItsMenu [

	| menu item submenu |
	menu := self openMenuWithASubmenu.
	item := self item: 'Choose your dish' in: menu.
	self hover: 'Choose your dish' in: menu.
	submenu := self menuElements last.
	self assert: (submenu items first bounds inSpace asRectangle top - item bounds inSpace asRectangle top) abs < 1.
	self assert: (submenu bounds inSpace asRectangle left - menu bounds inSpace asRectangle right) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testSubmenuStaysInTheWindow [

	| submenu |
	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 300 @ 200.
	self hover: 'Choose your dish' in: self menuElements first.
	submenu := self menuElements last.
	self assert: submenu measuredBounds position x + submenu extent x <= 400.
	self assert: submenu measuredBounds position y + submenu extent y <= 300
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testSubmenuWithoutRoomAtTheRightOpensAtTheLeft [

	| menu submenu |
	self openWithChoices: [ :node :dish |  ].
	self rightClickOn: (self nodeElement: #Henry) at: 200 @ 100.
	menu := self menuElements first.
	self hover: 'Choose your dish' in: menu.
	submenu := self menuElements last.
	self assert: (menu bounds inSpace asRectangle left - submenu bounds inSpace asRectangle right) abs < 1
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testTextOfALineIsAsHighAsALineOfItsFont [

	| menu |
	menu := self openMenuWithASubmenu.
	menu items do: [ :item | self assert: item children first height >= 13 ]
]

{ #category : 'tests' }
TLBlocConnectorMenuTest >> testThereIsNoMenuBeforeTheRightClick [

	self openWithChoices: [ :node :dish |  ].
	self assertEmpty: self menuElements
]
