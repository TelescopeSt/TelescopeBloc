"
A connector for the tests which counts how many times the routes of its connections are computed.
"
Class {
	#name : 'TLBlocRouteCountingConnector',
	#superclass : 'TLBlocConnector',
	#instVars : [
		'routeUpdates'
	],
	#category : 'Telescope-Bloc-Tests-Connection',
	#package : 'Telescope-Bloc-Tests',
	#tag : 'Connection'
}

{ #category : 'accessing' }
TLBlocRouteCountingConnector >> routeUpdates [

	^ routeUpdates ifNil: [ 0 ]
]

{ #category : 'updating' }
TLBlocRouteCountingConnector >> updateConnectionRoutes [

	routeUpdates := self routeUpdates + 1.
	super updateConnectionRoutes
]
