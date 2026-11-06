"
A node for the tests which counts how many times its effective style sheet is computed: merging the style sheets of its parents is costly.
"
Class {
	#name : 'TLSimpleNodeCountingStyleSheets',
	#superclass : 'TLSimpleNode',
	#instVars : [
		'styleSheetComputations'
	],
	#category : 'Telescope-Bloc-Tests-Node',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Node'
}

{ #category : 'styling' }
TLSimpleNodeCountingStyleSheets >> effectiveStyleSheet [

	styleSheetComputations := self styleSheetComputations + 1.
	^ super effectiveStyleSheet
]

{ #category : 'accessing' }
TLSimpleNodeCountingStyleSheets >> styleSheetComputations [

	^ styleSheetComputations ifNil: [ 0 ]
]
