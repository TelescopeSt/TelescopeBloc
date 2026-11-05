"
I list the demos of TLDemos, the class-side methods marked with a script pragma, the filters they declare with the tlFilter pragma and their description with the tlDescription pragma (#descriptionOf:). I answer no UI, so a browser can filter demos without knowing how they are found. I give the name of a demo for a human (#displayNameOf:) and sort demos by it (#sortedByDisplayName:).
"
Class {
	#name : 'TLDemoCatalogue',
	#superclass : 'Object',
	#category : 'Telescope-Bloc-Demo-Catalogue',
	#package : 'Telescope-Bloc-Demo',
	#tag : 'Catalogue'
}

{ #category : 'accessing' }
TLDemoCatalogue class >> demoSelectors [
	"The selectors of the demos of TLDemos, sorted by name"

	^ ((TLDemos class methods select: [ :each | each hasPragmaNamed: #script: ]) collect: [ :each | each selector ]) asSortedCollection asArray
]

{ #category : 'accessing' }
TLDemoCatalogue class >> demoSelectorsWithFilter: aFilterSymbol [
	"The selectors of the demos declaring the given filter"

	^ self demoSelectors select: [ :each | (self filtersOfDemo: each) includes: aFilterSymbol ]
]

{ #category : 'accessing' }
TLDemoCatalogue class >> descriptionOf: aDemoSelector [
	"The description of a demo, given by its tlDescription pragma. Answers an empty string when the demo has none."

	^ (TLDemos class >> aDemoSelector) pragmas
		detect: [ :pragma | pragma selector = #tlDescription: ]
		ifFound: [ :pragma | pragma arguments first ]
		ifNone: [ '' ]
]

{ #category : 'display' }
TLDemoCatalogue class >> display: aWord first: isFirst [
	"An acronym keeps its capitals, the other words are in lower case, and the first word starts with a capital"

	| isAcronym |
	isAcronym := aWord size > 1 and: [ (aWord allSatisfy: [ :character | character isUppercase or: [ character isDigit ] ]) and: [ aWord anySatisfy: #isLetter ] ].
	isAcronym ifTrue: [ ^ aWord ].
	^ isFirst
		  ifTrue: [ aWord asLowercase capitalized ]
		  ifFalse: [ aWord asLowercase ]
]

{ #category : 'display' }
TLDemoCatalogue class >> displayNameOf: aDemoSelector [
	"The name of a demo for a human: the selector without its example prefix, split on its camel case, with only the first word capitalized and the acronyms kept in capitals. exampleSimpleConnections is Simple connections"

	| selectorName words |
	selectorName := aDemoSelector asString.
	(selectorName size > 7 and: [ (selectorName beginsWith: 'example') and: [ (selectorName at: 8) isUppercase ] ]) ifTrue: [ selectorName := selectorName allButFirst: 7 ].
	words := (self wordsOf: selectorName) collectWithIndex: [ :word :index | self display: word first: index = 1 ].
	^ ' ' join: words
]

{ #category : 'display' }
TLDemoCatalogue class >> does: aString startAWordAt: anIndex [

	| character previous next |
	character := aString at: anIndex.
	previous := aString at: anIndex - 1.
	next := anIndex < aString size
		        ifTrue: [ aString at: anIndex + 1 ]
		        ifFalse: [ $  ].
	character isUppercase ifTrue: [
			previous isLowercase | previous isDigit ifTrue: [ ^ true ].
			^ previous isUppercase and: [ next isLowercase ] ].
	^ character isDigit and: [ previous isLetter ]
]

{ #category : 'accessing' }
TLDemoCatalogue class >> filterSymbols [
	"The symbols of all the demo filters, sorted by name"

	^ (TLAbstractDemoFilter allSubclasses collect: [ :each | each filterSymbol ]) asSortedCollection asArray
]

{ #category : 'accessing' }
TLDemoCatalogue class >> filtersOfDemo: aDemoSelector [
	"The filters declared by a demo with the tlFilter pragma"

	^ ((TLDemos class >> aDemoSelector) pragmas select: [ :each | each selector = #tlFilter: ]) collect: [ :each | each arguments first ]
]

{ #category : 'display' }
TLDemoCatalogue class >> sortedByDisplayName: someDemoSelectors [
	"The demos in the alphabetical order of their display names, whatever the case"

	^ someDemoSelectors asSortedCollection: [ :first :second | (self displayNameOf: first) asLowercase <= (self displayNameOf: second) asLowercase ]
]

{ #category : 'display' }
TLDemoCatalogue class >> wordsOf: aString [
	"The words of a camel case string: a new word starts with a capital after a lower case letter or a digit, with the last capital of a run of capitals when a lower case letter follows (HTTPServer is HTTP and Server), and with a digit after a letter"

	| words current |
	words := OrderedCollection new.
	current := WriteStream on: String new.
	aString doWithIndex: [ :character :index |
			(index > 1 and: [ self does: aString startAWordAt: index ]) ifTrue: [
					words add: current contents.
					current := WriteStream on: String new ].
			current nextPut: character ].
	words add: current contents.
	^ words
]
