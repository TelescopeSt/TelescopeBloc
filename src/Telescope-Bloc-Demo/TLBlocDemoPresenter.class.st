"
I am a Spec browser of the demos of TLDemos rendered by the Bloc connector. I list the demos, filter them with the filters they declare, show the visualization in a Bloc canvas, and show the description of the demo (its tlDescription pragma) and its source below. When a demo fails, I replace the visualization by the stack of the error. The list shows the names of the demos for a human (TLDemoCatalogue class>>displayNameOf:, which drops the example prefix and splits the camel case), in the alphabetical order of these names, and its items are the selectors which run the demos.
"
Class {
	#name : 'TLBlocDemoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'demoList',
		'filterList',
		'canvas',
		'code',
		'description',
		'themeList'
	],
	#category : 'Telescope-Bloc-Demo-Browser',
	#package : 'Telescope-Bloc-Demo',
	#tag : 'Browser'
}

{ #category : 'world menu' }
TLBlocDemoPresenter class >> menuCommandOn: aBuilder [
	"Adds the Bloc demo browser to the Telescope menu of the world menu"

	<worldMenu>
	(aBuilder item: #'Telescope bloc demo browser')
		parent: #Telescope;
		order: 2;
		iconName: #go;
		help: 'Browse the demos of Telescope rendered with the Bloc connector';
		action: [ self open ]
]

{ #category : 'instance creation' }
TLBlocDemoPresenter class >> open [

	^ self new open
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> canvas [
	^ canvas
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> code [
	^ code
]

{ #category : 'initialization' }
TLBlocDemoPresenter >> connectPresenters [

	demoList whenSelectedItemChangedDo: [ :selector | selector ifNotNil: [ self runDemo: selector ] ].
	themeList whenSelectedItemChangedDo: [ :theme | demoList selectedItem ifNotNil: [ :selector | self runDemo: selector ] ].
	filterList whenSelectedItemChangedDo: [ :filter | demoList items: (self demosMatching: filter) ]
]

{ #category : 'layout' }
TLBlocDemoPresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 300;
				   add: (SpBoxLayout newTopToBottom
						    add: filterList expand: false;
						    add: themeList expand: false;
						    add: demoList;
						    yourself);
				   add: canvas;
				   yourself);
		  add: (SpBoxLayout newTopToBottom
				   add: description expand: false;
				   add: code;
				   yourself);
		  yourself
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> demoList [
	^ demoList
]

{ #category : 'operations' }
TLBlocDemoPresenter >> demosMatching: aFilterSymbol [
	"The demos declaring the filter, or all the demos for #all, in the alphabetical order of their names"

	^ (TLDemoCatalogue sortedByDisplayName: (aFilterSymbol = #all
			    ifTrue: [ TLDemoCatalogue demoSelectors ]
			    ifFalse: [ TLDemoCatalogue demoSelectorsWithFilter: aFilterSymbol ])) asArray
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> description [
	"The text which describes the selected demo"

	^ description
]

{ #category : 'operations' }
TLBlocDemoPresenter >> errorElementFor: anError [
	"A red panel showing the stack of the error, one text element per line because Bloc does not break a text at line feeds"

	| element |
	element := BlElement new.
	element background: Color lightRed.
	element layout: BlLinearLayout vertical.
	element constraintsDo: [ :constraints |
			constraints horizontal matchParent.
			constraints vertical matchParent ].
	(self stackTextOf: anError) lines do: [ :line | element addChild: (BlTextElement new text: line asRopedText) ].
	^ element
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> filterList [
	^ filterList
]

{ #category : 'initialization' }
TLBlocDemoPresenter >> initializePresenters [
	"The list shows the names of the demos for a human, in alphabetical order, and its items are the selectors which run them. The demos are shown in the theme chosen in the list of the themes, the default one at first"

	demoList := self newList display: [ :selector | TLDemoCatalogue displayNameOf: selector ].
	filterList := self newDropList items: { #all } , TLDemoCatalogue filterSymbols.
	themeList := self newDropList
		             items: TLBlocTheme available asArray;
		             display: [ :theme | theme name ];
		             yourself.
	themeList selectItem: (themeList items detect: [ :theme | theme class = TLBlocTheme default class ]).
	canvas := self instantiate: SpBlSpaceInMorphPresenter.
	description := self newText beNotEditable.
	code := self newCode beNotEditable.
	demoList items: (self demosMatching: #all)
]

{ #category : 'initialization' }
TLBlocDemoPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Telescope Bloc Demos';
		initialExtent: 1200 @ 800
]

{ #category : 'running' }
TLBlocDemoPresenter >> runDemo: aDemoSelector [
	"Renders the demo in the canvas, in the chosen theme, or shows its error"

	| connector visualization demoMethod |
	description text: (TLDemoCatalogue descriptionOf: aDemoSelector).
	demoMethod := TLDemos class >> aDemoSelector.
	code beForMethod: demoMethod.
	code text: demoMethod sourceCode.
	[
		connector := TLBlocConnector new.
		connector theme: self selectedTheme.
		visualization := TLDemos perform: aDemoSelector.
		visualization generator: connector.
		visualization generateWith: connector.
		canvas space root
			background: self selectedTheme canvasColor;
			removeChildren;
			addChild: connector view ]
		on: Error
		do: [ :error | self showError: error ]
]

{ #category : 'running' }
TLBlocDemoPresenter >> selectedTheme [
	"The theme the demos are shown in"

	^ themeList selectedItem ifNil: [ TLBlocTheme default ]
]

{ #category : 'running' }
TLBlocDemoPresenter >> showError: anError [
	"Replaces the visualization by the stack of the error"

	canvas space root
		removeChildren;
		addChild: (self errorElementFor: anError)
]

{ #category : 'operations' }
TLBlocDemoPresenter >> stackTextOf: anError [
	"The error message followed by the first frames of its stack, one per line. The full stack is in the debugger"

	| stream context count |
	stream := WriteStream on: String new.
	stream
		nextPutAll: anError class name;
		nextPutAll: ': ';
		nextPutAll: anError description.
	count := 0.
	context := anError signalerContext.
	[ context isNotNil and: [ count < 30 ] ] whileTrue: [
			stream
				lf;
				print: context.
			count := count + 1.
			context := context sender ].
	^ stream contents
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> themeList [

	^ themeList
]
