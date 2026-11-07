Extension { #name : 'TLDemos' }

{ #category : '*Telescope-Bloc-Demo' }
TLDemos class >> exampleBenchmarkManyConnections [

	<script: 'self exampleBenchmarkManyConnections open'>
	<tlDescription:
	'Four hundred nodes on a circle with about twelve hundred connections, some of them with right angles which go around the other nodes: it stresses the routes, the heads and the parallel connections.'>
	<tlFilter: #benchmark>
	| visualization |
	visualization := TLVisualization fromEntities: (1 to: 400).
	visualization styleSheet
		width: 12;
		height: 12.
	visualization layout: TLCircularLayout new.
	visualization connectFollowingProperty: [ :number | (1 to: 3) collect: [ :step | number * step * 7 \\ 400 + 1 ] ].
	(visualization allNodes first: 100)
		connectFollowingProperty: [ :number | { (number * 11 \\ 400 + 1) } ];
		do: [ :connection | connection styleSheet curveStyle: TLSegmentsCurve ].
	^ visualization
]

{ #category : '*Telescope-Bloc-Demo' }
TLDemos class >> exampleBenchmarkManyInteractions [

	<script: 'self exampleBenchmarkManyInteractions open'>
	<tlDescription:
	'A thousand nodes and two thousand connections with a highlight on mouse over, a click, a pop up and a menu: it stresses the creation of the handlers and the update of the style when the mouse moves.'>
	<tlFilter: #benchmark>
	<tlFilter: #interaction>
	| visualization highlight connections |
	visualization := TLVisualization fromEntities: (1 to: 1000).
	visualization styleSheet
		width: 20;
		height: 20;
		nodeLabel: #asString position: #inside.
	visualization layout: ((TLLinearLayout perLine: 40)
			 gap: 20;
			 yourself).
	highlight := (TLStyleCustomizationAction custom: [ :style | style color: Color red lighter ]) onMouseOver.
	connections := visualization connectFollowingProperty: [ :number |
			               {
				               (number * 3 \\ 1000 + 1).
				               (number * 7 \\ 1000 + 1) } ].
	connections addInteraction: highlight.
	visualization addInteractions: {
			highlight.
			(TLCustomAction block: [ :node | node entity ]) onClick.
			(TLPopUpAction text: #asString) onMouseOver.
			((TLCustomAction block: [ :node | node entity ]) withMenu: 'Select') }.
	^ visualization
]

{ #category : '*Telescope-Bloc-Demo' }
TLDemos class >> exampleBenchmarkManyNodes [

	<script: 'self exampleBenchmarkManyNodes open'>
	<tlDescription: 'Three thousand nodes with a label each, in lines of sixty: it stresses the creation of the elements, the measure of the labels and a layout of many nodes.'>
	<tlFilter: #benchmark>
	| visualization |
	visualization := TLVisualization fromEntities: (1 to: 3000).
	visualization styleSheet
		width: 30;
		height: 20;
		nodeLabel: #asString position: #inside;
		layout: ((TLLinearLayout perLine: 60)
				 gap: 4;
				 yourself).
	^ visualization
]

{ #category : '*Telescope-Bloc-Demo' }
TLDemos class >> exampleBenchmarkNestedComposites [

	<script: 'self exampleBenchmarkNestedComposites open'>
	<tlDescription:
	'Composite nodes nested on four levels, five children each, which makes about eight hundred nodes expanded at once: it stresses the groups, the fit of a composite to its children and the style sheets of the parents.'>
	<tlFilter: #benchmark>
	<tlFilter: #composite>
	| visualization |
	visualization := TLVisualization new.
	visualization styleSheet
		width: 20;
		height: 20;
		compositeExpandedByDefault: true;
		childrenLayout: ((TLLinearLayout perLine: 5)
				 gap: 6;
				 yourself).
	visualization childrenProperty: [ :path |
			path size < 4
				ifTrue: [ (1 to: 5) collect: [ :index | path copyWith: index ] ]
				ifFalse: [ #(  ) ] ].
	visualization nodeCreationStrategy beRecursive.
	visualization addNodesFromEntities: ((1 to: 5) collect: [ :index | { index } ]).
	^ visualization
]

{ #category : '*Telescope-Bloc-Demo' }
TLDemos class >> exampleBenchmarkTree [

	<script: 'self exampleBenchmarkTree open'>
	<tlDescription: 'A binary tree of fifteen hundred nodes with a connection from each node to its two children, placed by the tree layout: it stresses a layout which depends on the connections.'>
	<tlFilter: #benchmark>
	| visualization |
	visualization := TLVisualization fromEntities: (1 to: 1500).
	visualization styleSheet
		width: 16;
		height: 16.
	visualization layout: TLTreeLayout new.
	visualization connectFollowingProperty: [ :number |
			{
				(number * 2).
				(number * 2 + 1) } select: [ :child | child <= 1500 ] ].
	^ visualization
]
