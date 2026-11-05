"
I am the toolbar of a visualization in a window, with a button to fit the visualization into the window, to zoom in, to zoom out, and to export it as a PNG or as a SVG. The visualization puts me in the root of its window, not in itself, so that the zoom and the panning do not move me, and I stay at the top right corner of the window, even when it is resized. The export buttons ask for the file in a dialog, in another process so that the window does not freeze.
"
Class {
	#name : 'TLBlocToolbar',
	#superclass : 'BlElement',
	#instVars : [
		'resizeHandler',
		'window'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocToolbar class >> for: aVisualization [
	"The toolbar of a visualization: fit it to the window, turn the auto fit on or off, zoom in, zoom out, and export it as a PNG or as a SVG, in a file the user chooses. The export buttons have an arrow down. Each button explains itself in a tooltip"

	| toolbar |
	toolbar := self new.
	(toolbar addButton: 'Fit' action: [ aVisualization fitIntoWindow ]) tooltip: 'Fit' , String cr , 'Scales and centers the visualization to fill the window'.
	(toolbar addToggleButton: 'Auto' action: [ :isOn | aVisualization autoFitOnLayout: isOn ])
		isOn: aVisualization autoFitOnLayout;
		tooltip: 'Auto fit' , String cr , 'On: the visualization fits the window each time its layout is updated' , String cr , 'Off: it stays where it is, even when its layout is updated'.
	(toolbar addButton: '+' action: [ aVisualization zoomIn ]) tooltip: 'Zoom in'.
	(toolbar addButton: '-' action: [ aVisualization zoomOut ]) tooltip: 'Zoom out'.
	(toolbar addButton: 'PNG' action: [ toolbar askForFileOfExtension: 'png' thenDo: [ :file | aVisualization exportAsPngTo: file ] ])
		tooltip: 'Export as a PNG image';
		addDownArrow.
	(toolbar addButton: 'SVG' action: [ toolbar askForFileOfExtension: 'svg' thenDo: [ :file | aVisualization exportAsSvgTo: file ] ])
		tooltip: 'Export as a SVG image';
		addDownArrow.
	^ toolbar
]

{ #category : 'accessing' }
TLBlocToolbar >> addButton: aString action: aBlock [
	"Answers the new button"

	| button |
	button := TLBlocToolbarButton label: aString action: aBlock.
	self addChild: button.
	^ button
]

{ #category : 'adding' }
TLBlocToolbar >> addToggleButton: aString action: aBlock [
	"Answers the new button, which is off. The block receives the new state each time it is clicked"

	| button |
	button := TLBlocToolbarToggleButton label: aString action: aBlock.
	self addChild: button.
	^ button
]

{ #category : 'export' }
TLBlocToolbar >> askForFileOfExtension: anExtension thenDo: aBlock [
	"The dialog is opened in another process: a click is handled by the process of the host of the window, which must not wait for the user"

	[
		(UIManager default chooseForSaveFileReference: 'Export the visualization as ' , anExtension asUppercase extensions: { anExtension } path: FileLocator home / ('visualization.' , anExtension))
			ifNotNil: aBlock ] fork
]

{ #category : 'accessing' }
TLBlocToolbar >> buttonLabeled: aString [

	^ self buttons detect: [ :button | button label = aString ]
]

{ #category : 'accessing' }
TLBlocToolbar >> buttons [
	"The buttons, from left to right"

	^ self children asArray
]

{ #category : 'initialization' }
TLBlocToolbar >> initialize [
	"A row of buttons, as big as its buttons"

	super initialize.
	self
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets all: 2);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
		background: (Color white alpha: 0.85);
		border: (BlBorder paint: Color lightGray width: 1);
		addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self placeInWindow ];
		addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :event | self installInWindow ];
		addEventHandlerOn: BlElementRemovedFromSceneGraphEvent do: [ :event | self uninstallFromWindow ]
]

{ #category : 'layout' }
TLBlocToolbar >> installInWindow [
	"The toolbar is placed again when the window is resized, and the window is laid out again"

	window := self parent.
	resizeHandler := window addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self placeInWindow ]
]

{ #category : 'layout' }
TLBlocToolbar >> placeInWindow [
	"The toolbar stays at the top right corner of the window, whatever its size. The window is the parent: a window is a basic layout, which does not place its children"

	| position |
	self parent ifNil: [ ^ self ].
	position := self parent extent x - self extent x - self windowMargin @ self windowMargin.
	self measuredBounds position = position ifFalse: [ self position: position ]
]

{ #category : 'layout' }
TLBlocToolbar >> uninstallFromWindow [

	(window isNotNil and: [ resizeHandler isNotNil ]) ifTrue: [ window removeEventHandler: resizeHandler ].
	window := nil.
	resizeHandler := nil
]

{ #category : 'layout' }
TLBlocToolbar >> windowMargin [
	"The space between the toolbar and the border of the window"

	^ 10
]
