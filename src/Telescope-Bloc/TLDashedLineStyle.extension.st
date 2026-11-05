Extension { #name : 'TLDashedLineStyle' }

{ #category : '*Telescope-Bloc' }
TLDashedLineStyle class >> blocBorderPaint: aPaint width: aWidth [
	"Segments four times as long as the line is thick, with gaps of two thicknesses"

	^ BlBorder builder
		  paint: aPaint;
		  width: aWidth;
		  dashArray: {
				  (aWidth * 4 max: 4).
				  (aWidth * 2 max: 2) };
		  build
]
