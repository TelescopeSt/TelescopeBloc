"
I am the transparent layer, as big as the window, which holds the menus shown above a visualization. I open the first menu where I am asked to, and a submenu at the right of a line when the mouse enters it, its first line in front of the line, replacing the submenus after the menu of the line. I close when a line which executes an action is chosen, or when the mouse is pressed outside of the menus. Only one of me is in a window.
"
Class {
	#name : 'TLBlocMenuPopup',
	#superclass : 'BlElement',
	#instVars : [
		'theme'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'opening' }
TLBlocMenuPopup class >> openIn: aSpace menu: aMenu at: aPoint [
	"Closes the menus which are open in the window, and shows the menu with its top left corner at the point"

	| popup |
	(aSpace root children select: [ :child | child class = self ]) do: #removeFromParent.
	popup := self new
		         extent: aSpace extent;
		         theme: aMenu theme;
		         yourself.
	aSpace root addChild: popup.
	popup show: aMenu at: aPoint.
	^ popup
]

{ #category : 'opening' }
TLBlocMenuPopup >> choose: anEntry from: anItem [
	"An action is executed once the menus are closed, because it may update the visualization. Choosing a line with a submenu opens the submenu, if the mouse did not already"

	anEntry hasSubmenu ifTrue: [ ^ self hover: anEntry over: anItem ].
	self close.
	anEntry execute
]

{ #category : 'opening' }
TLBlocMenuPopup >> close [

	self removeFromParent
]

{ #category : 'opening' }
TLBlocMenuPopup >> hover: anEntry over: anItem [
	"The mouse is over a line: the submenu of the line opens at its right, its first line in front of the line, unless it is open already (see TLBlocMenuElement>>#keepInWindow when there is no room at the right). The submenus of the other lines of the menu close, and the submenus open after the menu of the line are replaced"

	| menuElement |
	menuElement := anItem parent.
	menuElement openedItem == anItem ifTrue: [ ^ self ].
	(self children asArray copyAfter: menuElement) do: #removeFromParent.
	menuElement openedItem: nil.
	anEntry hasSubmenu ifFalse: [ ^ self ].
	menuElement openedItem: anItem.
	(self show: anEntry submenu at: menuElement measuredBounds position x + menuElement extent x + self submenuGap
		 @ (menuElement measuredBounds position y + anItem position y - TLBlocMenuElement padding - TLBlocMenuItemElement verticalMargin)) openerMenu: menuElement
]

{ #category : 'initialization' }
TLBlocMenuPopup >> initialize [
	"A transparent layer as big as the window, which holds the open menus above the visualization and receives the mouse presses outside of them"

	super initialize.
	self addEventHandlerOn: BlMouseDownEvent do: [ :event | event target == self ifTrue: [ self close ] ]
]

{ #category : 'opening' }
TLBlocMenuPopup >> show: aMenu at: aPoint [
	"Adds the menu, above the menus which are already open, and answers its element"

	| element |
	element := TLBlocMenuElement new
		           theme: self theme;
		           menu: aMenu popup: self;
		           position: aPoint;
		           yourself.
	self addChild: element.
	^ element
]

{ #category : 'accessing' }
TLBlocMenuPopup >> submenuGap [
	"The space between a menu and the submenu which opens at its right: none, the submenu continues the menu"

	^ 0
]

{ #category : 'theme' }
TLBlocMenuPopup >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocMenuPopup >> theme: aTheme [
	"The theme of the menus I show, the one of the menu I was opened for"

	theme := aTheme
]
