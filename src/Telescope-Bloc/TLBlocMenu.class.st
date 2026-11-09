"
I am the menu of a drawable of a Telescope visualization of Bloc: a list of entries, each with a text and an action, or with a submenu of choices. Telescope fills me through #add:target:selector:argument: and the connector through #add:choices:display:chosen:. I am a model: #openIn:at: shows me in the window as Bloc elements, without Morphic.
"
Class {
	#name : 'TLBlocMenu',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'theme'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'adding' }
TLBlocMenu >> add: aTitle choices: aChoicesBlock display: aDisplayBlock chosen: aChosenBlock [
	"An entry which opens a submenu of choices. The block of the choices is evaluated when the submenu opens, the display block gives the text of each choice and the chosen block receives the index of the choice"

	entries add: (TLBlocSubmenuEntry
			 label: aTitle
			 choices: aChoicesBlock
			 display: aDisplayBlock
			 chosen: aChosenBlock)
]

{ #category : 'adding' }
TLBlocMenu >> add: aTitle target: anObject selector: aSelector argument: anArgument [
	"An entry which sends the selector with the argument to the object when it is chosen. This is the message the connectors of Telescope use to fill the menu of a drawable"

	entries add: (TLBlocMenuEntry label: aTitle action: [ anObject perform: aSelector with: anArgument ])
]

{ #category : 'accessing' }
TLBlocMenu >> entries [

	^ entries
]

{ #category : 'initialization' }
TLBlocMenu >> initialize [

	super initialize.
	entries := OrderedCollection new
]

{ #category : 'accessing' }
TLBlocMenu >> isEmpty [

	^ entries isEmpty
]

{ #category : 'opening' }
TLBlocMenu >> openIn: aSpace at: aPoint [
	"Shows the menu in the window, with its top left corner at the point. The other menus of the window are closed"

	TLBlocMenuPopup openIn: aSpace menu: self at: aPoint
]

{ #category : 'theme' }
TLBlocMenu >> theme [
	"The theme which gives my colors: the default one unless I was given another one"

	^ theme ifNil: [ theme := TLBlocTheme default ]
]

{ #category : 'theme' }
TLBlocMenu >> theme: aTheme [

	theme := aTheme
]
