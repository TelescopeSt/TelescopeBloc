Class {
	#name : 'TLBlocOrthogonalRouterTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> assertRoute: aRoute avoids: aRectangle [

	aRoute overlappingPairsDo: [ :from :to | self deny: (((from min: to) - 0.5 corner: (from max: to) + 0.5) intersects: aRectangle) ]
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> assertRouteHasOnlyRightAngles: aRoute [

	aRoute overlappingPairsDo: [ :from :to | self assert: (from x = to x or: [ from y = to y ]) ]
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> bendsOf: aRoute [

	^ aRoute size - 2
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> routeAround: someRectangles from: aStart to: anEnd [

	^ (TLBlocOrthogonalRouter obstacles: someRectangles) routeFrom: aStart to: anEnd
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteAvoidsAGridOfNodes [
	"The first of three rows of three nodes to the last: no route with only two bends exists"

	| nodes route |
	nodes := (0 to: 2) flatCollect: [ :row | (0 to: 2) collect: [ :column | column * 120 @ (row * 120) extent: 50 @ 50 ] ].
	route := self
		         routeAround: (nodes copyWithoutAll: {
					          nodes first.
					          nodes last })
		         from: 50 @ 25
		         to: 240 @ 265.
	self assert: route isNotNil.
	self assertRouteHasOnlyRightAngles: route.
	(nodes copyWithoutAll: {
			 nodes first.
			 nodes last }) do: [ :node | self assertRoute: route avoids: node ]
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteBetweenAlignedPointsIsStraight [

	self assert: (self routeAround: #(  ) from: 0 @ 0 to: 100 @ 0) equals: {
			(0 @ 0).
			(100 @ 0) }
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteGoesAroundAWall [

	| wall route |
	wall := 40 @ -100 corner: 60 @ 100.
	route := self routeAround: { wall } from: 0 @ 0 to: 100 @ 0.
	self assert: route first equals: 0 @ 0.
	self assert: route last equals: 100 @ 0.
	self assertRouteHasOnlyRightAngles: route.
	self assertRoute: route avoids: wall
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteGoesAroundSeveralObstaclesOnItsWay [

	| obstacles route |
	obstacles := {
		             (30 @ -50 corner: 50 @ 50).
		             (80 @ -50 corner: 100 @ 50).
		             (130 @ -50 corner: 150 @ 50) }.
	route := self routeAround: obstacles from: 0 @ 0 to: 180 @ 0.
	self assert: route isNotNil.
	obstacles do: [ :obstacle | self assertRoute: route avoids: obstacle ]
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteHasNoUselessPoint [
	"Three points on the same line: the one in the middle is useless"

	| route |
	route := self routeAround: { (40 @ -100 corner: 60 @ 100) } from: 0 @ 0 to: 100 @ 0.
	route overlappingPairsDo: [ :from :to | self deny: from equals: to ].
	(1 to: route size - 2) do: [ :index |
			self deny: ((route at: index) x = (route at: index + 1) x and: [ (route at: index + 1) x = (route at: index + 2) x ]).
			self deny: ((route at: index) y = (route at: index + 1) y and: [ (route at: index + 1) y = (route at: index + 2) y ]) ]
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteIgnoresObstaclesFarFromTheWay [

	| route |
	route := self routeAround: { (1000 @ 1000 corner: 1100 @ 1100) } from: 0 @ 0 to: 100 @ 50.
	self assert: (self bendsOf: route) <= 2
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteIsNilWhenTheStartIsEnclosed [
	"Walls on the four sides of the start"

	| walls |
	walls := {
		         (-30 @ -30 corner: 30 @ -10).
		         (-30 @ 10 corner: 30 @ 30).
		         (-30 @ -30 corner: -10 @ 30).
		         (10 @ -30 corner: 30 @ 30) }.
	self assert: (self routeAround: walls from: 0 @ 0 to: 100 @ 0) isNil
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteKeepsADistanceFromTheObstacles [

	| wall route |
	wall := 40 @ -100 corner: 60 @ 100.
	route := self routeAround: { wall } from: 0 @ 0 to: 100 @ 0.
	self assertRoute: route avoids: (wall expandBy: 7)
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRoutePrefersFewerBends [
	"A node beside the straight way: one bend is enough, and the route does not wander"

	| route |
	route := self routeAround: { (40 @ -20 corner: 60 @ 20) } from: 0 @ 0 to: 100 @ 60.
	self assert: (self bendsOf: route) <= 2
]

{ #category : 'tests' }
TLBlocOrthogonalRouterTest >> testRouteWithoutObstacleGoesFromTheStartToTheEnd [

	| route |
	route := self routeAround: #(  ) from: 0 @ 0 to: 100 @ 50.
	self assert: route first equals: 0 @ 0.
	self assert: route last equals: 100 @ 50.
	self assertRouteHasOnlyRightAngles: route.
	self assert: (self bendsOf: route) <= 2
]
