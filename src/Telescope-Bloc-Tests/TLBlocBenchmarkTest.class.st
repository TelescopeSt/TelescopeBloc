Class {
	#name : 'TLBlocBenchmarkTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Demo',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Demo'
}

{ #category : 'tests' }
TLBlocBenchmarkTest >> testBenchmarkDemosAreTheOnesWithTheBenchmarkFilter [

	self assert: TLBlocBenchmark demoSelectors equals: (TLDemoCatalogue demoSelectorsWithFilter: #benchmark)
]

{ #category : 'tests' }
TLBlocBenchmarkTest >> testEveryBenchmarkDemoBuildsAVisualization [

	TLBlocBenchmark demoSelectors do: [ :selector | self assert: (TLDemos perform: selector) class equals: TLVisualization ].
	self assert: TLBlocBenchmark demoSelectors size equals: 5
]

{ #category : 'tests' }
TLBlocBenchmarkTest >> testMeasureAnswersTheDurationOfEachPhase [

	| measures |
	measures := TLBlocBenchmark new measure: [ TLVisualization fromEntities: (1 to: 20) ].
	self assert: measures keys asArray equals: #( #build #generate #firstFrame #render #dragStep #hover #pan ).
	measures do: [ :duration | self assert: duration >= 0 milliSeconds ]
]

{ #category : 'tests' }
TLBlocBenchmarkTest >> testMeasureClosesTheWindow [

	| before |
	before := BlHeadlessHost default spaces size.
	TLBlocBenchmark new measure: [ TLVisualization fromEntities: (1 to: 5) ].
	self assert: BlHeadlessHost default spaces size equals: before
]

{ #category : 'tests' }
TLBlocBenchmarkTest >> testMeasureCountsTheNodesAndTheConnections [

	| benchmark |
	benchmark := TLBlocBenchmark new.
	benchmark measure: [
			(TLVisualization fromEntities: (1 to: 20))
				connectFollowingProperty: [ :number | { (number \\ 20 + 1) } ];
				yourself ].
	self assert: benchmark numberOfNodes equals: 20.
	self assert: benchmark numberOfConnections equals: 20
]

{ #category : 'tests' }
TLBlocBenchmarkTest >> testReportNamesThePhasesAndTheSizes [

	| benchmark report |
	benchmark := TLBlocBenchmark new.
	benchmark measure: [ TLVisualization fromEntities: (1 to: 5) ].
	report := benchmark report.
	#( 'build' 'generate' 'first frame' 'render' 'drag step' 'hover' 'pan' '5 nodes' ) do: [ :expected | self assert: (report includesSubstring: expected) ]
]
