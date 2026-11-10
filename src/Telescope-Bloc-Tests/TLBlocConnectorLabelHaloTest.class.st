"
I test the halo of the labels: an outline of the letters, in the opposite of the color of the text, which keeps a label readable on a background close to its color. It is off by default, because it makes the drawing of a visualization with many labels slower (see TLBlocConnector class>>#labelHalo).
"
Class {
	#name : 'TLBlocConnectorLabelHaloTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests',
	#package : 'Telescope-Bloc-Tests'
}

{ #category : 'helpers' }
TLBlocConnectorLabelHaloTest >> haloOf: aLine [
	"The halo of the line of a label, or nil"

	^ (aLine text attributesAt: 1)
		  detect: [ :attribute | attribute class = BlTextBorderAttribute ]
		  ifNone: [ nil ]
]

{ #category : 'helpers' }
TLBlocConnectorLabelHaloTest >> lines [
	"The text elements of the lines of all the labels"

	^ (connector view content children select: [ :element | element class = TLBlocNodeElement ]) flatCollect: [ :node | node labelElement children ]
]

{ #category : 'running' }
TLBlocConnectorLabelHaloTest >> open [

	visualization styleSheet nodeLabel: #asString.
	visualization addNodesFromEntities: (1 to: 3).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Halo'.
	self settle
]

{ #category : 'running' }
TLBlocConnectorLabelHaloTest >> settle [

	connector view space settleForDuration: 1 seconds
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testHaloIsDrawn [

	| canvas space |
	connector labelHalo: true.
	self open.
	space := connector view space.
	canvas := AeCanvas extent: space extent.
	self shouldnt: [ space root aeFullDrawOn: canvas ] raise: Error
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testHaloOfAConnectorWinsOverTheSetting [

	| previous |
	previous := TLBlocConnector labelHalo.
	[
		TLBlocConnector labelHalo: true.
		connector labelHalo: false.
		self open.
		self assert: (self haloOf: self lines first) isNil ] ensure: [ TLBlocConnector labelHalo: previous ]
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testHaloOfADarkTextIsLight [

	connector labelHalo: true.
	visualization styleSheet textColor: Color black.
	self open.
	self assert: (self haloOf: self lines first) border paint color equals: (Color white alpha: 0.8)
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testHaloOfALightTextIsDark [

	connector labelHalo: true.
	visualization styleSheet textColor: Color white.
	self open.
	self assert: (self haloOf: self lines first) border paint color equals: (Color black alpha: 0.8)
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testLabelsFollowTheSetting [

	| previous |
	previous := TLBlocConnector labelHalo.
	[
		TLBlocConnector labelHalo: true.
		self open.
		self assert: (self haloOf: self lines first) isNotNil ] ensure: [ TLBlocConnector labelHalo: previous ]
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testLabelsHaveAHaloWhenTheConnectorSaysSo [

	connector labelHalo: true.
	self open.
	self denyEmpty: self lines.
	self lines do: [ :line |
			| halo |
			halo := self haloOf: line.
			self assert: halo isNotNil.
			self deny: halo isAbove ]
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testLabelsHaveNoHaloByDefault [

	self deny: TLBlocConnector defaultLabelHalo.
	self open.
	self lines do: [ :line | self assert: (self haloOf: line) isNil ]
]

{ #category : 'tests' }
TLBlocConnectorLabelHaloTest >> testWrappedLinesKeepTheHalo [
	"The lines made again to wrap a label have a halo too"

	connector labelHalo: true.
	visualization styleSheet
		nodeLabelWrap: 'wrap';
		nodeLabelMaxWidth: 40.
	visualization styleSheet nodeLabel: [ :number | 'a label of many words' ].
	visualization addNodesFromEntities: (1 to: 2).
	connector open: visualization inWindowSized: 400 @ 300 titled: 'Halo'.
	self settle.
	self assert: self lines size > 2.
	self lines do: [ :line | self assert: (self haloOf: line) isNotNil ]
]
