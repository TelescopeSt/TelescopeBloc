Extension { #name : 'TLCircle' }

{ #category : '*Telescope-Bloc' }
TLCircle class >> headOutlineAt: aTip direction: aDirection length: aLength width: aWidth [

	^ self circleHeadOutlineAt: aTip direction: aDirection length: aLength
]

{ #category : '*Telescope-Bloc' }
TLCircle class >> outlineOfExtent: anExtent [

	^ TLNotSupportedFunctionalityException signal: 'Circle is only for connections; use Ellipse'
]
