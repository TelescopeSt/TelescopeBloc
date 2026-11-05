Class {
	#name : 'TLDemoCatalogueTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Demo',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Demo'
}

{ #category : 'tests' }
TLDemoCatalogueTest >> testDemosCanBeSortedByTheirDisplayName [

	| sorted names |
	sorted := TLDemoCatalogue sortedByDisplayName: { #exampleZebra. #exampleApple. #exampleMango }.
	self assert: sorted asArray equals: #( #exampleApple #exampleMango #exampleZebra )
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDescriptionIsTheArgumentOfThePragmaOfTheDemo [

	| pragma |
	pragma := (TLDemos class >> #exampleSimpleConnections) pragmas detect: [ :each | each selector = #tlDescription: ].
	self assert: (TLDemoCatalogue descriptionOf: #exampleSimpleConnections) equals: pragma arguments first.
	self assert: (TLDemoCatalogue descriptionOf: #exampleSimpleConnections) isNotEmpty
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDescriptionOfAMethodWithoutPragmaIsEmpty [
	"A method of the class of the demos which is not a demo"

	self assert: (TLDemoCatalogue descriptionOf: #connectionArrowsIn:from:to:label:) equals: ''
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDescriptionsAreOneParagraphWhichEndsWithAFullStop [

	TLDemoCatalogue demoSelectors do: [ :selector |
			| description |
			description := TLDemoCatalogue descriptionOf: selector.
			self assert: (description isNotEmpty and: [ description last = $. ]) description: selector , ' does not end with a full stop'.
			self deny: (description includes: Character cr) description: selector , ' has several lines'.
			self deny: (description includes: Character lf) description: selector , ' has several lines' ]
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDescriptionsOfTheDemosAreDifferent [

	| descriptions |
	descriptions := TLDemoCatalogue demoSelectors collect: [ :selector | TLDemoCatalogue descriptionOf: selector ].
	self assert: descriptions asSet size equals: descriptions size
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameKeepsAnAcronymInCapitals [

	self assert: (TLDemoCatalogue displayNameOf: #exampleCIStyle) equals: 'CI style'.
	self assert: (TLDemoCatalogue displayNameOf: #exampleUseHTTPServer) equals: 'Use HTTP server'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameOfALongSelectorHasOnlyTheFirstWordCapitalized [

	self assert: (TLDemoCatalogue displayNameOf: #exampleCompositeNodeWithLabelInsideInButterfly) equals: 'Composite node with label inside in butterfly'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameOfASelectorWithoutThePrefixIsSplitToo [

	self assert: (TLDemoCatalogue displayNameOf: #somethingElse) equals: 'Something else'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameOfASingleWordIsCapitalized [

	self assert: (TLDemoCatalogue displayNameOf: #exampleLegend) equals: 'Legend'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameOfAnExampleWhichStartsWithTheWordExampleOnlyDropsThePrefix [

	self assert: (TLDemoCatalogue displayNameOf: #exampleExampleOfNodes) equals: 'Example of nodes'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameOfTheBarePrefixIsThePrefix [

	self assert: (TLDemoCatalogue displayNameOf: #example) equals: 'Example'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameRemovesTheExamplePrefixAndSplitsTheCamelCase [

	self assert: (TLDemoCatalogue displayNameOf: #exampleSimpleConnections) equals: 'Simple connections'.
	self assert: (TLDemoCatalogue displayNameOf: #exampleAllShapes) equals: 'All shapes'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNameSeparatesTheNumbers [

	self assert: (TLDemoCatalogue displayNameOf: #exampleLayout2Groups) equals: 'Layout 2 groups'
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testDisplayNamesOfTheDemosAreDifferent [

	| names |
	names := TLDemoCatalogue demoSelectors collect: [ :selector | TLDemoCatalogue displayNameOf: selector ].
	self assert: names asSet size equals: names size
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testEveryDemoHasADescription [

	TLDemoCatalogue demoSelectors do: [ :selector |
			| description |
			description := TLDemoCatalogue descriptionOf: selector.
			self assert: description isNotEmpty description: selector , ' has no description'.
			self assert: description size > 25 description: selector , ' has a too short description' ]
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testEveryDemoHasADisplayNameWithoutThePrefix [

	TLDemoCatalogue demoSelectors do: [ :selector |
			| name |
			name := TLDemoCatalogue displayNameOf: selector.
			self assert: name isNotEmpty.
			self assert: name first isUppercase.
			self deny: (name beginsWith: 'Example ').
			self deny: (name includes: Character cr) ]
]

{ #category : 'tests' }
TLDemoCatalogueTest >> testSortingIgnoresTheCaseOfTheDisplayName [

	self assert: (TLDemoCatalogue sortedByDisplayName: { #exampleBeta. #exampleAlpha. #exampleCI }) asArray equals: #( #exampleAlpha #exampleBeta #exampleCI )
]
