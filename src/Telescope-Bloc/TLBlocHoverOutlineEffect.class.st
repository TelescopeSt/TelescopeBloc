"
I outline the node under the mouse: I draw a ring of my color and width around the geometry of the node, outside of it, below the node. I only make the node be drawn again: I change neither its size nor the layout.
"
Class {
	#name : 'TLBlocHoverOutlineEffect',
	#superclass : 'BlElementEffect',
	#instVars : [
		'color',
		'width'
	],
	#category : 'Telescope-Bloc',
	#package : 'Telescope-Bloc'
}

{ #category : 'instance creation' }
TLBlocHoverOutlineEffect class >> color: aColor width: aNumber [

	^ self new
		  color: aColor width: aNumber;
		  yourself
]

{ #category : 'drawing' }
TLBlocHoverOutlineEffect >> aeDrawBelow: aBlElement on: aeCanvas [
	"The ring is the border of the geometry of the element, outside of it. It is drawn before the element, which may clip its children to its geometry"

	aBlElement geometry aeApplyTo: aeCanvas element: aBlElement.
	aeCanvas
		setBackgroundOff;
		setOutskirtsOutside.
	aBlElement geometry aeApplyWithOutsideBorderTo: aeCanvas element: aBlElement borderWidth: width.
	aeCanvas setBorderBlock: [
			aeCanvas
				setSourceColor: color;
				setBorderWidth: width ].
	aeCanvas drawFigure
]

{ #category : 'accessing' }
TLBlocHoverOutlineEffect >> color [

	^ color
]

{ #category : 'initialization' }
TLBlocHoverOutlineEffect >> color: aColor width: aNumber [

	color := aColor.
	width := aNumber
]

{ #category : 'geometry' }
TLBlocHoverOutlineEffect >> computeBounds: aBlBounds [
	"The ring is outside of the geometry: the area drawn again when the node changes includes it"

	^ aBlBounds expandByMargin: (BlInsets all: width)
]

{ #category : 'accessing' }
TLBlocHoverOutlineEffect >> width [

	^ width
]
