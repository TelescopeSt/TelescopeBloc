"
I test how the style sheet of a node is applied to the node drawn by the Bloc connector. For now it covers the colors: a color of the style sheet, a block of the entity or a gradient of the entity gives the color of the background and of the border of each node. I inherit the connector and the visualization from TLBlocConnectorTest.
"
Class {
	#name : 'TLBlocConnectorNodeStyleTest',
	#superclass : 'TLBlocConnectorTest',
	#category : 'Telescope-Bloc-Tests-Connector',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connector'
}

{ #category : 'helpers' }
TLBlocConnectorNodeStyleTest >> backgroundColorOfEntity: anEntity [
	"Generates a node of the entity and answers the color of the background of its element"

	| node |
	node := visualization addNodeFromEntity: anEntity.
	visualization generateWith: connector.
	^ (connector elementFromTLDrawable: node) background paint color
]

{ #category : 'helpers' }
TLBlocConnectorNodeStyleTest >> colorsOfEntities: aCollection [
	"Generates a node for each entity and answers the colors of the backgrounds of their elements"

	| nodes |
	nodes := aCollection collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization generateWith: connector.
	^ nodes collect: [ :node | (connector elementFromTLDrawable: node) background paint color ]
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBackgroundIsTheColorOfTheStyle [

	visualization styleSheet backgroundColor: Color red.
	self assert: (self backgroundColorOfEntity: 1) equals: Color red
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBlockGivesEachNodeTheColorOfItsEntity [

	| colors |
	visualization styleSheet backgroundColor: [ :entity |
			entity even
				ifTrue: [ Color red ]
				ifFalse: [ Color blue ] ].
	colors := self colorsOfEntities: #( 1 2 3 ).
	self assert: colors asArray equals: {
			Color blue.
			Color red.
			Color blue }
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderColorCanDependOnTheEntityToo [

	| nodes |
	visualization styleSheet borderColor: [ :entity |
			entity = 1
				ifTrue: [ Color red ]
				ifFalse: [ Color blue ] ].
	nodes := #( 1 2 ) collect: [ :entity | visualization addNodeFromEntity: entity ].
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: nodes first) border paint color equals: Color red.
	self assert: (connector elementFromTLDrawable: nodes last) border paint color equals: Color blue
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testBorderIsTheBorderColorOfTheStyle [

	| node |
	visualization styleSheet
		borderColor: Color blue;
		borderWidth: 3.
	node := visualization addNodeFromEntity: 1.
	visualization generateWith: connector.
	self assert: (connector elementFromTLDrawable: node) border paint color equals: Color blue.
	self assert: (connector elementFromTLDrawable: node) border width equals: 3
]

{ #category : 'tests' }
TLBlocConnectorNodeStyleTest >> testGradientGivesEachNodeTheColorOfItsEntity [

	| gradient colors |
	gradient := (MDLColor red property: #yourself gradientAt: 5)
		            to: MDLColor green at: 15;
		            yourself.
	visualization styleSheet backgroundColor: gradient.
	colors := self colorsOfEntities: #( 5 10 15 ).
	self assert: colors first equals: MDLColor red.
	self assert: colors last equals: MDLColor green.
	self assert: (colors at: 2) equals: (gradient value: 10).
	self deny: (colors at: 2) equals: colors first.
	self deny: (colors at: 2) equals: colors last
]
