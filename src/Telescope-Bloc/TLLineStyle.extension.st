Extension { #name : 'TLLineStyle' }

{ #category : '*Telescope-Bloc' }
TLLineStyle class >> blocBorderPaint: aPaint width: aWidth [
	"The Bloc border drawing a line of this style"

	^ BlBorder paint: aPaint width: aWidth
]

{ #category : '*Telescope-Bloc' }
TLLineStyle class >> hasParallelLineInBloc [
	"Whether the line of this style is drawn twice, side by side"

	^ false
]
