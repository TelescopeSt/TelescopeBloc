Class {
	#name : 'TLBlocDemoPresenterTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Demo',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Demo'
}

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testDemoListHasEveryDemo [

	self assert: TLBlocDemoPresenter new demoList items size equals: TLDemoCatalogue demoSelectors size
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testDemoListIsInTheAlphabeticalOrderOfTheDisplayNames [

	| names |
	names := TLBlocDemoPresenter new demoList items collect: [ :selector | (TLDemoCatalogue displayNameOf: selector) asLowercase ].
	self assert: names asArray equals: names asSortedCollection asArray
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testDemoListShowsTheDisplayNamesOfTheDemos [

	| presenter |
	presenter := TLBlocDemoPresenter new.
	self assert: (presenter demoList display value: #exampleSimpleConnections) equals: 'Simple connections'
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testFilteredDemosAreInTheAlphabeticalOrderOfTheirDisplayNames [

	| presenter names |
	presenter := TLBlocDemoPresenter new.
	names := (presenter demosMatching: #style) collect: [ :selector | (TLDemoCatalogue displayNameOf: selector) asLowercase ].
	self assert: names isNotEmpty.
	self assert: names asArray equals: names asSortedCollection asArray
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testSelectingADemoStillRunsItWithItsSelector [
	"The list shows names, but its items are still the selectors, which run the demos"

	| presenter |
	presenter := TLBlocDemoPresenter new.
	self assert: (presenter demoList items includes: #exampleSimpleConnections)
]
