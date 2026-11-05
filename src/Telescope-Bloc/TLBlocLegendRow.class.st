"
I am a row of a legend: a swatch, centered in a cell of a fixed width so that the texts of all the rows are aligned, and the text which says what the swatch shows.
"
Class {
	#name : 'TLBlocLegendRow',
	#superclass : 'BlElement',
	#instVars : [
		'swatch',
		'label'
	],
	#category : 'Telescope-Bloc-Legend',
	#package : 'Telescope-Bloc',
	#tag : 'Legend'
}

{ #category : 'instance creation' }
TLBlocLegendRow class >> swatch: aSwatch label: aString [

	^ self new
		  swatch: aSwatch label: aString;
		  yourself
]

{ #category : 'initialization' }
TLBlocLegendRow >> initialize [
	"A swatch and a text side by side, as big as their content"

	super initialize.
	self
		layout: (BlLinearLayout horizontal
				 alignCenterLeft;
				 yourself);
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets
				 top: 2
				 left: 0
				 bottom: 2
				 right: 0)
]

{ #category : 'accessing' }
TLBlocLegendRow >> label [
	"The text of the row"

	^ label
]

{ #category : 'accessing' }
TLBlocLegendRow >> swatch [
	"The small drawing which shows what the row talks about"

	^ swatch
]

{ #category : 'initialization' }
TLBlocLegendRow >> swatch: aSwatch label: aString [
	"The text describes what the swatch shows. The swatch is centered in a cell of a fixed width, so that the texts of all the rows are aligned"

	| cell |
	swatch := aSwatch.
	label := aString.
	cell := BlElement new
		        layout: (BlLinearLayout horizontal
				         alignCenter;
				         yourself);
		        constraintsDo: [ :layoutConstraints |
				        layoutConstraints horizontal exact: self swatchCellWidth.
				        layoutConstraints vertical fitContent ];
		        yourself.
	cell addChild: aSwatch.
	self addChild: cell.
	self addChild: (BlTextElement new
			 text: (aString asRopedText fontSize: 12);
			 margin: (BlInsets left: 8);
			 yourself)
]

{ #category : 'initialization' }
TLBlocLegendRow >> swatchCellWidth [
	"The width of the cell of the swatch: the widest swatch fits in it"

	^ 30
]
