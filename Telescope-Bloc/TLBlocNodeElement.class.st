Class {
	#name : #TLBlocNodeElement,
	#superclass : #BlElement,
	#instVars : [
		'dimension',
		'position'
	],
	#category : #'Telescope-Bloc'
}

{ #category : #accessing }
TLBlocNodeElement >> customizeFrom: aTLStyleSheet [ 
	self background: aTLStyleSheet backgroundColor.
	self dimension: aTLStyleSheet width @ aTLStyleSheet height.
	self geometry: aTLStyleSheet shape obtainTLBlocShape.
	self border: (BlBorder paint: aTLStyleSheet borderColor width: aTLStyleSheet borderWidth)
]

{ #category : #accessing }
TLBlocNodeElement >> dimension [
	^ dimension
]

{ #category : #accessing }
TLBlocNodeElement >> dimension: anObject [
	dimension := anObject
]

{ #category : #accessing }
TLBlocNodeElement >> isNode [
	^ true
]

{ #category : #dimension }
TLBlocNodeElement >> occupyMaxSpace [
	^ false
]

{ #category : #accessing }
TLBlocNodeElement >> position [
	^ position
]

{ #category : #accessing }
TLBlocNodeElement >> position: aPoint [ 
	position := aPoint.
	^ self relocate: aPoint 
]
