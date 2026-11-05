Class {
	#name : 'TLBlocSmoothEasingTest',
	#superclass : 'TestCase',
	#category : 'Telescope-Bloc-Tests-Elements',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Elements'
}

{ #category : 'tests' }
TLBlocSmoothEasingTest >> testIsHalfWayAtHalfTheTime [

	self assert: (TLBlocSmoothEasing new interpolate: 0.5) closeTo: 0.5
]

{ #category : 'tests' }
TLBlocSmoothEasingTest >> testIsSymmetric [

	#( 0.1 0.25 0.4 ) do: [ :progress | self assert: (TLBlocSmoothEasing new interpolate: progress) + (TLBlocSmoothEasing new interpolate: 1 - progress) closeTo: 1 ]
]

{ #category : 'tests' }
TLBlocSmoothEasingTest >> testNeverGoesBack [

	| previous |
	previous := 0.
	(0 to: 1 by: 0.05) do: [ :progress |
			| value |
			value := TLBlocSmoothEasing new interpolate: progress.
			self assert: value >= previous.
			previous := value ]
]

{ #category : 'tests' }
TLBlocSmoothEasingTest >> testStartsAndEndsSlowly [

	self assert: (TLBlocSmoothEasing new interpolate: 0.1) < 0.05.
	self assert: (TLBlocSmoothEasing new interpolate: 0.9) > 0.95
]

{ #category : 'tests' }
TLBlocSmoothEasingTest >> testStartsAtZeroAndEndsAtOne [

	self assert: (TLBlocSmoothEasing new interpolate: 0) closeTo: 0.
	self assert: (TLBlocSmoothEasing new interpolate: 1) closeTo: 1
]
