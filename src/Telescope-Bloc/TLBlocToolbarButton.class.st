"
I am a small button of the toolbar of a visualization: a rounded box with a text, which executes an action when it is clicked and which changes its color while the mouse is over it. My text is my label. The buttons which save something have an arrow down after their label.
"
Class {
	#name : 'TLBlocToolbarButton',
	#superclass : 'BlElement',
	#instVars : [
		'label',
		'action',
		'icon'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocToolbarButton class >> label: aString action: aBlock [

	^ self new
		  label: aString action: aBlock;
		  yourself
]

{ #category : 'icon' }
TLBlocToolbarButton >> addDownArrow [
	"An arrow pointing down, drawn after the label, for the buttons which save something"

	icon := BlElement new
		        extent: 8 @ 10;
		        geometry: (BlPolygonGeometry vertices: {
						         (3 @ 0).
						         (5 @ 0).
						         (5 @ 5).
						         (8 @ 5).
						         (4 @ 10).
						         (0 @ 5).
						         (3 @ 5) });
		        background: Color darkGray;
		        margin: (BlInsets left: 5);
		        yourself.
	self addChild: icon
]

{ #category : 'accessing' }
TLBlocToolbarButton >> hoverColor [

	^ Color veryLightGray
]

{ #category : 'icon' }
TLBlocToolbarButton >> icon [
	"The icon drawn after the label, or nil when the button has none"

	^ icon
]

{ #category : 'initialization' }
TLBlocToolbarButton >> initialize [
	"A small rounded button which is as big as its label, but not smaller than a minimum so that the buttons look alike. Its layout is not the basic one, which does not wrap its content"

	super initialize.
	self
		layout: (BlLinearLayout horizontal
				 alignCenter;
				 yourself);
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		minWidth: 28;
		minHeight: 24;
		padding: (BlInsets
				 top: 3
				 left: 8
				 bottom: 3
				 right: 8);
		margin: (BlInsets all: 2);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		background: self restColor;
		border: (BlBorder paint: Color lightGray width: 1);
		addEventHandlerOn: BlMouseEnterEvent do: [ :event | self background: self hoverColor ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self background: self restColor ];
		addEventHandlerOn: BlClickEvent do: [ :event | action value ]
]

{ #category : 'accessing' }
TLBlocToolbarButton >> label [
	"The text of the button"

	^ label
]

{ #category : 'initialization' }
TLBlocToolbarButton >> label: aString action: aBlock [
	"The text of the button, and what happens when it is clicked"

	label := aString.
	action := aBlock.
	self addChild: (BlTextElement new
			 text: (aString asRopedText fontSize: 13);
			 yourself)
]

{ #category : 'accessing' }
TLBlocToolbarButton >> restColor [

	^ Color white
]
