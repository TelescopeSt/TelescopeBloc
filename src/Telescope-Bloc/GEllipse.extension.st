Extension { #name : 'GEllipse' }

{ #category : '*Telescope-Bloc' }
GEllipse >> asBlocGeometry [
	"The ellipse is as large as the Bloc element which gets the geometry"

	^ BlEllipseGeometry new
]

{ #category : '*Telescope-Bloc' }
GEllipse >> translatedCopyBy: aPoint [
	"A new ellipse moved by the point. translateBy: moves the ellipse itself, and a copy shares the points of the original"

	^ GEllipse center: (self center asPoint + aPoint) asGPoint vertex: (self vertex asPoint + aPoint) asGPoint coVertex: (self coVertex asPoint + aPoint) asGPoint
]
