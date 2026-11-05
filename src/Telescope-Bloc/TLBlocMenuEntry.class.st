"
I am an entry of a TLBlocMenu: a text, and an action which is executed when the entry is chosen.
"
Class {
	#name : 'TLBlocMenuEntry',
	#superclass : 'Object',
	#instVars : [
		'label',
		'action'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'instance creation' }
TLBlocMenuEntry class >> label: aString action: aBlock [

	^ self new
		  label: aString action: aBlock;
		  yourself
]

{ #category : 'accessing' }
TLBlocMenuEntry >> action [

	^ action
]

{ #category : 'accessing' }
TLBlocMenuEntry >> execute [

	^ action value
]

{ #category : 'accessing' }
TLBlocMenuEntry >> hasSubmenu [

	^ false
]

{ #category : 'accessing' }
TLBlocMenuEntry >> label [

	^ label
]

{ #category : 'accessing' }
TLBlocMenuEntry >> label: aString action: aBlock [

	label := aString.
	action := aBlock
]
