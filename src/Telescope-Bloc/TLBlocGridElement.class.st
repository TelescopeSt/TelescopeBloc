"
I am the grid of dots of the canvas of a Telescope visualization of Bloc, behind it in the window. My dots are a grid of the content of the visualization: they follow its panning and its zoom, which gives a sense of the space and of the zoom. When the content is zoomed out, I draw every other dot, and when it is zoomed in, I add dots between them, so that they are never closer than #minimumSpacing nor further than #maximumSpacing. My color is the grid color of the theme of the visualization. I do not take the mouse: a press on me is a press on the background, which pans. All my dots are one path, filled once.
"
Class {
	#name : 'TLBlocGridElement',
	#superclass : 'BlElement',
	#instVars : [
		'visualization'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'accessing' }
TLBlocGridElement class >> contentSpacing [
	"The distance between two dots in the coordinates of the content of the visualization"

	^ 20
]

{ #category : 'instance creation' }
TLBlocGridElement class >> for: aVisualization [

	^ self new
		  visualization: aVisualization;
		  yourself
]

{ #category : 'accessing' }
TLBlocGridElement class >> maximumSpacing [
	"The largest distance between two dots in the window"

	^ 48
]

{ #category : 'accessing' }
TLBlocGridElement class >> minimumSpacing [
	"The smallest distance between two dots in the window"

	^ 12
]

{ #category : 'drawing' }
TLBlocGridElement >> aeDrawGeometryOn: aeCanvas [
	"All the dots of the window, as one path filled once"

	| spacing origin radius |
	spacing := self dotSpacing.
	origin := self dotOrigin.
	radius := self dotRadius.
	aeCanvas pathFactory: [ :cairoContext |
			origin x to: self width by: spacing do: [ :x |
					origin y to: self height by: spacing do: [ :y |
							cairoContext moveToX: x + radius y: y.
							cairoContext circleCenterX: x y: y radius: radius ] ] ].
	(BlBackground paint: self dotColor) aeApplyTo: aeCanvas.
	aeCanvas setBorderOff.
	aeCanvas drawFigure
]

{ #category : 'accessing' }
TLBlocGridElement >> dotColor [

	^ visualization theme gridColor
]

{ #category : 'accessing' }
TLBlocGridElement >> dotOrigin [
	"The dot which is the nearest to the top left corner of the window: the origin of the content of the visualization is on a dot"

	| origin spacing |
	origin := visualization content localPointToGlobal: 0 @ 0.
	spacing := self dotSpacing.
	^ origin x \\ spacing @ (origin y \\ spacing)
]

{ #category : 'accessing' }
TLBlocGridElement >> dotRadius [

	^ 0.9
]

{ #category : 'accessing' }
TLBlocGridElement >> dotSpacing [
	"The distance between two dots in the window: the one of the content at the zoom of the visualization, doubled or halved until it is between the minimum and the maximum"

	| spacing |
	spacing := self class contentSpacing * visualization zoom.
	[ spacing < self class minimumSpacing ] whileTrue: [ spacing := spacing * 2 ].
	[ spacing > self class maximumSpacing ] whileTrue: [ spacing := spacing / 2 ].
	^ spacing
]

{ #category : 'initialization' }
TLBlocGridElement >> initialize [
	"As big as the window, behind the visualization, and transparent to the mouse"

	super initialize.
	self
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal matchParent.
				layoutConstraints vertical matchParent ];
		preventMeAndChildrenMouseEvents
]

{ #category : 'accessing' }
TLBlocGridElement >> visualization: aVisualization [

	visualization := aVisualization
]
