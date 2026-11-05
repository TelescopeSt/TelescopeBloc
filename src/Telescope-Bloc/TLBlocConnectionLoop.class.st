"
I am the route of a connection from a node to itself: a loop which leaves the node and comes back to it. I am an arc, a quadratic Bezier curve, whose two ends are on the border of the node on both sides of a direction, and whose control point is away from the node in that direction. The loop of a lone connection goes up. The offset, which spreads the connections between the same nodes, turns the direction around the node, so that several loops on the same node do not overlap. The label is away from the node, beyond the loop.
"
Class {
	#name : 'TLBlocConnectionLoop',
	#superclass : 'TLBlocConnectionArc',
	#instVars : [
		'direction'
	],
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
TLBlocConnectionLoop class >> around: anOutline offset: anOffset [
	"The outline is a Geometry project shape, in the coordinates of the view"

	^ self new
		  around: anOutline offset: anOffset;
		  yourself
]

{ #category : 'initialization' }
TLBlocConnectionLoop >> around: anOutline offset: anOffset [
	"The loop goes up when the offset is 0, and the offset turns it clockwise around the node, by 1.75 degrees for each pixel (40 pixels is the spacing of two parallel connections). The control point is away from the border of the node, and the ends are on the border on both sides of the direction"

	| center radius |
	offset := anOffset.
	center := self centerOf: anOutline.
	radius := (anOutline encompassingRectangle width max: anOutline encompassingRectangle height) / 2.
	direction := self directionForOffset: anOffset.
	control := center + (direction * (radius * 1.1 + 50)).
	start := self borderPointOf: anOutline around: center toward: (self rotate: direction by: self openingAngle negated).
	end := self borderPointOf: anOutline around: center toward: (self rotate: direction by: self openingAngle)
]

{ #category : 'initialization' }
TLBlocConnectionLoop >> borderPointOf: anOutline around: aCenter toward: aUnitVector [
	"Where the half line from the center of the node in that direction leaves the outline"

	| far |
	far := aCenter + (aUnitVector * 10000).
	^ self
		  borderPointOf: anOutline
		  on: (GLine through: aCenter asGPoint and: far asGPoint)
		  nearestTo: far
		  orElse: aCenter
]

{ #category : 'initialization' }
TLBlocConnectionLoop >> directionForOffset: anOffset [
	"The unit vector which points up, turned clockwise by an angle proportional to the offset"

	| angle |
	angle := (anOffset * 1.75) degreesToRadians.
	^ angle sin @ angle cos negated
]

{ #category : 'accessing' }
TLBlocConnectionLoop >> labelCenterFor: anExtent gap: aGap [
	"The label is beyond the loop, away from the node, in the direction of the loop"

	^ self middlePoint + (direction * (direction x abs * anExtent x / 2 + (direction y abs * anExtent y / 2) + aGap))
]

{ #category : 'accessing' }
TLBlocConnectionLoop >> middleDirection [
	"The loop is symmetrical around its direction, along which the label goes: the middle of the loop is crossed perpendicularly"

	^ direction y negated @ direction x
]

{ #category : 'initialization' }
TLBlocConnectionLoop >> openingAngle [
	"The angle between the direction of the loop and each of its ends, seen from the center of the node"

	^ 30 degreesToRadians
]

{ #category : 'initialization' }
TLBlocConnectionLoop >> rotate: aUnitVector by: anAngle [

	^ aUnitVector x * anAngle cos - (aUnitVector y * anAngle sin) @ (aUnitVector x * anAngle sin + (aUnitVector y * anAngle cos))
]
