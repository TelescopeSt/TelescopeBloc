"
I am a line of a menu shown in a window: the text of an entry, as high as a line of its font, and a chevron at my right when the entry opens a submenu. I am highlighted while the mouse is over me and while my submenu is open, and my popup is told: the submenu of my entry opens when the mouse enters me, and the submenus of the other lines of my menu close. Clicking me executes my entry, unless it has a submenu.
"
Class {
	#name : 'TLBlocMenuItemElement',
	#superclass : 'BlElement',
	#instVars : [
		'entry',
		'theme'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'accessing' }
TLBlocMenuItemElement class >> verticalMargin [
	"The space above and below a line, so that the highlighted line does not touch its neighbours"

	^ 1
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> choose [
	"The menu which contains the line decides what choosing it does: executing an action closes the menus, a submenu opens next to the line"

	self parent popup choose: entry from: self
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> entry: aMenuEntry [
	"The text of the line, as high as a line of its font, and a chevron at the right of the line when choosing it opens a submenu. The text takes the width the chevron does not use"

	entry := aMenuEntry.
	self addChild: (BlTextElement new
			 labelMeasurement;
			 text: ((aMenuEntry label asString asRopedText fontSize: 13) foreground: self theme textColor);
			 constraintsDo: [ :layoutConstraints | layoutConstraints horizontal matchParent ];
			 yourself).
	aMenuEntry hasSubmenu ifTrue: [
			self addChild: (BlElement new
					 extent: 5 @ 9;
					 geometry: (BlPolylineGeometry vertices: {
									  (0.5 @ 0.5).
									  (4.5 @ 4.5).
									  (0.5 @ 8.5) });
					 border: (BlBorder builder
							  paint: self theme iconColor;
							  width: 1.5;
							  capRound;
							  joinRound;
							  build);
					 margin: (BlInsets left: 16);
					 yourself) ]
]

{ #category : 'hovering' }
TLBlocMenuItemElement >> highlight: aBoolean [

	self background: (aBoolean
			 ifTrue: [ self hoverColor ]
			 ifFalse: [ Color transparent ])
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> hover [
	"The mouse is over the line: its submenu opens, and the submenus of the other lines close"

	self parent popup hover: entry over: self
]

{ #category : 'accessing' }
TLBlocMenuItemElement >> hoverColor [

	^ self theme menuHoverColor
]

{ #category : 'initialization' }
TLBlocMenuItemElement >> initialize [
	"A line of a menu, as wide as the menu. It is highlighted while the mouse is over it, and while its submenu is open, and the menu is told, so that it opens the submenu of the line or closes the one of another line"

	super initialize.
	self
		layout: (BlLinearLayout horizontal
				 alignCenterLeft;
				 yourself);
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal matchParent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets
				 top: 5
				 left: 12
				 bottom: 5
				 right: 10);
		margin: (BlInsets top: self class verticalMargin bottom: self class verticalMargin);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 5);
		addEventHandlerOn: BlMouseEnterEvent do: [ :event |
			self highlight: true.
			self hover ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self isOpened ifFalse: [ self highlight: false ] ];
		addEventHandlerOn: BlClickEvent do: [ :event | self choose ]
]

{ #category : 'testing' }
TLBlocMenuItemElement >> isOpened [
	"Whether my submenu is open"

	^ self parent isNotNil and: [ self parent openedItem == self ]
]

{ #category : 'accessing' }
TLBlocMenuItemElement >> label [

	^ entry label
]

{ #category : 'theme' }
TLBlocMenuItemElement >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocMenuItemElement >> theme: aTheme [
	"Given before the entry: its text and its arrow have the colors of the theme"

	theme := aTheme
]
