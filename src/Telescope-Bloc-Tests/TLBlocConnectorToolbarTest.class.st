Class {
	#name : 'TLBlocConnectorToolbarTest',
	#superclass : 'TLBlocConnectorNavigationTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> click: aLabel [

	(self toolbar buttonLabeled: aLabel) dispatchEvent: BlClickEvent new.
	self settle
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> contentPointUnderTheCenterOfTheWindow [
	"The point of the visualization, in its own coordinates, which is at the center of the window"

	^ connector view space extent / 2 - connector view measuredBounds position / connector view zoom
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> exportFile: anExtension [

	^ FileLocator temp / ('telescope-bloc-export-' , UUID new asString36 , '.' , anExtension)
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testExportButtonsHaveAnArrowDownNextToTheirLabel [

	#( 'PNG' 'SVG' ) do: [ :label |
			| button |
			button := self toolbar buttonLabeled: label.
			self assert: button icon isNotNil.
			self assert: button children size equals: 2.
			self assert: button children last identicalTo: button icon.
			self assert: button icon geometry class equals: BlPolygonGeometry ]
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testFitButtonFitsTheVisualizationAgain [

	self click: '+'.
	self click: '+'.
	self click: 'Fit'.
	self assert: connector view zoom equals: 1
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testOtherButtonsHaveNoIcon [

	#( 'Fit' '+' '-' ) do: [ :label | self assert: (self toolbar buttonLabeled: label) icon isNil ]
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testToolbarHasTheNavigationAndExportActions [

	self assert: (self toolbar buttons collect: #label) asArray equals: #( 'Fit' '+' '-' 'PNG' 'SVG' )
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testToolbarIsInTheWindowAndNotPannedWithTheVisualization [

	self assert: self toolbar isNotNil.
	self assert: self toolbar parent identicalTo: connector view space root
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testVisualizationCanBeExportedAsPng [

	| file |
	file := self exportFile: 'png'.
	[
		connector view exportAsPngTo: file.
		self assert: file exists.
		self assert: (file binaryReadStreamDo: [ :stream | stream next: 4 ]) equals: #( 137 80 78 71 ) asByteArray ] ensure: [ file ensureDelete ]
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testVisualizationCanBeExportedAsSvg [

	| file |
	file := self exportFile: 'svg'.
	[
		connector view exportAsSvgTo: file.
		self assert: file exists.
		self assert: (file contents includesSubstring: '<svg') ] ensure: [ file ensureDelete ]
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testZoomButtonsKeepTheCenterOfTheWindowFixed [

	| before |
	before := self contentPointUnderTheCenterOfTheWindow.
	self click: '+'.
	self assert: (self contentPointUnderTheCenterOfTheWindow - before) abs < (0.5 @ 0.5)
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testZoomInButtonZoomsIn [

	self click: '+'.
	self assert: connector view zoom > 1
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> testZoomOutButtonZoomsOut [

	self click: '-'.
	self assert: connector view zoom < 1
]

{ #category : 'tests' }
TLBlocConnectorToolbarTest >> toolbar [

	^ connector view toolbar
]
