Extension { #name : 'TLDoubleLineStyle' }

{ #category : '*Telescope-Bloc' }
TLDoubleLineStyle class >> blocBorderPaint: aPaint width: aWidth [
	"Two lines and the gap between them, each a third of the width, take the width of a solid line. This is the border of one of the two lines"

	^ BlBorder paint: aPaint width: aWidth / 3.0
]

{ #category : '*Telescope-Bloc' }
TLDoubleLineStyle class >> hasParallelLineInBloc [

	^ true
]
