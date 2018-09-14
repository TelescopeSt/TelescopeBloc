Class {
	#name : #TLBlocNodeConnection,
	#superclass : #BlElement,
	#instVars : [
		'fromNode',
		'toNode',
		'element'
	],
	#category : #'Telescope-Bloc'
}

{ #category : #'instance creation' }
TLBlocNodeConnection class >> createFrom: aTLBlocNodeElementFrom to: aTLBlocNodeElementTo [
	^ self new
		fromNode: aTLBlocNodeElementFrom;
		toNode: aTLBlocNodeElementTo;
		yourself
]

{ #category : #accessing }
TLBlocNodeConnection >> element [
	^ element
]

{ #category : #accessing }
TLBlocNodeConnection >> element: anObject [
	element := anObject
]

{ #category : #accessing }
TLBlocNodeConnection >> fromNode [
	^ fromNode
]

{ #category : #accessing }
TLBlocNodeConnection >> fromNode: anObject [
	fromNode := anObject.
	self element fromAnchor: (BlElementCenterAnchor element: anObject)
]

{ #category : #initialization }
TLBlocNodeConnection >> initialize [
	super initialize.
	element := BlLineElement new
		border:
			(BlBorder builder
				paint: Color gray;
				width: 2;
				build);
		yourself.
	self addChild: element
]

{ #category : #accessing }
TLBlocNodeConnection >> toNode [
	^ toNode
]

{ #category : #accessing }
TLBlocNodeConnection >> toNode: anObject [
	toNode := anObject.
	self element toAnchor: (BlElementCenterAnchor element: anObject)
]
