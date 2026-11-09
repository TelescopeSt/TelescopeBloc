Class {
	#name : 'TLBlocConnectorThemeTest',
	#superclass : 'TLBlocConnectorTest',
	#instVars : [
		'theme'
	],
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> childOfRoot: aClass [

	^ self root children detect: [ :child | child class = aClass ]
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> nodeElement [

	^ connector elementFromTLDrawable: visualization allNodes first
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> open [
	"Opens three nodes in the dark theme, with a legend, a menu and a pop up on mouse over"

	visualization addNodesFromEntities: (1 to: 3).
	visualization legend descriptionForHeight: 'Height'.
	visualization addInteraction: ((TLCustomAction block: [ :node |  ]) withMenu: 'Do it').
	visualization addInteraction: (TLPopUpAction text: [ :entity | entity asString ]) onMouseOver.
	connector theme: theme.
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Theme'.
	self settle
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> root [

	^ connector view space root
]

{ #category : 'running' }
TLBlocConnectorThemeTest >> setUp [

	super setUp.
	theme := TLBlocDarkTheme new
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> settle [

	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testArrowOfAButtonHasTheIconColorOfTheTheme [

	| button |
	self open.
	button := connector view toolbar buttonLabeled: 'PNG'.
	self assert: button icon background paint color equals: theme iconColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testCanvasHasTheColorOfTheDefaultThemeWithoutTheme [

	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Theme'.
	self settle.
	self assert: self root background paint color equals: TLBlocTheme default canvasColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testCanvasHasTheColorOfTheTheme [

	self open.
	self assert: self root background paint color equals: theme canvasColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testLegendHasTheColorsOfTheTheme [

	| legend row |
	self open.
	legend := self childOfRoot: TLBlocLegendElement.
	row := legend rows first.
	self assert: legend background paint color equals: theme legendColor.
	self assert: legend border paint color equals: theme panelBorderColor.
	self assert: (self textColorOf: (self textElementIn: row)) equals: theme textColor.
	self assert: row swatch background paint color equals: theme iconColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testMenuHasTheColorsOfTheTheme [

	| menu item |
	self open.
	self nodeElement fireEvent: (BlMouseDownEvent new
			 position: 100 @ 100;
			 screenPosition: 800 @ 600;
			 button: BlMouseButton secondary;
			 yourself).
	self settle.
	menu := (self childOfRoot: TLBlocMenuPopup) children detect: [ :child | child class = TLBlocMenuElement ].
	item := menu items first.
	self assert: menu background paint color equals: theme menuColor.
	self assert: menu border paint color equals: theme panelBorderColor.
	self assert: (self textColorOf: (self textElementIn: item)) equals: theme textColor.
	item dispatchEvent: BlMouseEnterEvent new.
	self assert: item background paint color equals: theme menuHoverColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testPopUpHasTheColorsOfTheTheme [

	| popUp |
	self open.
	self nodeElement dispatchEvent: BlMouseEnterEvent new.
	self settle.
	popUp := self childOfRoot: TLBlocPopUpElement.
	self assert: popUp background paint color equals: theme popUpColor.
	self assert: popUp border paint color equals: theme popUpBorderColor.
	self assert: (self textColorOf: popUp children first) equals: theme popUpTextColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testToggledButtonHasTheToggledColorOfTheTheme [

	| button |
	self open.
	button := connector view toolbar buttonLabeled: 'Auto'.
	button isOn: true.
	self assert: button background paint color equals: theme toggledButtonColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testToolbarButtonUnderTheMouseHasTheHoverColorOfTheTheme [

	| button |
	self open.
	button := connector view toolbar buttonLabeled: 'Fit'.
	button dispatchEvent: BlMouseEnterEvent new.
	self assert: button background paint color equals: theme buttonHoverColor.
	button dispatchEvent: BlMouseLeaveEvent new.
	self assert: button background paint color equals: theme buttonColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testToolbarHasTheColorsOfTheTheme [

	| toolbar button |
	self open.
	toolbar := connector view toolbar.
	button := toolbar buttonLabeled: 'Fit'.
	self assert: toolbar background paint color equals: theme panelColor.
	self assert: toolbar border paint color equals: theme panelBorderColor.
	self assert: button background paint color equals: theme buttonColor.
	self assert: (self textColorOf: (self textElementIn: button)) equals: theme textColor
]

{ #category : 'tests' }
TLBlocConnectorThemeTest >> testTooltipOfAButtonHasTheColorsOfTheTheme [

	| popUp |
	self open.
	(connector view toolbar buttonLabeled: 'Fit') showTooltip.
	self settle.
	popUp := self childOfRoot: TLBlocPopUpElement.
	self assert: popUp background paint color equals: theme popUpColor
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> textColorOf: aTextElement [
	"The color of the text of the element, or nil when the text has none"

	^ ((aTextElement text attributesAt: 1)
		   detect: [ :attribute | attribute isKindOf: BlTextForegroundAttribute ]
		   ifNone: [ nil ]) ifNotNil: #paint
]

{ #category : 'helpers' }
TLBlocConnectorThemeTest >> textElementIn: anElement [

	^ anElement children detect: [ :child | child class = BlTextElement ]
]
