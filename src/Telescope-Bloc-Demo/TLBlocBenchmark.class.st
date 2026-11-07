"
I measure how long TelescopeBloc takes to show a visualization, to find what is worth optimizing.
#measure: takes a block which builds the visualization (the benchmark demos of TLDemos are such blocks) and times its phases in a headless window:
- build: the block, which builds the model of Telescope.
- generate: the connector makes the Bloc elements and opens the window.
- firstFrame: Bloc lays the elements out until the window is settled.
- render: the average of a few draws of the window on a Cairo canvas, as a host draws it, without converting it to a Form.
- dragStep: the average of a step of a drag of the first node, with the layouts it asks for.
- hover: the mouse enters the first node and leaves it, with the interactions it triggers.
- pan: the average of a step of a pan, the drawing of the window included, the first step, which fills the composition layer of the content, too.
#report answers the durations as a text, and #runAll the report of every demo with the benchmark filter.
Use it with the profiler to look for what to optimize: MessageTally spyOn: [ TLBlocBenchmark reportOf: #exampleBenchmarkManyNodes ].
"
Class {
	#name : 'TLBlocBenchmark',
	#superclass : 'Object',
	#instVars : [
		'measures',
		'numberOfNodes',
		'numberOfConnections'
	],
	#category : 'Telescope-Bloc-Demo-Benchmark',
	#package : 'Telescope-Bloc-Demo',
	#tag : 'Benchmark'
}

{ #category : 'demos' }
TLBlocBenchmark class >> demoSelectors [
	"The selectors of the demos of TLDemos with the benchmark filter"

	^ TLDemoCatalogue demoSelectorsWithFilter: #benchmark
]

{ #category : 'running' }
TLBlocBenchmark class >> reportOf: aDemoSelector [
	"Runs the demo, which builds its visualization, and answers its name followed by the durations of the phases"

	| benchmark |
	benchmark := self new.
	benchmark measure: [ TLDemos perform: aDemoSelector ].
	^ (TLDemoCatalogue displayNameOf: aDemoSelector) , String cr , benchmark report
]

{ #category : 'running' }
TLBlocBenchmark class >> runAll [
	"The report of every demo with the benchmark filter, one after the other. It takes a while: the demos are big"

	^ String streamContents: [ :stream |
			  self demoSelectors do: [ :selector |
					  stream
						  nextPutAll: (self reportOf: selector);
						  cr ] ]
]

{ #category : 'measuring' }
TLBlocBenchmark >> dragStepOf: aNodeElement in: aConnector [
	"Moves the node like the mouse does, and waits for the layouts it asks for. Answers the average duration of a step"

	| steps view |
	steps := 10.
	view := aConnector view.
	^ [
		  steps timesRepeat: [
				  view keepPositionWhile: [
						  aNodeElement placeAt: aNodeElement placement + (4 @ 3).
						  aNodeElement fitParentCompositesToTheirChildren ].
				  view nodesMoved: aNodeElement.
				  view space settleForDuration: 60 seconds ] ] timeToRun / steps
]

{ #category : 'measuring' }
TLBlocBenchmark >> drawDurationOf: aSpace [
	"Draws the window once on a Cairo canvas, as its host does, without converting it to a Form, and answers how long the drawing took"

	| canvas |
	canvas := AeCanvas extent: aSpace extent.
	canvas clippingRectangle: (0 @ 0 extent: aSpace extent).
	^ [ canvas restoreContextAfter: [ aSpace root aeFullDrawOn: canvas ] ] timeToRun
]

{ #category : 'measuring' }
TLBlocBenchmark >> hoverOf: aNodeElement in: aConnector [
	"The mouse enters the node and leaves it, and Bloc waits for the interactions to change the style, like a user passing over the node. Answers the duration"

	^ [
		  aNodeElement dispatchEvent: BlMouseEnterEvent new.
		  aConnector view space settleForDuration: 60 seconds.
		  aNodeElement dispatchEvent: BlMouseLeaveEvent new.
		  aConnector view space settleForDuration: 60 seconds ] timeToRun
]

{ #category : 'measuring' }
TLBlocBenchmark >> measure: aBlockBuildingTheVisualization [
	"Answers the durations of the phases, by name, for the visualization which the block builds. The window is closed at the end"

	| visualization connector |
	measures := OrderedDictionary new.
	visualization := self time: #build of: aBlockBuildingTheVisualization.
	connector := TLBlocConnector new.
	connector
		host: BlHeadlessHost default;
		animationDuration: 0 seconds.
	visualization generator: connector.
	self time: #generate of: [ connector open: visualization inWindowSized: 1000 @ 800 titled: 'Benchmark' ].
	self time: #firstFrame of: [ connector view space settleForDuration: 120 seconds ].
	measures at: #render put: (self renderOf: connector view space).
	numberOfNodes := visualization allNodesRecursively size.
	numberOfConnections := connector connections size.
	measures at: #dragStep put: (self dragStepOf: (connector elementFromTLDrawable: visualization allNodes first) in: connector).
	measures at: #hover put: (self hoverOf: (connector elementFromTLDrawable: visualization allNodes first) in: connector).
	measures at: #pan put: (self panOf: connector).
	connector view space close.
	BlHeadlessHost default settle.
	^ measures
]

{ #category : 'accessing' }
TLBlocBenchmark >> numberOfConnections [
	"The number of connections of the last visualization measured"

	^ numberOfConnections
]

{ #category : 'accessing' }
TLBlocBenchmark >> numberOfNodes [
	"The number of nodes of the last visualization measured, the nodes inside of composite nodes included"

	^ numberOfNodes
]

{ #category : 'measuring' }
TLBlocBenchmark >> panOf: aConnector [
	"Pans the visualization like the mouse dragging the background, and draws the window after each step. Answers the average duration of a step, the first one included: it is the one which fills the composition layer of the content"

	| steps view total |
	steps := 10.
	view := aConnector view.
	total := 0 milliSeconds.
	view startPanning.
	steps timesRepeat: [
			total := total + [
				         view panBy: 3 @ 2.
				         view space settleForDuration: 60 seconds ] timeToRun + (self drawDurationOf: view space) ].
	view stopPanning.
	^ total / steps
]

{ #category : 'measuring' }
TLBlocBenchmark >> renderOf: aSpace [
	"The average duration of a few draws of the window. The window is not converted to a Form, which costs more than drawing it and which a host does not do"

	| draws total |
	draws := 5.
	total := 0 milliSeconds.
	draws timesRepeat: [ total := total + (self drawDurationOf: aSpace) ].
	^ total / draws
]

{ #category : 'reporting' }
TLBlocBenchmark >> report [
	"The sizes of the last visualization measured and the duration of each phase in milliseconds"

	^ String streamContents: [ :stream |
			  stream
				  print: numberOfNodes;
				  nextPutAll: ' nodes, ';
				  print: numberOfConnections;
				  nextPutAll: ' connections';
				  cr.
			  measures keysAndValuesDo: [ :phase :duration |
					  stream
						  nextPutAll: (TLDemoCatalogue displayNameOf: phase) asLowercase;
						  tab;
						  print: duration asMilliSeconds;
						  nextPutAll: ' ms';
						  cr ] ]
]

{ #category : 'measuring' }
TLBlocBenchmark >> time: aPhase of: aBlock [
	"Evaluates the block, remembers how long it took for the phase and answers its value"

	| value |
	measures at: aPhase put: [ value := aBlock value ] timeToRun.
	^ value
]
