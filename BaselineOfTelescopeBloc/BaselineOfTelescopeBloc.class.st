"
I am a baseline of the Bloc connector for Telescope. I depend on the Bloc dev branch, which I load with Telescope. I define the packages and groups of the connector and its tests.
"
Class {
	#name : 'BaselineOfTelescopeBloc',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTelescopeBloc',
	#package : 'BaselineOfTelescopeBloc'
}

{ #category : 'baselines' }
BaselineOfTelescopeBloc >> baseline: spec [

	<baseline>
	spec for: #common do: [ "Dependencies"
			self
				bloc: spec;
				telescope: spec.

			"Packages"
			spec
				package: 'Telescope-Bloc' with: [ spec requires: #( 'Telescope' 'Bloc' ) ];
				package: 'Telescope-Bloc-Tests' with: [ spec requires: #( 'Telescope-Bloc' ) ].

			"Groups"
			spec
				group: 'all' with: #( 'default' );
				group: 'core' with: #( 'Telescope-Bloc' );
				group: 'default' with: #( 'core' 'tests' );
				group: 'tests' with: #( 'Telescope-Bloc-Tests' ) ]
]

{ #category : 'dependencies' }
BaselineOfTelescopeBloc >> bloc: spec [

	spec baseline: 'Bloc' with: [ spec repository: 'github://pharo-graphics/Bloc:dev/src' ]
]

{ #category : 'dependencies' }
BaselineOfTelescopeBloc >> telescope: spec [

	spec baseline: 'Telescope' with: [ spec repository: 'github://TelescopeSt/Telescope:v2.x.x/src' ]
]
