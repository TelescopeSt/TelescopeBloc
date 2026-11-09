"
I am the dark blue theme of Telescope Bloc, which goes with the dark blue theme of Pharo (DarkBlueTheme): a dark blue canvas, blue toolbar, legend and menus, and white text. My colors are the ones of that theme, copied, so that I do not depend on it. The colors of the nodes, of their labels and of the connections stay the ones of the style sheet of the visualization, which are made for a light canvas by default.
"
Class {
	#name : 'TLBlocDarkBlueTheme',
	#superclass : 'TLBlocTheme',
	#category : 'Telescope-Bloc-Theme',
	#package : 'Telescope-Bloc',
	#tag : 'Theme'
}

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> buttonColor [

	^ Color r: 0.227 g: 0.273 b: 0.37
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> buttonHoverColor [

	^ Color r: 0.257 g: 0.303 b: 0.451
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> canvasColor [

	^ Color r: 0.116 g: 0.147 b: 0.21
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> iconColor [

	^ Color r: 0.839 g: 0.846 b: 0.878
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> legendColor [

	^ (Color r: 0.188 g: 0.231 b: 0.309) alpha: 0.92
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> menuColor [

	^ Color r: 0.169 g: 0.208 b: 0.29
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> menuHoverColor [

	^ Color r: 0.307 g: 0.337 b: 0.474
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> name [

	^ 'Dark blue'
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> panelBorderColor [

	^ Color r: 0.294 g: 0.341 b: 0.491
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> panelColor [

	^ (Color r: 0.188 g: 0.231 b: 0.309) alpha: 0.9
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> popUpBorderColor [

	^ Color r: 0.294 g: 0.341 b: 0.491
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> popUpColor [

	^ Color r: 0.169 g: 0.208 b: 0.29
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> popUpShadowColor [

	^ Color black alpha: 0.6
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> popUpTextColor [

	^ Color white
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> swatchOutlineColor [

	^ Color white alpha: 0.35
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> textColor [

	^ Color white
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> toggledButtonColor [

	^ Color r: 0.307 g: 0.337 b: 0.474
]

{ #category : 'accessing' }
TLBlocDarkBlueTheme >> toggledButtonHoverColor [

	^ Color r: 0.319 g: 0.369 b: 0.531
]
