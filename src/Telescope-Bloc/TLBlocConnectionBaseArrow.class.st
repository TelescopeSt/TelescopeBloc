Class {
	#name : 'TLBlocConnectionBaseArrow',
	#superclass : 'TLBlocConnectionArrow',
	#category : 'Telescope-Bloc-Connection',
	#package : 'Telescope-Bloc',
	#tag : 'Connection'
}

{ #category : 'accessing' }
TLBlocConnectionBaseArrow class >> styleName [

	^ #base
]

{ #category : 'placing' }
TLBlocConnectionBaseArrow >> directionOn: aRoute [
	"The arrow at the start of the line points backwards, into the source"

	^ aRoute startDirection ifNotNil: [ :direction | direction negated ]
]

{ #category : 'placing' }
TLBlocConnectionBaseArrow >> tipOn: aRoute direction: aDirection size: aLength [

	^ aRoute start
]
