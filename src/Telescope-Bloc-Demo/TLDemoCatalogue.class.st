"
I list the demos of TLDemos, the class-side methods marked with a script pragma, and the filters they declare with the tlFilter pragma. I answer no UI, so a browser can filter demos without knowing how they are found.
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
TLDemoCatalogue class >> filterSymbols [
	"The symbols of all the demo filters, sorted by name"

	^ (TLAbstractDemoFilter allSubclasses collect: [ :each | each filterSymbol ]) asSortedCollection asArray
]

{ #category : 'accessing' }
TLDemoCatalogue class >> filtersOfDemo: aDemoSelector [
	"The filters declared by a demo with the tlFilter pragma"

	^ ((TLDemos class >> aDemoSelector) pragmas select: [ :each | each selector = #tlFilter: ]) collect: [ :each | each arguments first ]
]
