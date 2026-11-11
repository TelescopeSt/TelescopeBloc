"
I am the dark theme of Telescope Bloc: a dark canvas, dark toolbar, legend and menus, and light text. The colors of the nodes, of their labels and of the connections stay the ones of the style sheet of the visualization, which are made for a light canvas by default.
"
Class {
	#name : 'TLBlocDarkTheme',
	#superclass : 'TLBlocTheme',
	#category : 'Telescope-Bloc-Theme',
	#package : 'Telescope-Bloc',
	#tag : 'Theme'
}

{ #category : 'accessing' }
TLBlocDarkTheme >> buttonColor [

	^ Color r: 0.22 g: 0.23 b: 0.27
]

{ #category : 'accessing' }
TLBlocDarkTheme >> buttonHoverColor [

	^ Color r: 0.3 g: 0.32 b: 0.37
]

{ #category : 'accessing' }
TLBlocDarkTheme >> canvasColor [

	^ Color r: 0.12 g: 0.13 b: 0.15
]

{ #category : 'accessing' }
TLBlocDarkTheme >> gridColor [

	^ Color white alpha: 0.08
]

{ #category : 'accessing' }
TLBlocDarkTheme >> hoverOutlineColor [

	^ Color
		  r: 0.45
		  g: 0.65
		  b: 1
		  alpha: 0.85
]

{ #category : 'accessing' }
TLBlocDarkTheme >> iconColor [

	^ Color r: 0.7 g: 0.72 b: 0.76
]

{ #category : 'accessing' }
TLBlocDarkTheme >> legendColor [

	^ (Color r: 0.18 g: 0.19 b: 0.22) alpha: 0.92
]

{ #category : 'accessing' }
TLBlocDarkTheme >> menuColor [

	^ Color r: 0.18 g: 0.19 b: 0.22
]

{ #category : 'accessing' }
TLBlocDarkTheme >> menuHoverColor [
	"A tint of the outline of the node under the mouse"

	^ Color
		  r: 0.45
		  g: 0.65
		  b: 1
		  alpha: 0.22
]

{ #category : 'accessing' }
TLBlocDarkTheme >> name [

	^ 'Dark'
]

{ #category : 'accessing' }
TLBlocDarkTheme >> panelBorderColor [

	^ Color r: 0.33 g: 0.35 b: 0.39
]

{ #category : 'accessing' }
TLBlocDarkTheme >> panelColor [

	^ (Color r: 0.18 g: 0.19 b: 0.22) alpha: 0.9
]

{ #category : 'accessing' }
TLBlocDarkTheme >> popUpBorderColor [

	^ Color white alpha: 0.15
]

{ #category : 'accessing' }
TLBlocDarkTheme >> popUpColor [

	^ Color r: 0.26 g: 0.29 b: 0.35
]

{ #category : 'accessing' }
TLBlocDarkTheme >> popUpShadowColor [

	^ Color black alpha: 0.6
]

{ #category : 'accessing' }
TLBlocDarkTheme >> popUpTextColor [

	^ Color r: 0.96 g: 0.97 b: 0.98
]

{ #category : 'accessing' }
TLBlocDarkTheme >> swatchOutlineColor [

	^ Color white alpha: 0.35
]

{ #category : 'accessing' }
TLBlocDarkTheme >> textColor [

	^ Color r: 0.9 g: 0.91 b: 0.93
]

{ #category : 'accessing' }
TLBlocDarkTheme >> toggledButtonColor [

	^ Color r: 0.2 g: 0.33 b: 0.52
]

{ #category : 'accessing' }
TLBlocDarkTheme >> toggledButtonHoverColor [

	^ Color r: 0.25 g: 0.4 b: 0.62
]
