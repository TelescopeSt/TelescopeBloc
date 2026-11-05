"
I am an entry of a TLBlocMenu which opens a submenu of choices instead of executing an action. The choices are asked when the submenu opens, so they are the current ones. Choosing one sends its index to the chosen block.
"
Class {
	#name : 'TLBlocSubmenuEntry',
	#superclass : 'TLBlocMenuEntry',
	#instVars : [
		'choicesBlock',
		'displayBlock',
		'chosenBlock'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'instance creation' }
TLBlocSubmenuEntry class >> label: aString choices: aChoicesBlock display: aDisplayBlock chosen: aChosenBlock [

	^ self new
		  label: aString
		  choices: aChoicesBlock
		  display: aDisplayBlock
		  chosen: aChosenBlock;
		  yourself
]

{ #category : 'accessing' }
TLBlocSubmenuEntry >> execute [
	"An entry with a submenu opens it, it does not do anything by itself"

	^ nil
]

{ #category : 'accessing' }
TLBlocSubmenuEntry >> hasSubmenu [

	^ true
]

{ #category : 'accessing' }
TLBlocSubmenuEntry >> label: aString choices: aChoicesBlock display: aDisplayBlock chosen: aChosenBlock [

	label := aString.
	choicesBlock := aChoicesBlock.
	displayBlock := aDisplayBlock.
	chosenBlock := aChosenBlock
]

{ #category : 'accessing' }
TLBlocSubmenuEntry >> submenu [
	"The menu of the choices, as they are now"

	| menu |
	menu := TLBlocMenu new.
	choicesBlock value doWithIndex: [ :choice :index | menu entries add: (TLBlocMenuEntry label: (displayBlock value: choice) asString action: [ chosenBlock value: index ]) ].
	^ menu
]
