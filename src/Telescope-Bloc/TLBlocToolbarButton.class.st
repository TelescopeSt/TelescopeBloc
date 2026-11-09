"
A small button of the toolbar of a visualization. Its action is evaluated when it is clicked. It can have an icon drawn after its label, and a tooltip which explains it once the mouse stayed over it for a second.
"
Class {
	#name : 'TLBlocToolbarButton',
	#superclass : 'BlElement',
	#instVars : [
		'label',
		'action',
		'icon',
		'tooltip',
		'tooltipTask',
		'theme'
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

{ #category : 'actions' }
TLBlocToolbarButton >> activate [
	"What happens when the button is clicked"

	action value
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
		        background: self theme iconColor;
		        margin: (BlInsets left: 5);
		        yourself.
	self addChild: icon
]

{ #category : 'theme' }
TLBlocToolbarButton >> applyTheme [
	"The background, the border, the text and the arrow"

	self
		background: self restColor;
		border: (BlBorder paint: self theme panelBorderColor width: 1).
	(self children
		 detect: [ :child | child class = BlTextElement ]
		 ifNone: [ nil ]) ifNotNil: [ :textElement | textElement text: self labelText ].
	icon ifNotNil: [ :arrow | arrow background: self theme iconColor ]
]

{ #category : 'accessing' }
TLBlocToolbarButton >> hideTooltip [

	tooltipTask ifNotNil: [ :task | task stop ].
	self space ifNotNil: [ :space | TLBlocPopUpElement closeIn: space root ]
]

{ #category : 'accessing' }
TLBlocToolbarButton >> hoverColor [

	^ self theme buttonHoverColor
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
		addEventHandlerOn: BlMouseEnterEvent do: [ :event | self background: self hoverColor ];
		addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self background: self restColor ];
		addEventHandlerOn: BlClickEvent do: [ :event | self activate ].
	self applyTheme
]

{ #category : 'accessing' }
TLBlocToolbarButton >> isToggle [

	^ false
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
			 text: self labelText;
			 yourself)
]

{ #category : 'accessing' }
TLBlocToolbarButton >> labelText [
	"The label in the size and the color of the text of the buttons"

	^ (label asRopedText fontSize: 13) foreground: self theme textColor
]

{ #category : 'accessing' }
TLBlocToolbarButton >> restColor [

	^ self theme buttonColor
]

{ #category : 'accessing' }
TLBlocToolbarButton >> scheduleTooltip [

	tooltipTask ifNil: [
			tooltipTask := BlDelayedTaskAction new
				               delay: self tooltipDelay;
				               action: [ self showTooltip ];
				               yourself ].
	tooltipTask element: self.
	tooltipTask startOrRestart
]

{ #category : 'accessing' }
TLBlocToolbarButton >> showTooltip [

	self space ifNotNil: [
			TLBlocPopUpElement
				showText: tooltip
				near: self
				position: TLPosition bottom
				theme: self theme ]
]

{ #category : 'theme' }
TLBlocToolbarButton >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocToolbarButton >> theme: aTheme [

	theme := aTheme.
	self applyTheme
]

{ #category : 'accessing' }
TLBlocToolbarButton >> tooltip [
	"The text which explains the button when the mouse is over it"

	^ tooltip
]

{ #category : 'accessing' }
TLBlocToolbarButton >> tooltip: aString [
	"Shows the text below the button once the mouse stayed over it for a moment. It is hidden when the mouse leaves, and when the button is clicked because the tooltip would hide what the click changed"

	tooltip ifNil: [
			self
				addEventHandlerOn: BlMouseEnterEvent do: [ :event | self scheduleTooltip ];
				addEventHandlerOn: BlMouseLeaveEvent do: [ :event | self hideTooltip ];
				addEventHandlerOn: BlClickEvent do: [ :event | self hideTooltip ] ].
	tooltip := aString
]

{ #category : 'accessing' }
TLBlocToolbarButton >> tooltipDelay [
	"How long the mouse has to stay over the button before its tooltip is shown"

	^ 0.5 second
]
