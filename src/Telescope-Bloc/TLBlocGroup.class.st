"
I am a sub-group of a Telescope visualization, seen by the layouts of Telescope. I am a collection of the nodes and of the sub-groups of the group, and, like a node, I know my dimension and I am placed by my center, so that a layout can place a group as one node. My nodes are inside my TLBlocGroupElement, in its coordinates, so they move with it. A node which an update moves into the group, for example because an action moved it from another group, has its element moved inside my element too, and keeps its place in the view so that the layout and the animation start from there.
"
Class {
	#name : 'TLBlocGroup',
	#superclass : 'OrderedCollection',
	#instVars : [
		'element'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'instance creation' }
TLBlocGroup class >> new: aSize [
	"A collection does not initialize by default"

	^ (super new: aSize)
		  initialize;
		  yourself
]

{ #category : 'instance creation' }
TLBlocGroup class >> withElements: aCollection [
	"A group of the given nodes and sub-groups, which are moved inside the element of the group"

	| group |
	group := self new.
	aCollection do: [ :each | group addElement: each ].
	^ group
]

{ #category : 'adding' }
TLBlocGroup >> addAllFirstUnlessAlreadyPresent: someNodesOrGroups [
	"Telescope adds to a group the nodes which an update put in it, for example a node which moved from another group. Like #addElement:, this moves their Bloc element inside the element of the group, otherwise the node would stay in the element of its old group, and be placed in the coordinates of the old group. The items already in the group are found in a set: searching the group for each item made an update quadratic"

	| present newItems |
	present := self asIdentitySet.
	newItems := someNodesOrGroups reject: [ :item | present includes: item ].
	newItems do: [ :item | self moveInsideElement: item ].
	self addAllFirst: newItems
]

{ #category : 'adding' }
TLBlocGroup >> addElement: aNodeOrGroup [
	"Moves the Bloc element of a node or of a sub-group, which was added to the view when it was generated, inside the element of the group"

	aNodeOrGroup asBlocElement removeFromParent.
	element addChild: aNodeOrGroup asBlocElement.
	^ self addLast: aNodeOrGroup
]

{ #category : 'accessing' }
TLBlocGroup >> asBlocElement [
	"The Bloc element that stands for a node or a group: the element of the group"

	^ element
]

{ #category : 'layout' }
TLBlocGroup >> dimension [

	^ self localRectangle extent
]

{ #category : 'accessing' }
TLBlocGroup >> element [
	"The Bloc element which holds the nodes of the group"

	^ element
]

{ #category : 'layout' }
TLBlocGroup >> encompassingRectangle [
	"The rectangle of the group in the coordinates of its parent"

	^ self localRectangle translateBy: element measuredBounds position
]

{ #category : 'initialization' }
TLBlocGroup >> initialize [

	element := TLBlocGroupElement new
]

{ #category : 'accessing' }
TLBlocGroup >> isGroup [

	^ true
]

{ #category : 'accessing' }
TLBlocGroup >> isNode [

	^ false
]

{ #category : 'layout' }
TLBlocGroup >> localRectangle [
	"The rectangle which contains the nodes and the sub-groups of the group, in the coordinates of the element of the group"

	^ self ifEmpty: [ 0 @ 0 corner: 0 @ 0 ] ifNotEmpty: [ Rectangle merging: (self collect: #encompassingRectangle as: Array) ]
]

{ #category : 'adding' }
TLBlocGroup >> moveInsideElement: aNodeOrGroup [
	"The element stays at the same place in the view, which is not the same place in the new element: the layout then moves it, and the animation starts from where it was"

	| itemElement topLeftInView |
	itemElement := aNodeOrGroup asBlocElement.
	topLeftInView := self topLeftInViewOf: itemElement.
	itemElement removeFromParent.
	element addChild: itemElement.
	aNodeOrGroup placeAt: topLeftInView - (self topLeftInViewOf: element)
]

{ #category : 'accessing' }
TLBlocGroup >> occupyMaxSpace [

	^ false
]

{ #category : 'layout' }
TLBlocGroup >> placeAt: aTopLeft [
	"Places the element of the group by its top left corner"

	element position: aTopLeft
]

{ #category : 'layout' }
TLBlocGroup >> placement [
	"The top left corner of the element of the group, as it was last asked, in the coordinates of its parent. It does not depend on the nodes inside, which move with the element"

	^ element measuredBounds position
]

{ #category : 'layout' }
TLBlocGroup >> placementCenteredAt: aCenter [
	"The top left corner the element of the group has when the rectangle of the group is centered on the given point"

	^ aCenter - self localRectangle center
]

{ #category : 'layout' }
TLBlocGroup >> position [
	"The center of the group, as the position of a node"

	^ self encompassingRectangle center
]

{ #category : 'layout' }
TLBlocGroup >> position: aCenter [
	"A layout places the group by its center, as a node: the element moves so that the rectangle of the group is centered on it"

	element position: aCenter - self localRectangle center
]

{ #category : 'adding' }
TLBlocGroup >> topLeftInViewOf: anElement [
	"The top left corner of the element, in the coordinates of the view, whatever the groups between them"

	| topLeft current |
	topLeft := 0 @ 0.
	current := anElement.
	[ current isNil or: [ current class = TLBlocVisualization ] ] whileFalse: [
			topLeft := topLeft + current measuredBounds position.
			current := current parent ].
	^ topLeft
]
