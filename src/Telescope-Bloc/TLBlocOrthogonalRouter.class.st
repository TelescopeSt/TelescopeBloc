Class {
	#name : 'TLBlocOrthogonalRouter',
	#superclass : 'Object',
	#instVars : [
		'obstacles',
		'xs',
		'ys',
		'distances',
		'previous'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
TLBlocOrthogonalRouter class >> obstacles: someRectangles [
	"The rectangles which the routes go around"

	^ self new
		  obstacles: someRectangles;
		  yourself
]

{ #category : 'accessing' }
TLBlocOrthogonalRouter >> bendPenalty [
	"What a bend costs, in pixels of route: the routes with fewer bends are preferred to slightly shorter ones"

	^ 30
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> cellOfState: aState [

	| index |
	index := aState - 1 // 4.
	^ index \\ xs size + 1 @ (index // xs size + 1)
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> directionOfState: aState [

	^ aState - 1 \\ 4 + 1
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> is: aPoint insideAnyOf: someRectangles [
	"Strictly inside: the sides of an obstacle, which are the lines of the grid, are free"

	^ someRectangles anySatisfy: [ :rectangle | aPoint x > rectangle left and: [ aPoint x < rectangle right and: [ aPoint y > rectangle top and: [ aPoint y < rectangle bottom ] ] ] ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> is: aPoint onTheLineBetween: aFirstPoint and: aSecondPoint [

	^ (aFirstPoint x = aPoint x and: [ aPoint x = aSecondPoint x ]) or: [ aFirstPoint y = aPoint y and: [ aPoint y = aSecondPoint y ] ]
]

{ #category : 'accessing' }
TLBlocOrthogonalRouter >> margin [
	"The distance in pixels between a route and the obstacles"

	^ 8
]

{ #category : 'accessing' }
TLBlocOrthogonalRouter >> obstacles: someRectangles [
	"The routes keep a margin from them"

	obstacles := someRectangles collect: [ :rectangle | rectangle expandBy: self margin ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> obstaclesNear: aStart and: anEnd [

	| area |
	area := ((aStart min: anEnd) corner: (aStart max: anEnd)) expandBy: self searchRadius.
	^ obstacles select: [ :rectangle | rectangle intersects: area ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> pointOfCell: aCell [

	^ (xs at: aCell x) @ (ys at: aCell y)
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> pointsEndingAt: aState [
	"The points of the route which ends at the state, from the start, without the points which are on the line between their neighbors"

	| points state |
	points := OrderedCollection new.
	state := aState.
	[ state = 0 ] whileFalse: [
			points addFirst: (self pointOfCell: (self cellOfState: state)).
			state := previous at: state ].
	^ self withoutPointsOnALine: points
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> reach: aCell from: aState length: aLength bend: isBend direction: aDirection into: aHeap [

	| cost newState |
	cost := (distances at: aState) + aLength + (isBend
		         ifTrue: [ self bendPenalty ]
		         ifFalse: [ 0 ]).
	newState := self stateAt: aCell direction: aDirection.
	cost < (distances at: newState) ifFalse: [ ^ self ].
	distances at: newState put: cost.
	previous at: newState put: aState.
	aHeap add: {
			cost.
			newState }
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> relax: aState from: aCell direction: aDirection into: aHeap among: someRectangles [
	"Moves to the neighbor cells of the grid, except backwards: the cost is the length, and a bend when the direction changes"

	1 to: 4 do: [ :newDirection |
			| neighbor |
			neighbor := newDirection = (aDirection + 1 \\ 4 + 1) ifFalse: [ self stepFrom: aCell direction: newDirection among: someRectangles ].
			neighbor ifNotNil: [
					self
						reach: neighbor
						from: aState
						length: ((self pointOfCell: neighbor) distanceTo: (self pointOfCell: aCell))
						bend: newDirection ~= aDirection
						direction: newDirection
						into: aHeap ] ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> routeFrom: aStart to: anEnd [
	"The points of the shortest route with right angles, with the fewest bends, from the start to the end which does not enter the obstacles, or nil when there is none. The obstacles near the start and the end are considered first, and all of them when that does not give a route"

	| near |
	near := self obstaclesNear: aStart and: anEnd.
	^ (self routeFrom: aStart to: anEnd among: near) ifNil: [ near size = obstacles size ifFalse: [ self routeFrom: aStart to: anEnd among: obstacles ] ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> routeFrom: aStart to: anEnd among: someRectangles [
	"Dijkstra on the grid made by the lines through the start, the end and the sides of the obstacles: a state is a point of the grid and the direction in which it was reached, so that a bend can cost more than a straight move"

	| heap size endIndex |
	xs := (someRectangles flatCollect: [ :rectangle |
			       {
				       rectangle left.
				       rectangle right } ]) , {
		      aStart x.
		      anEnd x }.
	xs := xs asSet asSortedCollection asArray.
	ys := (someRectangles flatCollect: [ :rectangle |
			       {
				       rectangle top.
				       rectangle bottom } ]) , {
		      aStart y.
		      anEnd y }.
	ys := ys asSet asSortedCollection asArray.
	size := xs size * ys size * 4.
	distances := Array new: size withAll: Float infinity.
	previous := Array new: size withAll: 0.
	endIndex := (xs indexOf: anEnd x) @ (ys indexOf: anEnd y).
	heap := Heap sortBlock: [ :first :second | first first <= second first ].
	1 to: 4 do: [ :direction |
			| state |
			state := self stateAt: (xs indexOf: aStart x) @ (ys indexOf: aStart y) direction: direction.
			distances at: state put: 0.
			heap add: {
					0.
					state } ].
	[ heap isEmpty ] whileFalse: [
			| entry state cell direction |
			entry := heap removeFirst.
			state := entry second.
			entry first > (distances at: state) ifFalse: [
					cell := self cellOfState: state.
					direction := self directionOfState: state.
					cell = endIndex ifTrue: [ ^ self pointsEndingAt: state ].
					self
						relax: state
						from: cell
						direction: direction
						into: heap
						among: someRectangles ] ].
	^ nil
]

{ #category : 'accessing' }
TLBlocOrthogonalRouter >> searchRadius [
	"The obstacles which are farther than this from the rectangle of the start and the end are not considered at first: they are rarely in the way"

	^ 150
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> stateAt: aCell direction: aDirection [

	^ aCell y - 1 * xs size + aCell x - 1 * 4 + aDirection
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> stepFrom: aCell direction: aDirection among: someRectangles [
	"The neighbor cell of the grid in the direction, or nil when it is out of the grid or when the segment to it enters an obstacle"

	| neighbor from to middle |
	neighbor := aCell + (self vectorOfDirection: aDirection).
	((neighbor x between: 1 and: xs size) and: [ neighbor y between: 1 and: ys size ]) ifFalse: [ ^ nil ].
	from := self pointOfCell: aCell.
	to := self pointOfCell: neighbor.
	middle := from + to / 2.
	^ ((self is: from insideAnyOf: someRectangles) or: [ (self is: to insideAnyOf: someRectangles) or: [ self is: middle insideAnyOf: someRectangles ] ]) ifFalse: [ neighbor ]
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> vectorOfDirection: aDirection [

	^ {
		  (1 @ 0).
		  (0 @ 1).
		  (-1 @ 0).
		  (0 @ -1) } at: aDirection
]

{ #category : 'routing' }
TLBlocOrthogonalRouter >> withoutPointsOnALine: somePoints [
	"Drops the repeated points, and the points which are on the line between their neighbors"

	| result |
	result := OrderedCollection new.
	somePoints do: [ :point |
			(result isNotEmpty and: [ result last = point ]) ifFalse: [
					[ result size >= 2 and: [ self is: result last onTheLineBetween: (result at: result size - 1) and: point ] ] whileTrue: [ result removeLast ].
					result add: point ] ].
	^ result asArray
]
