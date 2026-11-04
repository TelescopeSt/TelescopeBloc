"
I am the easing of the animations of the Bloc connector: the elements start and end their move slowly and go faster in the middle, instead of moving at a constant speed. I am half a cosine, from 0 to 1.
"
Class {
	#name : 'TLBlocSmoothEasing',
	#superclass : 'BlEasing',
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'interpolation' }
TLBlocSmoothEasing >> interpolate: aProgress [
	"Starts and ends slowly, and goes faster in the middle: half a cosine, from 0 to 1"

	^ 1 - (aProgress * Float pi) cos / 2
]
