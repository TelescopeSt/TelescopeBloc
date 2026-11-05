Class {
	#name : 'TLBlocConnectionMiddleArrow',
	#superclass : 'TLBlocConnectionArrow',
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'accessing' }
TLBlocConnectionMiddleArrow class >> styleName [

	^ #middle
]

{ #category : 'placing' }
TLBlocConnectionMiddleArrow >> directionOn: aRoute [
	"The arrow at the middle of the line points along it"

	^ aRoute unitVectorOf: aRoute middleDirection
]

{ #category : 'placing' }
TLBlocConnectionMiddleArrow >> tipOn: aRoute direction: aDirection size: aLength [
	"The arrow is centered on the middle of the line: its tip is half of its length ahead"

	^ aRoute middlePoint + (aDirection * (aLength / 2))
]
