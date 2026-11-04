Extension { #name : 'TLArrow' }

{ #category : '*Telescope-Bloc' }
TLArrow class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Arrow is only usable for connections'
]
