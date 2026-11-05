"
I am a line of a menu shown in a window: the text of an entry, and an arrow when the entry opens a submenu. I change color while the mouse is over me, and my popup is told: the submenu of my entry opens when the mouse enters me, and the submenus of the other lines of my menu close. Clicking me executes my entry, unless it has a submenu.
"
Class {
	#name : 'TLBlocMenuItemElement',
	#superclass : 'BlElement',
	#instVars : [
		'entry'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'initialization' }
TLBlocMenuItemElement >> choose [
	"The menu which contains the line decides what choosing it does: executing an action closes the menus, a submenu opens next to the line"

	self parent popup choose: entry from: self
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> entry: aMenuEntry [
	"The text of the line, and an arrow when choosing it opens a submenu"

	entry := aMenuEntry.
	self addChild: (BlTextElement new
			 text: (aMenuEntry label asString asRopedText fontSize: 13);
			 yourself).
	aMenuEntry hasSubmenu ifTrue: [
			self addChild: (BlElement new
					 extent: 6 @ 10;
					 geometry: (BlPolygonGeometry vertices: {
									  (0 @ 0).
									  (6 @ 5).
									  (0 @ 10) });
					 background: Color darkGray;
					 margin: (BlInsets left: 14);
					 yourself) ]
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> hover [
	"The mouse is over the line: its submenu opens, and the submenus of the other lines close"

	self parent popup hover: entry over: self
]

{ #category : 'accessing' }
TLBlocMenuItemElement >> hoverColor [

	^ Color veryLightGray
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> initialize [
	"A line of a menu, as wide as the menu. It changes its color while the mouse is over it, and the menu is told, so that it opens the submenu of the line or closes the one of another line"

	super initialize.
	self
		layout: (BlLinearLayout horizontal
				 alignCenterLeft;
				 yourself);
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal matchParent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets
				 top: 4
				 left: 10
				 bottom: 4
				 right: 10);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		addEventHandlerOn: BlMouseEnterEvent do: [ :event |
			self background: self hoverColor.
			self hover ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self background: Color transparent ];
		addEventHandlerOn: BlClickEvent do: [ :event | self choose ]
]

{ #category : 'accessing' }
TLBlocMenuItemElement >> label [

	^ entry label
]
