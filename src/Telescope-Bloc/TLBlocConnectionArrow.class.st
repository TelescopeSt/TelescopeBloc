"
I am an arrow of a connection other than its head: at the start of the line (TLBlocConnectionBaseArrow), or at its middle, along it (TLBlocConnectionMiddleArrow) or backwards (TLBlocConnectionMiddleReversedArrow). The connection asks for them from the substyles of its style sheet, named base, middle and middleReversed: there is one when the substyle has a shape which draws something. An arrow has the color of the line unless its substyle has its own. It is placed on the route of the connection: its outline, in the coordinates of the view, has its tip where it points, and its element is a child of the connection. The size is the one of the head.
"
Class {
	#name : 'TLBlocConnectionArrow',
	#superclass : 'Object',
	#instVars : [
		'shape',
		'color',
		'element',
		'outline'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
TLBlocConnectionArrow class >> arrowsFrom: aStyleSheet lineColor: aColor [
	"The arrows which the substyles of the style sheet of a connection ask for: those which have a shape which draws something. They have the color of the line, unless their substyle has its own"

	^ (self allSubclasses sorted: [ :first :second | first styleName <= second styleName ])
		  select: [ :arrowClass |
				  | substyle |
				  substyle := aStyleSheet > arrowClass styleName.
				  (substyle attributes includesKey: #shape) and: [ substyle shape ~= TLNoShape ] ]
		  thenCollect: [ :arrowClass |
				  | substyle |
				  substyle := aStyleSheet > arrowClass styleName.
				  arrowClass new
					  shape: substyle shape color: ((substyle attributes includesKey: #color)
							   ifTrue: [ substyle color ]
							   ifFalse: [ aColor ]);
					  yourself ]
]

{ #category : 'instance creation' }
TLBlocConnectionArrow class >> styleName [
	"The name of the substyle of a connection which gives the shape and the color of the arrow"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> color [

	^ color
]

{ #category : 'placing' }
TLBlocConnectionArrow >> directionOn: aRoute [
	"The unit vector along which the arrow points, or nil when the route has no such direction"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> element [
	"The element of the arrow, in the connection, or nil when the shape draws nothing"

	^ element
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> element: anElement [

	element := anElement
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> name [
	"The name of the substyle which defines the arrow"

	^ self class styleName
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> outline [
	"The Geometry project shape of the arrow, in the coordinates of the view, or nil when the shape draws nothing or the route is empty"

	^ outline
]

{ #category : 'placing' }
TLBlocConnectionArrow >> placeOn: aRoute size: aLength [
	"The outline of the arrow on the route, a square of the given side: its tip is where the arrow points. There is none when the route is empty or when the shape draws nothing"

	| direction |
	outline := nil.
	direction := self directionOn: aRoute.
	direction ifNil: [ ^ self ].
	outline := shape
		           headOutlineAt: (self tipOn: aRoute direction: direction size: aLength)
		           direction: direction
		           length: aLength
		           width: aLength
]

{ #category : 'accessing' }
TLBlocConnectionArrow >> shape: aTLShape color: aColor [

	shape := aTLShape.
	color := aColor
]

{ #category : 'placing' }
TLBlocConnectionArrow >> tipOn: aRoute direction: aDirection size: aLength [
	"The point which the arrow points to"

	^ self subclassResponsibility
]
