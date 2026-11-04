Extension { #name : 'TLArrow' }

{ #category : '*Telescope-Bloc' }
TLArrow class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Arrow is only usable for connections'
]

{ #category : '*Telescope-Bloc' }
TLArrow class >> polygonPoints [
	"A triangle whose base is curved inwards"

	^ {
		  (0 @ 1).
		  (1 @ -1).
		  (0 @ -0.4).
		  (-1 @ -1) }
]
