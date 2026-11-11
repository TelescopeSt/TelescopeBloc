"
I am a menu shown in a window: a rounded box with a soft shadow, like the pop ups, and a line for each entry of a TLBlocMenu. I am as big as my lines, but not narrower than #minimumWidth, and I stay inside the window, whatever the place I was asked for. I know which line has its submenu open: it stays highlighted while the mouse is in the submenu. When I am a submenu, I know the menu which opened me (#openerMenu:), and I open at its left when there is no room at its right.
"
Class {
	#name : 'TLBlocMenuElement',
	#superclass : 'BlElement',
	#instVars : [
		'menu',
		'popup',
		'openedItem',
		'theme',
		'openerMenu'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'accessing' }
TLBlocMenuElement class >> minimumWidth [
	"A menu with short entries is not narrower: it would look cramped"

	^ 160
]

{ #category : 'accessing' }
TLBlocMenuElement class >> padding [
	"The space between the border of a menu and its lines"

	^ 8
]

{ #category : 'theme' }
TLBlocMenuElement >> applyTheme [
	"A soft shadow, like the one of the pop ups, sets the menu above the visualization"

	self
		background: self theme menuColor;
		border: (BlBorder paint: self theme panelBorderColor width: 1);
		effect: (BlGaussianShadowEffect color: self theme popUpShadowColor width: 9 offset: 0 @ 3)
]

{ #category : 'initialization' }
TLBlocMenuElement >> initialize [
	"A list of lines in a rounded box, as big as its lines but not narrower than a minimum, with some space around them. It stays in the window, whatever the place it was asked for"

	super initialize.
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent.
				layoutConstraints minWidth: self class minimumWidth ];
		padding: (BlInsets all: self class padding);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 8);
		addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self keepInWindow ].
	self applyTheme
]

{ #category : 'accessing' }
TLBlocMenuElement >> items [
	"The lines of the menu, from top to bottom"

	^ self children asArray
]

{ #category : 'layout' }
TLBlocMenuElement >> keepInWindow [
	"The size is known once the menu is laid out: a menu asked near the right or bottom border of the window is moved back inside. A submenu which has no room at the right of the menu which opened it opens at its left instead, so that it does not cover it"

	| x position window |
	popup ifNil: [ ^ self ].
	window := popup extent.
	x := self measuredBounds position x.
	(openerMenu isNotNil and: [ x + self extent x > window x ]) ifTrue: [ x := openerMenu measuredBounds position x - popup submenuGap - self extent x ].
	position := ((x min: window x - self extent x) max: 0) @ ((self measuredBounds position y min: window y - self extent y) max: 0).
	self measuredBounds position = position ifFalse: [ self position: position ]
]

{ #category : 'initialization' }
TLBlocMenuElement >> menu: aMenu popup: aPopup [
	"A line for each entry of the menu"

	menu := aMenu.
	popup := aPopup.
	aMenu entries do: [ :entry |
			self addChild: (TLBlocMenuItemElement new
					 theme: self theme;
					 entry: entry;
					 yourself) ]
]

{ #category : 'accessing' }
TLBlocMenuElement >> openedItem [
	"The line whose submenu is open, or nil"

	^ openedItem
]

{ #category : 'accessing' }
TLBlocMenuElement >> openedItem: aMenuItemElement [
	"The line whose submenu is open stays highlighted while the mouse is in the submenu, and the one which was open before is not any more"

	openedItem ifNotNil: [ :previous | previous highlight: false ].
	openedItem := aMenuItemElement.
	aMenuItemElement ifNotNil: [ :item | item highlight: true ]
]

{ #category : 'accessing' }
TLBlocMenuElement >> openerMenu: aMenuElement [
	"The menu whose line opened me, when I am a submenu"

	openerMenu := aMenuElement
]

{ #category : 'accessing' }
TLBlocMenuElement >> popup [

	^ popup
]

{ #category : 'theme' }
TLBlocMenuElement >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocMenuElement >> theme: aTheme [
	"Given before the menu: its lines have the same theme"

	theme := aTheme.
	self applyTheme
]
