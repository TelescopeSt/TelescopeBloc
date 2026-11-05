"
I am the element of an entry of a Telescope legend: the rows of the entry one above the other. A static entry, such as a color or a height, has one row, and a dynamic entry has one for each description of the nodes it describes.
"
Class {
	#name : 'TLBlocLegendEntryElement',
	#superclass : 'BlElement',
	#category : 'Telescope-Bloc-Legend',
	#package : 'Telescope-Bloc',
	#tag : 'Legend'
}

{ #category : 'initialization' }
TLBlocLegendEntryElement >> addRow: aSwatch label: aString [

	self addChild: (TLBlocLegendRow swatch: aSwatch label: aString)
]

{ #category : 'initialization' }
TLBlocLegendEntryElement >> initialize [
	"The rows of an entry of the legend, one above the other"

	super initialize.
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ]
]

{ #category : 'accessing' }
TLBlocLegendEntryElement >> rows [
	"The rows of the entry: a static entry has one, a dynamic entry has one for each description"

	^ self children asArray
]
