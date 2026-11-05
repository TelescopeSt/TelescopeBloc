"
I am a baseline of the Bloc connector for Telescope. I depend on the stable Bloc, the releases tagged v3.x.x. I depend on the core of Telescope, and on its demo group only for the demo browser. The shapes of the nodes use the Geometry project, which is part of Pharo. I define the packages and groups of the connector, of its demo browser and of its tests.
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
				package: 'Telescope-Bloc-Demo' with: [ spec requires: #( 'Telescope-Bloc' 'TelescopeDemo' ) ];
				package: 'Telescope-Bloc-Tests' with: [ spec requires: #( 'Telescope-Bloc' 'Telescope-Bloc-Demo' ) ].

			"Groups"
			spec
				group: 'all' with: #( 'default' );
				group: 'core' with: #( 'Telescope-Bloc' );
				group: 'demo' with: #( 'Telescope-Bloc-Demo' );
				group: 'default' with: #( 'core' 'demo' 'tests' );
				group: 'tests' with: #( 'Telescope-Bloc-Tests' ) ]
]

{ #category : 'dependencies' }
BaselineOfTelescopeBloc >> bloc: spec [
	"The stable Bloc: the releases of the version 3, which are tagged v3.x.x"

	spec baseline: 'Bloc' with: [ spec repository: 'github://pharo-graphics/Bloc:v3.0.0/src' ]
]

{ #category : 'dependencies' }
BaselineOfTelescopeBloc >> telescope: spec [
	"The core of Telescope, which the connector needs"

	spec baseline: 'Telescope' with: [
			spec
				loads: #( 'core' );
				repository: 'github://TelescopeSt/Telescope:v2.x.x/src' ].

	spec project: 'TelescopeDemo' copyFrom: 'Telescope' with: [ spec loads: #( 'demo' ) ]
]
