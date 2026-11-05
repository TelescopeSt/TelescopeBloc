Class {
	#name : 'TLBlocConnectionMiddleReversedArrow',
	#superclass : 'TLBlocConnectionMiddleArrow',
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'accessing' }
TLBlocConnectionMiddleReversedArrow class >> styleName [

	^ #middleReversed
]

{ #category : 'placing' }
TLBlocConnectionMiddleReversedArrow >> directionOn: aRoute [
	"The arrow at the middle of the line points backwards"

	^ (super directionOn: aRoute) ifNotNil: [ :direction | direction negated ]
]
