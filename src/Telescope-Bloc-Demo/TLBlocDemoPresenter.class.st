"
I am a Spec browser of the demos of TLDemos rendered by the Bloc connector. I list the demos, filter them with the filters they declare, show the visualization in a Bloc canvas and the source of the demo below. When a demo fails, I replace the visualization by the stack of the error and I enable a button to debug it.
"
Class {
	#name : 'TLBlocDemoPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'demoList',
		'filterList',
		'canvas',
		'code',
		'errorText',
		'debugButton',
		'lastError'
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
	filterList whenSelectedItemChangedDo: [ :filter | demoList items: (self demosMatching: filter) ]
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> debugButton [
	^ debugButton
]

{ #category : 'operations' }
TLBlocDemoPresenter >> debugLastError [
	"Opens a debugger on the context of the last error of a demo"

	lastError ifNotNil: [ :error | error debug ]
]

{ #category : 'layout' }
TLBlocDemoPresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 300;
				   add: (SpBoxLayout newTopToBottom
						    add: filterList expand: false;
						    add: demoList;
						    add: (SpBoxLayout newLeftToRight
								     add: debugButton expand: false;
								     add: errorText;
								     yourself)
						    expand: false;
						    yourself);
				   add: canvas;
				   yourself);
		  add: code;
		  yourself
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> demoList [
	^ demoList
]

{ #category : 'operations' }
TLBlocDemoPresenter >> demosMatching: aFilterSymbol [
	"The demos declaring the filter, or all the demos for #all"

	^ aFilterSymbol = #all
		  ifTrue: [ TLDemoCatalogue demoSelectors ]
		  ifFalse: [ TLDemoCatalogue demoSelectorsWithFilter: aFilterSymbol ]
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
TLBlocDemoPresenter >> errorText [
	^ errorText
]

{ #category : 'accessing' }
TLBlocDemoPresenter >> filterList [
	^ filterList
]

{ #category : 'initialization' }
TLBlocDemoPresenter >> initializePresenters [

	demoList := self newList display: [ :selector | selector asString ].
	filterList := self newDropList items: { #all } , TLDemoCatalogue filterSymbols.
	canvas := self instantiate: SpBlSpaceInMorphPresenter.
	code := self newCode beNotEditable.
	errorText := self newText beNotEditable.
	debugButton := self newButton
		               label: 'Debug';
		               action: [ self debugLastError ];
		               disable;
		               yourself.
	demoList items: TLDemoCatalogue demoSelectors
]

{ #category : 'initialization' }
TLBlocDemoPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Telescope Bloc Demos';
		initialExtent: 1200 @ 800
]

{ #category : 'operations' }
TLBlocDemoPresenter >> runDemo: aDemoSelector [
	"Renders the demo in the canvas, or shows its error"

	| connector visualization demoMethod |
	lastError := nil.
	debugButton disable.
	errorText text: ''.
	demoMethod := TLDemos class >> aDemoSelector.
	code beForMethod: demoMethod.
	code text: demoMethod sourceCode.
	[
		connector := TLBlocConnector new.
		visualization := TLDemos perform: aDemoSelector.
		visualization generator: connector.
		visualization generateWith: connector.
		canvas space root
			removeChildren;
			addChild: connector view ]
		on: Error
		do: [ :error | self showError: error ]
]

{ #category : 'operations' }
TLBlocDemoPresenter >> showError: anError [
	"Replaces the visualization by the stack of the error, and enables the debug button"

	lastError := anError.
	errorText text: anError class name , ': ' , anError description.
	debugButton enable.
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
