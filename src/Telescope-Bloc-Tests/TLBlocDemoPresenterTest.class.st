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
TLBlocDemoPresenterTest >> testDescriptionCanNotBeEdited [

	self deny: TLBlocDemoPresenter new description isEditable
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testDescriptionChangesWithTheSelectedDemo [

	| presenter first |
	presenter := TLBlocDemoPresenter new.
	presenter demoList selectItem: #exampleSimpleConnections.
	first := presenter description text asString.
	presenter demoList selectItem: #exampleAllShapes.
	self deny: presenter description text asString equals: first.
	self assert: presenter description text asString equals: (TLDemoCatalogue descriptionOf: #exampleAllShapes)
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testErrorOfADemoIsShownInTheCanvasOnly [
	"A demo which fails shows its error in the canvas, there is no separate error field"

	| presenter |
	presenter := TLBlocDemoPresenter new.
	[ Error signal: 'A broken demo' ]
		on: Error
		do: [ :error | presenter showError: error ].
	self assert: presenter canvas space root children size equals: 1.
	self deny: (TLBlocDemoPresenter canUnderstand: #errorText)
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
TLBlocDemoPresenterTest >> testSelectingADemoShowsItsDescription [

	| presenter |
	presenter := TLBlocDemoPresenter new.
	presenter demoList selectItem: #exampleSimpleConnections.
	self assert: presenter description text asString equals: (TLDemoCatalogue descriptionOf: #exampleSimpleConnections)
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testSelectingADemoStillRunsItWithItsSelector [
	"The list shows names, but its items are still the selectors, which run the demos"

	| presenter |
	presenter := TLBlocDemoPresenter new.
	self assert: (presenter demoList items includes: #exampleSimpleConnections)
]

{ #category : 'tests' }
TLBlocDemoPresenterTest >> testThereIsNoDebugButton [

	self deny: (TLBlocDemoPresenter canUnderstand: #debugButton).
	self deny: (TLBlocDemoPresenter canUnderstand: #debugLastError)
]
