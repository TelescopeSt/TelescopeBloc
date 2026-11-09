Class {
	#name : 'TLBlocThemeTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Theme',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Theme'
}

{ #category : 'tests' }
TLBlocThemeTest >> testAvailableThemesAreTheLightTheDarkAndTheDarkBlueOnes [

	self assert: (TLBlocTheme available collect: #class) asSet equals: {
			TLBlocLightTheme.
			TLBlocDarkTheme.
			TLBlocDarkBlueTheme } asSet
]

{ #category : 'tests' }
TLBlocThemeTest >> testDarkBlueThemeHasADarkBlueCanvasAndALightText [
	"It goes with the dark blue theme of Pharo"

	| theme |
	theme := TLBlocDarkBlueTheme new.
	self assert: theme canvasColor luminance < 0.3.
	self assert: theme canvasColor blue > theme canvasColor red.
	self assert: theme textColor luminance > 0.7
]

{ #category : 'tests' }
TLBlocThemeTest >> testDarkThemeHasADarkCanvasAndALightText [

	| theme |
	theme := TLBlocDarkTheme new.
	self assert: theme canvasColor luminance < 0.3.
	self assert: theme textColor luminance > 0.7
]

{ #category : 'tests' }
TLBlocThemeTest >> testDefaultThemeIsTheLightOne [

	self assert: TLBlocTheme default class equals: TLBlocLightTheme
]

{ #category : 'tests' }
TLBlocThemeTest >> testEveryThemeGivesAllItsColors [

	TLBlocTheme available do: [ :theme | TLBlocTheme colorSelectors do: [ :selector | self assert: (theme perform: selector) isColor description: theme name , ' has no ' , selector ] ]
]

{ #category : 'tests' }
TLBlocThemeTest >> testLightThemeKeepsTheColorsTelescopeBlocHad [

	| theme |
	theme := TLBlocLightTheme new.
	self assert: theme canvasColor equals: Color white.
	self assert: theme textColor equals: Color black.
	self assert: theme buttonColor equals: Color white
]

{ #category : 'tests' }
TLBlocThemeTest >> testThemesHaveDifferentNames [

	| names |
	names := TLBlocTheme available collect: #name.
	self assert: names asSet size equals: names size.
	names do: [ :name | self denyEmpty: name ]
]
