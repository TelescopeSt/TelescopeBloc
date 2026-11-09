"
A toolbar button which is on or off. It looks pressed when it is on, and its action receives the new state each time it is clicked.
"
Class {
	#name : 'TLBlocToolbarToggleButton',
	#superclass : 'TLBlocToolbarButton',
	#instVars : [
		'isOn'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> activate [
	"Switches the button, and tells the action the new state. The mouse is over the button since it was clicked"

	isOn := isOn not.
	self background: self hoverColor.
	action value: isOn
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> hoverColor [

	^ isOn
		  ifTrue: [ self theme toggledButtonHoverColor ]
		  ifFalse: [ super hoverColor ]
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> initialize [
	"A button which is on or off, and looks pressed when it is on. It is off until it is told otherwise"

	isOn := false.
	super initialize
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> isOn [

	^ isOn
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> isOn: aBoolean [

	isOn := aBoolean.
	self background: self restColor
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> isToggle [

	^ true
]

{ #category : 'accessing' }
TLBlocToolbarToggleButton >> restColor [

	^ isOn
		  ifTrue: [ self theme toggledButtonColor ]
		  ifFalse: [ super restColor ]
]
