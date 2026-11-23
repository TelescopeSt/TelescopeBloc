"
I let an element of a node or of a connection change its colors progressively when an interaction changes its style, for example to highlight it, instead of jumping to them.
The element tells me the colors its style gives each time it applies it (#showColors:), and the connector asks me to go from the ones shown before to them (#easeColorsDuring:). A change during a transition goes on from the colors on the screen. The element knows how to show colors (#applyColors:): an array of colors, the same for each of them.
"
Trait {
	#name : 'TTLBlocEasedColors',
	#instVars : [
		'shownColors',
		'colorsBeforeUpdate',
		'colorTransition'
	],
	#category : 'Telescope-Bloc-Elements',
	#package : 'Telescope-Bloc',
	#tag : 'Elements'
}

{ #category : 'colors' }
TTLBlocEasedColors >> applyColors: someColors [
	"Shows the colors, in the order of the ones given to #showColors:"

	^ self explicitRequirement
]

{ #category : 'colors' }
TTLBlocEasedColors >> easeColorsDuring: aDuration [
	"Goes from the colors shown before the style was applied again to the ones it gives, progressively. A transition in progress, or not started yet, stops first, whether or not the colors changed: the style which was just applied is the one to show, and the new transition starts from the colors on the screen"

	| from to |
	colorTransition ifNotNil: [ :running |
			running stop.
			self dequeueTask: running.
			colorTransition := nil ].
	(colorsBeforeUpdate isNil or: [ colorsBeforeUpdate = shownColors ]) ifTrue: [ ^ self ].
	(colorsBeforeUpdate size = shownColors size and: [ colorsBeforeUpdate , shownColors allSatisfy: [ :color | color isColor ] ]) ifFalse: [ ^ self ].
	from := colorsBeforeUpdate.
	to := shownColors.
	self showColorsAt: 0 from: from to: to.
	colorTransition := BlNumberTransition new
		                   from: 0;
		                   to: 1;
		                   duration: aDuration;
		                   easing: TLBlocSmoothEasing new;
		                   onStepDo: [ :progress | self showColorsAt: progress from: from to: to ];
		                   yourself.
	self addAnimation: colorTransition
]

{ #category : 'colors' }
TTLBlocEasedColors >> showColors: someColors [
	"The style was applied and gives these colors, which are shown at once. The ones shown before are kept, for #easeColorsDuring:"

	colorsBeforeUpdate := shownColors.
	shownColors := someColors
]

{ #category : 'colors' }
TTLBlocEasedColors >> showColorsAt: aProgress from: someColors to: otherColors [
	"The colors between the ones of the start and the ones of the end, at the progress, from 0 to 1"

	shownColors := someColors with: otherColors collect: [ :from :to | from interpolateTo: to at: aProgress ].
	self applyColors: shownColors
]
