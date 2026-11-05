Class {
	#name : 'TLBlocConnectorLegendTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'tests' }
TLBlocConnectorLegendTest >> evenOdd [

	^ [ :entity |
		  entity even
			  ifTrue: [ 'even' ]
			  ifFalse: [ 'odd' ] ]
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> evenOddColors [
	"The nodes with an even entity are red, the others blue"

	visualization styleSheet backgroundColor: [ :entity |
			entity even
				ifTrue: [ Color red ]
				ifFalse: [ Color blue ] ]
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> labels [

	^ self rows collect: #label as: Array
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> legendElement [

	^ connector view space root children
		  detect: [ :child | child class = TLBlocLegendElement ]
		  ifNone: [ nil ]
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> openWithNodes: aNumber [
	"Opens the visualization, with the given number of nodes of the entities 1, 2... in a window of 500 by 400"

	visualization addNodesFromEntities: (1 to: aNumber).
	connector open: visualization inWindowSized: 500 @ 400 titled: 'Legend'.
	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> rowLabeled: aString [

	^ self rows detect: [ :row | row label = aString ]
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> rows [

	^ self legendElement
		  ifNil: [ #(  ) ]
		  ifNotNil: #rows
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testBorderColorEntryHasASwatchWithABorderOfItsColor [

	visualization legend description: 'Alert' forBorderColor: Color orange.
	self openWithNodes: 3.
	self assert: (self rowLabeled: 'Alert') swatch border paint color equals: Color orange
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testBorderShapeEntryHasASwatchOfItsShape [

	visualization legend description: 'Round' forBorderShape: TLEllipse.
	self openWithNodes: 3.
	self assert: (self rowLabeled: 'Round') swatch geometry class equals: (TLEllipse outlineOfExtent: 10 @ 10) asBlocGeometry class
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testColorEntryHasASwatchOfItsColor [

	visualization legend description: 'Dead' forColor: Color red.
	self openWithNodes: 3.
	self assert: (self rowLabeled: 'Dead') swatch background paint color equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testConnectionStyleEntryHasALineOfItsColor [

	visualization legend description: 'Uses' forConnectionStyle: (TLStyleSheet new
			 color: Color green;
			 yourself).
	self openWithNodes: 3.
	self assert: (self rowLabeled: 'Uses') swatch background paint color equals: Color green
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testGradientEntryHasABarWithTheColorsOfTheGradient [

	visualization legend description: 'Age' forGradient: ((TLGradient new
			  levelProperty: #yourself;
			  yourself)
			 to: Color red at: 1;
			 to: Color blue at: 10;
			 yourself).
	self openWithNodes: 3.
	self assert: (self rowLabeled: 'Age') swatch background paint class equals: BlLinearGradientPaint
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testHeightAndWidthDescriptionsAreRowsOfTheLegend [

	visualization legend
		descriptionForHeight: 'Text explaining height';
		descriptionForWidth: 'Text explaining width'.
	self openWithNodes: 3.
	self assert: self labels equals: #( 'Text explaining height' 'Text explaining width' )
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testLegendDemoShowsEveryKindOfEntryOfTheNodes [
	"The height and the width, a gradient, then one row for each description of the dynamic entries (background, border color, shape), and a static color"

	| demo |
	demo := TLDemos exampleLegend.
	demo generator: connector.
	connector open: demo inWindowSized: 900 @ 700 titled: 'Legend'.
	connector view space settleForDuration: 2 seconds.
	self assert: self labels equals: #( 'Text explaining height' 'Text explaining width' 'Value' 'Multiple of 10' 'Other' 'Not prime' 'Prime' 'Even' 'Odd' 'Under the mouse' )
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testLegendDemoSwatchesMatchTheNodes [

	| demo |
	demo := TLDemos exampleLegend.
	demo generator: connector.
	connector open: demo inWindowSized: 900 @ 700 titled: 'Legend'.
	connector view space settleForDuration: 2 seconds.
	self assert: (self rowLabeled: 'Value') swatch background paint class equals: BlLinearGradientPaint.
	self assert: (self rowLabeled: 'Prime') swatch border paint color equals: Color blue.
	self assert: (self rowLabeled: 'Not prime') swatch border paint color equals: Color black.
	self assert: (self rowLabeled: 'Under the mouse') swatch background paint color equals: Color orange
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testLegendIsInTheBottomLeftCornerOfTheWindow [

	| bounds |
	visualization legend description: 'Dead' forColor: Color red.
	self openWithNodes: 3.
	bounds := self legendElement boundsInSpace asRectangle.
	self assert: bounds left equals: self legendElement windowMargin.
	self assert: bounds bottom equals: 400 - self legendElement windowMargin
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testLegendIsNotMovedByTheZoom [

	| before |
	visualization legend description: 'Dead' forColor: Color red.
	self openWithNodes: 3.
	before := self legendElement boundsInSpace asRectangle.
	connector view zoomBy: 0.5 around: 0 @ 0.
	connector view space settleForDuration: 300 milliSeconds.
	self assert: self legendElement boundsInSpace asRectangle equals: before
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testNodeBackgroundEntryHasARowForEachDescription [

	self evenOddColors.
	visualization legend backgroundDescription: self evenOdd forNodes: [ visualization allNodes ].
	self openWithNodes: 4.
	self assert: self labels equals: #( 'even' 'odd' ).
	self assert: (self rowLabeled: 'even') swatch background paint color equals: Color red.
	self assert: (self rowLabeled: 'odd') swatch background paint color equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testNodeBorderColorEntryHasARowForEachDescription [

	visualization styleSheet borderColor: [ :entity |
			entity even
				ifTrue: [ Color green ]
				ifFalse: [ Color black ] ].
	visualization legend borderColorDescription: self evenOdd forNodes: [ visualization allNodes ].
	self openWithNodes: 4.
	self assert: self labels equals: #( 'even' 'odd' ).
	self assert: (self rowLabeled: 'even') swatch border paint color equals: Color green.
	self assert: (self rowLabeled: 'odd') swatch border paint color equals: Color black
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testNodeShapeEntryHasARowForEachDescription [

	visualization styleSheet shape: [ :entity |
			entity even
				ifTrue: [ TLEllipse ]
				ifFalse: [ TLRectangle ] ].
	visualization legend nodeShapeDescription: self evenOdd forNodes: [ visualization allNodes ].
	self openWithNodes: 4.
	self assert: self labels equals: #( 'even' 'odd' ).
	self assert: (self rowLabeled: 'even') swatch geometry class equals: (TLEllipse outlineOfExtent: 10 @ 10) asBlocGeometry class.
	self assert: (self rowLabeled: 'odd') swatch geometry class equals: (TLRectangle outlineOfExtent: 10 @ 10) asBlocGeometry class
]

{ #category : 'tests' }
TLBlocConnectorLegendTest >> testThereIsNoLegendWithoutEntries [

	self openWithNodes: 3.
	self assert: self legendElement isNil
]
