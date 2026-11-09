"
I am a menu shown in a window: a box with a line for each entry of a TLBlocMenu. I am as big as my lines, and I stay inside the window, whatever the place I was asked for. I know which line has its submenu open.
"
Class {
	#name : 'TLBlocMenuElement',
	#superclass : 'BlElement',
	#instVars : [
		'menu',
		'popup',
		'openedItem',
		'theme'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'theme' }
TLBlocMenuElement >> applyTheme [

	self
		background: self theme menuColor;
		border: (BlBorder paint: self theme panelBorderColor width: 1)
]

{ #category : 'initialization' }
TLBlocMenuElement >> initialize [
	"A list of lines in a box, as big as its lines. It stays in the window, whatever the place it was asked for"

	super initialize.
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets all: 3);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
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
	"The size is known once the menu is laid out: a menu asked near the right or bottom border of the window is moved back inside"

	| position window |
	popup ifNil: [ ^ self ].
	window := popup extent.
	position := ((self measuredBounds position x min: window x - self extent x) max: 0) @ ((self measuredBounds position y min: window y - self extent y) max: 0).
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

	openedItem := aMenuItemElement
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
