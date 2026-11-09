"
I am a theme of Telescope Bloc: the colors of what surrounds a visualization, which are not given by its style sheet. The canvas behind it, the toolbar and its buttons, the legend, the menus and the pop ups take their colors from me.
The colors of the nodes, of their labels and of the connections are the ones of the style sheet of the visualization: a theme does not change them.
#available answers an instance of each theme, and #default the one a visualization has unless it is given another one (see TLBlocConnector>>#theme:). A theme is a subclass which answers its #name and the colors of #colorSelectors.
"
Class {
	#name : 'TLBlocTheme',
	#superclass : 'Object',
	#category : 'Telescope-Bloc-Theme',
	#package : 'Telescope-Bloc',
	#tag : 'Theme'
}

{ #category : 'instance creation' }
TLBlocTheme class >> available [
	"An instance of each theme, in the order of their names"

	^ ((self allSubclasses reject: [ :class | class isAbstract ]) collect: [ :class | class new ]) asSortedCollection: [ :first :second | first name <= second name ]
]

{ #category : 'accessing' }
TLBlocTheme class >> colorSelectors [
	"The colors which a theme gives"

	^ #( #canvasColor #panelColor #panelBorderColor #legendColor #textColor #iconColor #buttonColor #buttonHoverColor #toggledButtonColor #toggledButtonHoverColor #menuColor #menuHoverColor
	     #popUpColor #popUpBorderColor #popUpTextColor #popUpShadowColor #swatchOutlineColor )
]

{ #category : 'instance creation' }
TLBlocTheme class >> default [
	"The theme of a visualization which is not given another one"

	^ TLBlocLightTheme new
]

{ #category : 'testing' }
TLBlocTheme class >> isAbstract [

	^ self == TLBlocTheme
]

{ #category : 'accessing' }
TLBlocTheme >> buttonColor [
	"The background of a button"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> buttonHoverColor [
	"The background of a button while the mouse is over it"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> canvasColor [
	"The background of the window, behind the visualization"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> iconColor [
	"The arrows drawn by the buttons, the menus and the legend"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> legendColor [
	"The background of the legend"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> menuColor [
	"The background of a menu"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> menuHoverColor [
	"The background of the line of a menu which the mouse is over"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> name [
	"The name of the theme, for a human"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> panelBorderColor [
	"The border of the toolbar, of its buttons, of the legend and of the menus"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> panelColor [
	"The background of the toolbar"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> popUpBorderColor [
	"The border of a pop up"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> popUpColor [
	"The background of a pop up or of a tooltip"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> popUpShadowColor [
	"The shadow of a pop up"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> popUpTextColor [
	"The text of a pop up"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> swatchOutlineColor [
	"The outline of the swatches of the legend which show a color"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> textColor [
	"The text of the buttons, of the legend and of the menus"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> toggledButtonColor [
	"The background of a button which is on"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
TLBlocTheme >> toggledButtonHoverColor [
	"The background of a button which is on, while the mouse is over it"

	^ self subclassResponsibility
]
