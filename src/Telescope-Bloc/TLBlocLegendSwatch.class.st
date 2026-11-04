"
I am the small drawing of a row of a legend: a box filled with a color, a box with a thick border, the shape of a node, a bar with the colors of a gradient, a line of the color and of the width of a connection, or an arrow for a height or a width. My class side builds each of them.
"
Class {
	#name : 'TLBlocLegendSwatch',
	#superclass : 'BlElement',
	#category : 'Telescope-Bloc-Legend',
	#package : 'Telescope-Bloc',
	#tag : 'Legend'
}

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> borderColor: aColor [
	"A small rounded box with a thick border of the color, and no fill"

	^ self new
		  extent: 26 @ 14;
		  geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		  background: Color transparent;
		  border: (BlBorder paint: aColor width: 3);
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> color: aColor [
	"A small rounded box filled with the color"

	^ self new
		  extent: 26 @ 14;
		  geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		  background: aColor;
		  border: (BlBorder paint: (Color black alpha: 0.3) width: 1);
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> gradient: aGradient [
	"A horizontal bar with the colors of the gradient, at the places of their levels"

	^ self new
		  extent: 30 @ 12;
		  geometry: (BlRoundedRectangleGeometry cornerRadius: 3);
		  background:
			  (BlLinearGradientPaint horizontal stops: (aGradient levelForColors collect: [ :levelAndColor | (aGradient percentageForLevel: levelAndColor key) -> levelAndColor value asColor ] as: Array));
		  border: (BlBorder paint: (Color black alpha: 0.3) width: 1);
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> heightArrow [
	"An arrow with a head at both ends, vertical"

	^ self new
		  extent: 10 @ 16;
		  geometry: (BlPolygonGeometry vertices: {
						   (5 @ 0).
						   (10 @ 5).
						   (6 @ 5).
						   (6 @ 11).
						   (10 @ 11).
						   (5 @ 16).
						   (0 @ 11).
						   (4 @ 11).
						   (4 @ 5).
						   (0 @ 5) });
		  background: Color darkGray;
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> line: aColor width: aWidth [
	"A short line of the color and of the width of a connection"

	^ self new
		  extent: 26 @ (aWidth max: 2);
		  background: aColor;
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> shape: aShape background: aBackgroundColor border: aBorderColor [
	"The shape of a node, as small as a swatch, with the colors of the node. A shape which draws nothing is an empty box"

	| outline |
	outline := aShape outlineOfExtent: 16 @ 16.
	^ self new
		  extent: 16 @ 16;
		  geometry: (outline
				   ifNil: [ BlEmptyGeometry new ]
				   ifNotNil: #asBlocGeometry);
		  background: aBackgroundColor;
		  border: (BlBorder paint: aBorderColor width: 1);
		  yourself
]

{ #category : 'instance creation' }
TLBlocLegendSwatch class >> widthArrow [
	"An arrow with a head at both ends, horizontal"

	^ self new
		  extent: 22 @ 10;
		  geometry: (BlPolygonGeometry vertices: {
						   (0 @ 5).
						   (5 @ 0).
						   (5 @ 4).
						   (17 @ 4).
						   (17 @ 0).
						   (22 @ 5).
						   (17 @ 10).
						   (17 @ 6).
						   (5 @ 6).
						   (5 @ 10) });
		  background: Color darkGray;
		  yourself
]
