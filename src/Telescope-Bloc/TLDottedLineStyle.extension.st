Extension { #name : 'TLDottedLineStyle' }

{ #category : '*Telescope-Bloc' }
TLDottedLineStyle class >> blocBorderPaint: aPaint width: aWidth [
	"Square dots as wide as the line is thick, with gaps of the same width"

	^ BlBorder builder
		  paint: aPaint;
		  width: aWidth;
		  dashArray: {
				  aWidth.
				  aWidth };
		  build
]
