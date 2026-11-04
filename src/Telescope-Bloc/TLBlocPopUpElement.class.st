"
I am a pop up of a Telescope visualization of Bloc: a small dark rounded box with a soft shadow and the lines of a text in light letters, which fades in, shown above the window near the element of a node, for example while the mouse is over the node. I am placed outside of the node on the side of the position of the action (a TLPosition), centered on the axes where the position is at the center, and I stay inside the window. I do not take the mouse, otherwise the mouse would leave the node I am shown for. There is one of me in a window at most, and I know my owner, the element of the node.
"
Class {
	#name : 'TLBlocPopUpElement',
	#superclass : 'BlElement',
	#instVars : [
		'lines',
		'anchor',
		'placement',
		'owner'
	],
	#category : 'Telescope-Bloc-Menu',
	#package : 'Telescope-Bloc',
	#tag : 'Menu'
}

{ #category : 'showing' }
TLBlocPopUpElement class >> closeIn: aRoot [

	(aRoot children select: [ :child | child class = self ]) do: #removeFromParent
]

{ #category : 'showing' }
TLBlocPopUpElement class >> isShownIn: aRoot [

	^ aRoot children anySatisfy: [ :child | child class = self ]
]

{ #category : 'showing' }
TLBlocPopUpElement class >> showText: aString near: anElement position: aTLPosition [
	"Shows the text above everything in the window of the element, near the element. The pop ups which were shown are closed: there is only one"

	| popUp root |
	root := anElement space root.
	self closeIn: root.
	popUp := self new
		         text: aString;
		         owner: anElement;
		         anchoredAt: anElement boundsInSpace asRectangle position: aTLPosition;
		         yourself.
	root addChild: popUp.
	popUp fadeIn.
	^ popUp
]

{ #category : 'showing' }
TLBlocPopUpElement class >> shownIn: aRoot [
	"The pop up which is shown in the window, or nil"

	^ aRoot children
		  detect: [ :child | child class = self ]
		  ifNone: [ nil ]
]

{ #category : 'initialization' }
TLBlocPopUpElement >> anchoredAt: aRectangle position: aTLPosition [
	"The rectangle of the node in the window, and where the pop up is relatively to it"

	anchor := aRectangle.
	placement := aTLPosition
]

{ #category : 'accessing' }
TLBlocPopUpElement >> backgroundColor [

	^ Color r: 0.14 g: 0.17 b: 0.24
]

{ #category : 'layout' }
TLBlocPopUpElement >> coordinateFor: aSide on: aSize between: aStart and: anEnd [
	"The coordinate of the pop up on an axis, from its side on the node: before the start (left, top), centered, or after the end (right, bottom)"

	aSide = #left ifTrue: [ ^ aStart - aSize - self gap ].
	aSide = #top ifTrue: [ ^ aStart - aSize - self gap ].
	aSide = #right ifTrue: [ ^ anEnd + self gap ].
	aSide = #bottom ifTrue: [ ^ anEnd + self gap ].
	^ aStart + anEnd - aSize / 2
]

{ #category : 'initialization' }
TLBlocPopUpElement >> fadeIn [
	"The pop up appears progressively once it is in the window"

	self opacity: 0.
	self addAnimation: (BlOpacityAnimation new
			 opacity: 1;
			 duration: 140 milliSeconds;
			 yourself)
]

{ #category : 'accessing' }
TLBlocPopUpElement >> gap [
	"The space in pixels between the node and the pop up, on the sides where the pop up is outside of the node"

	^ 4
]

{ #category : 'initialization' }
TLBlocPopUpElement >> initialize [
	"A dark rounded box with a soft shadow and some lines of white text. It does not take the mouse, otherwise it would make the mouse leave the node it is shown for. It stays near the node, and in the window, once its size is known"

	super initialize.
	lines := #(  ).
	self
		layout: BlLinearLayout vertical;
		constraintsDo: [ :layoutConstraints |
				layoutConstraints horizontal fitContent.
				layoutConstraints vertical fitContent ];
		padding: (BlInsets
				 top: 6
				 left: 11
				 bottom: 6
				 right: 11);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 7);
		background: self backgroundColor;
		border: (BlBorder paint: (Color white alpha: 0.12) width: 1);
		effect: (BlGaussianShadowEffect color: (Color black alpha: 0.35) width: 9 offset: 0 @ 3);
		preventMeAndChildrenMouseEvents;
		addEventHandlerOn: BlElementLayoutComputedEvent do: [ :event | self placeNearAnchor ]
]

{ #category : 'accessing' }
TLBlocPopUpElement >> lines [
	"The text of the pop up, line by line"

	^ lines
]

{ #category : 'accessing' }
TLBlocPopUpElement >> owner [
	"The element of the node the pop up is shown for"

	^ owner
]

{ #category : 'accessing' }
TLBlocPopUpElement >> owner: anElement [

	owner := anElement
]

{ #category : 'layout' }
TLBlocPopUpElement >> placeNearAnchor [
	"The pop up is outside of the node, on the side of the position: on the left of the node for a position at its left, centered when the position is at the center. It is moved back inside the window when it would be outside"

	| target window |
	(anchor isNil or: [ self parent isNil ]) ifTrue: [ ^ self ].
	window := self parent extent.
	target := (self
		           coordinateFor: placement horizontal
		           on: self extent x
		           between: anchor left
		           and: anchor right) @ (self
		           coordinateFor: placement vertical
		           on: self extent y
		           between: anchor top
		           and: anchor bottom).
	target := ((target x min: window x - self extent x) max: 0) @ ((target y min: window y - self extent y) max: 0).
	self measuredBounds position = target ifFalse: [ self position: target ]
]

{ #category : 'initialization' }
TLBlocPopUpElement >> text: aString [
	"A line of light text for each line of the text"

	lines := aString lines asArray.
	lines do: [ :line |
			self addChild: (BlTextElement new
					 text: ((line asRopedText fontSize: 12) foreground: self textColor);
					 yourself) ]
]

{ #category : 'accessing' }
TLBlocPopUpElement >> textColor [

	^ Color r: 0.94 g: 0.96 b: 0.99
]
