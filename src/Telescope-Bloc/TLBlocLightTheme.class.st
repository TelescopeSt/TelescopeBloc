"
I am the light theme of Telescope Bloc, the default one: a white canvas, light toolbar, legend and menus, and dark pop ups.
"
Class {
	#name : 'TLBlocLightTheme',
	#superclass : 'TLBlocTheme',
	#category : 'Telescope-Bloc-Theme',
	#package : 'Telescope-Bloc',
	#tag : 'Theme'
}

{ #category : 'accessing' }
TLBlocLightTheme >> buttonColor [

	^ Color white
]

{ #category : 'accessing' }
TLBlocLightTheme >> buttonHoverColor [

	^ Color veryLightGray
]

{ #category : 'accessing' }
TLBlocLightTheme >> canvasColor [

	^ Color white
]

{ #category : 'accessing' }
TLBlocLightTheme >> gridColor [

	^ Color gray alpha: 0.2
]

{ #category : 'accessing' }
TLBlocLightTheme >> hoverOutlineColor [

	^ Color
		  r: 0.2
		  g: 0.45
		  b: 0.9
		  alpha: 0.8
]

{ #category : 'accessing' }
TLBlocLightTheme >> iconColor [

	^ Color darkGray
]

{ #category : 'accessing' }
TLBlocLightTheme >> legendColor [

	^ Color white alpha: 0.9
]

{ #category : 'accessing' }
TLBlocLightTheme >> menuColor [

	^ Color white
]

{ #category : 'accessing' }
TLBlocLightTheme >> menuHoverColor [
	"A light tint of the outline of the node under the mouse"

	^ Color
		  r: 0.2
		  g: 0.45
		  b: 0.9
		  alpha: 0.14
]

{ #category : 'accessing' }
TLBlocLightTheme >> name [

	^ 'Light'
]

{ #category : 'accessing' }
TLBlocLightTheme >> panelBorderColor [

	^ Color lightGray
]

{ #category : 'accessing' }
TLBlocLightTheme >> panelColor [

	^ Color white alpha: 0.85
]

{ #category : 'accessing' }
TLBlocLightTheme >> popUpBorderColor [

	^ Color white alpha: 0.12
]

{ #category : 'accessing' }
TLBlocLightTheme >> popUpColor [

	^ Color r: 0.14 g: 0.17 b: 0.24
]

{ #category : 'accessing' }
TLBlocLightTheme >> popUpShadowColor [

	^ Color black alpha: 0.35
]

{ #category : 'accessing' }
TLBlocLightTheme >> popUpTextColor [

	^ Color r: 0.94 g: 0.96 b: 0.99
]

{ #category : 'accessing' }
TLBlocLightTheme >> swatchOutlineColor [

	^ Color black alpha: 0.3
]

{ #category : 'accessing' }
TLBlocLightTheme >> textColor [

	^ Color black
]

{ #category : 'accessing' }
TLBlocLightTheme >> toggledButtonColor [

	^ Color r: 0.78 g: 0.88 b: 1.0
]

{ #category : 'accessing' }
TLBlocLightTheme >> toggledButtonHoverColor [

	^ Color r: 0.68 g: 0.82 b: 0.98
]
