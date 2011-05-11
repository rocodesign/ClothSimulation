package
{
	// physics
	import org.cove.ape.*;
	import flash.display.DisplayObjectContainer;
	
	// common
	import flash.geom.Rectangle;
	import flash.geom.Matrix;

	// vis
	import flash.events.Event;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.display.GradientType;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.display.PixelSnapping;

	// gui
	import org.aswing.*;
	import org.aswing.border.TitledBorder;

	import flash.filters.BlurFilter;
	
	import org.papervision3d.cameras.*;
	import org.papervision3d.events.*;
	import org.papervision3d.materials.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.scenes.*;
	import flash.filters.GlowFilter;

	public class Simulator extends Sprite implements IConfigurable
	{
		// timing/stats
		private var stopWatch: StopWatch = new StopWatch();
		private var lastFrameTimeMs: int = 0;
		
		// auto adjuster
		private var autoAdjust: Boolean = Configuration.PHYSICS_AUTO_ADJUST_TIMESTEP;
		private var stats: Statistics = null;
		private var physWatch: StopWatch = new StopWatch();
		private var hasReduced: Boolean = false;
		private var canRaise: Boolean = false;
		private var sliderGlow: GlowFilter = new GlowFilter( 0, 1, 6, 6, 2, 1 );

		// GUI - mesh
		private var tesselationX: int = Configuration.MESH_TESSELATION_X;
		private var tesselationY: int = Configuration.MESH_TESSELATION_Y;
		private var spacingX: int = Configuration.MESH_PARTICLE_SPACING_X;
		private var spacingY: int = Configuration.MESH_PARTICLE_SPACING_Y;
		private var meshWidth: int = Configuration.MESH_WIDTH;
		private var meshHeight: int = Configuration.MESH_HEIGHT;
		private var position: Point = null;
		private var timeStepHz: int = Configuration.PHYSICS_TIMESTEP_HZ;

		public function Simulator( aStatistics: Statistics, aTimeStepHz: int, constraintCycles: int )
		{
			stats = aStatistics;

			setupPresentation();
			setupSimulation( aTimeStepHz, constraintCycles );

			// create particle picker
			picker = new ParticlePicker( clothmesh.clothGroup );
			picker.boundaries = new Rectangle( 0, 0, Configuration.OUTPUT_WIDTH, Configuration.FLOOR_Y );

			filters = [];
		}


		/////////////////////////
		// presentation logic
		/////////////////////////

		private var scene: Scene3D;
		private var rootNode: DisplayObject3D;
		private var freeCamera: FreeCamera3D;
		private var clothMat: BitmapDiffuseMaterial;

		private function setupSimulation( aTimeStepHz: int, constraintCycles: int ): void
		{
			createPhysics( aTimeStepHz, constraintCycles );

			// create floor
			floor = new Floor( Configuration.FLOOR_W/2 + Configuration.FLOOR_X + 1,
							   Configuration.FLOOR_H/2 + Configuration.FLOOR_Y + 1,
							   Configuration.FLOOR_W,
							   Configuration.FLOOR_H,
							   Configuration.FLOOR_MASS );
			APEngine.addGroup( floor );


			// construct a mesh from the particle grid

			tesselationX = Configuration.MESH_TESSELATION_X;
			tesselationY = Configuration.MESH_TESSELATION_Y;;
			position = centerMesh( meshWidth );
			spacingX = Configuration.MESH_PARTICLE_SPACING_X;
			spacingY = Configuration.MESH_PARTICLE_SPACING_Y;

			clothmesh = new ClothMesh( clothMat, position, Configuration.MESH_TESSELATION_X, Configuration.MESH_TESSELATION_Y, spacingX, spacingY );

			needMeshUpdate = true;
		}

		private function centerMesh( aWidth: int ): Point
		{
			var x: int = ( Configuration.OUTPUT_WIDTH - aWidth ) / 2.;
			var y: int = 50;
			return new Point( x, y );
		}

		private function pinMesh( aTesselationX: int ): void
		{
			AbstractParticle( clothmesh.clothGroup.particles[ 0 ] ).fixed = true;
			AbstractParticle( clothmesh.clothGroup.particles[ aTesselationX - 1 ] ).fixed = true;
			AbstractParticle( clothmesh.clothGroup.particles[ aTesselationX - 1 ] ).py += 50;
		}

		private function setupPresentation(): void
		{
			// create objects
			var tex: Bitmap = new Resources.materialCloth();

			clothMat = new BitmapDiffuseMaterial( tex.bitmapData );
			clothMat.doubleSided = true;

			x = y = 0;

			// Create scene
			scene = new Scene3D( this );

			// Create camera
			freeCamera = new FreeCamera3D();
			freeCamera.zoom = 1;
			freeCamera.y = 0;
			freeCamera.z = 0;

			// create root node
			rootNode = new DisplayObject3D( "rootNode" );
		}




		/////////////////////////
		// business logic
		/////////////////////////

		private var floor: Floor = null;
		private var picker: ParticlePicker = null;
		private var clothmesh: ClothMesh = null;

		private function createPhysics(  aTimeStepHz: int, constraintCycles: int ): void
		{
			timeStepHz = aTimeStepHz;

			// initialize physics engine
			APEngine.init( timeStepHz );
//			APEngine.container = this;
			APEngine.addMasslessForce( new Vector( 0, 9 ) );
			APEngine.damping = .98;
//			APEngine.constraintCollisionCycles = 1;
			APEngine.constraintCycles = constraintCycles;
		}

		public function getAverageMotion( absoluteValues: Boolean = false ): Point
		{
			return clothmesh.clothGroup.getAverageMotion( absoluteValues );
		}

		public function onMouseDown( evt: MouseEvent ): void
		{
			picker.onMouseDown( evt );
		}

		public function onMouseUp( evt: MouseEvent ): void
		{
			picker.onMouseUp( evt );
		}
		
		public function get particleGroup(): ClothGroup
		{
			return clothmesh.clothGroup;
		}

		private var needMeshUpdate: Boolean = false;
		public function tick( evt: Event ): void
		{
			//
			// logic
			//

			lastFrameTimeMs = stopWatch.stop();
			stopWatch.start();

			// pick particles
			picker.tick( clothmesh.clothGroup );

			// dispatch timestep (integrate particles)
			APEngine.tick( lastFrameTimeMs );

			// update particles-vertices bindings
			clothmesh.updateVertexBindings();

			// render scene to the previously bound container
			scene.renderCamera( freeCamera );

			if( needMeshUpdate )
			{
				updateMesh();
				APEngine.resetTimeAccumulator();
				stopWatch.start();
				needMeshUpdate = false;
			}
			
			// auto-adjust physics timestep
			if( autoAdjust )
			{
				if( stats.SecondsPerFrame > 0.05 )
				{
					sliderGlow.color = 0xc02020;
					sliderHz.filters = [ sliderGlow ];
	
					timeStepHz -= ( stats.SecondsPerFrame - 0.05 ) * timeStepHz;
					updateSliderHzClamped( timeStepHz );
					hasReduced = true;
					canRaise = false;
				}
				else if( /*( hasReduced || canRaise ) && */ timeStepHz < Configuration.PHYSICS_TIMESTEP_HZ && ( stats.SecondsPerFrame < 0.03 ) )
				{
					sliderGlow.color = 0x20c020;
					sliderHz.filters = [ sliderGlow ];
	
					updateSliderHzClamped( ++timeStepHz );
					hasReduced = false;
					canRaise = true;
				}
				else
				{
					canRaise = false;
					sliderHz.filters = [];
				}
			}
		}



		//
		// GUI
		//
		private var sliderX: JSlider = null;
		private var sliderY: JSlider = null;
		private var sliderW: JSlider = null;
		private var sliderH: JSlider = null;
		private var sliderHz: JSlider = null;
		private var sliderDown: Boolean = false;

		public function createUI( pane: JPanel ): void
		{
			// this configurable's box
			var p: JPanel = new JPanel( new GridLayout( 6, 2, 5, 5 ) );
			p.setPreferredWidth( 90 );
			p.setBorder( new TitledBorder( null, 'Simulation' ) );

			var lbl: JLabel;


			// mesh tesselation x
			lbl = new JLabel( 'H. tesselation:' );
			p.append( lbl );

			sliderX = new JSlider( 0, 2, 20, tesselationX );
			sliderX.setSnapToTicks( true );
			sliderX.setPaintTicks( true );
			sliderX.setShowValueTip( true );
			sliderX.addEventListener( MouseEvent.MOUSE_DOWN, onSliderMouseDown );
			sliderX.addEventListener( MouseEvent.MOUSE_UP, onSliderXMouseUp );
			p.append( sliderX );


			// mesh tesselation y
			lbl = new JLabel( 'V. tesselation:' );
			p.append( lbl );

			sliderY = new JSlider( 0, 2, 20, tesselationY );
			sliderY.setSnapToTicks( true );
			sliderY.setPaintTicks( true );
			sliderY.setShowValueTip( true );
			sliderY.addEventListener( MouseEvent.MOUSE_DOWN, onSliderMouseDown );
			sliderY.addEventListener( MouseEvent.MOUSE_UP, onSliderYMouseUp );
			p.append( sliderY );


			// mesh width
			lbl = new JLabel( 'Mesh width:' );
			p.append( lbl );

			sliderW = new JSlider( 0, 10, 200, meshWidth );
			sliderW.setSnapToTicks( true );
			sliderW.setPaintTicks( true );
			sliderW.setShowValueTip( true );
			sliderW.addEventListener( MouseEvent.MOUSE_DOWN, onSliderMouseDown );
			sliderW.addEventListener( MouseEvent.MOUSE_UP, onSliderWMouseUp );
			p.append( sliderW );


			// mesh height
			lbl = new JLabel( 'Mesh height:' );
			p.append( lbl );

			sliderH = new JSlider( 0, 10, 200, meshHeight );
			sliderH.setSnapToTicks( true );
			sliderH.setPaintTicks( true );
			sliderH.setShowValueTip( true );
			sliderH.addEventListener( MouseEvent.MOUSE_DOWN, onSliderMouseDown );
			sliderH.addEventListener( MouseEvent.MOUSE_UP, onSliderHMouseUp );
			p.append( sliderH );


			// timestep
			lbl = new JLabel( 'Physics (Hz): ' );
			p.append( lbl );

			sliderHz = new JSlider( 0, Configuration.PHYSICS_MIN_TIMESTEP_HZ, Configuration.PHYSICS_MAX_TIMESTEP_HZ, timeStepHz );
			sliderHz.setSnapToTicks( true );
			sliderHz.setPaintTicks( true );
			sliderHz.setShowValueTip( true );
			sliderHz.addEventListener( MouseEvent.MOUSE_DOWN, onSliderHzMouseDown );
			sliderHz.addEventListener( MouseEvent.MOUSE_UP, onSliderHzMouseUp );
			sliderHz.addEventListener( MouseEvent.MOUSE_MOVE, onSliderHzMouseMove );
			p.append( sliderHz );

			// automatic timestep adjustment
			var cb: JCheckBox = new JCheckBox( 'Auto adjust' );
			cb.addEventListener( MouseEvent.MOUSE_UP, onAutoAdjustMouseUp );
			p.append( cb );
			cb.setSelected( Configuration.PHYSICS_AUTO_ADJUST_TIMESTEP );
			
			sliderHz.setEnabled( Configuration.PHYSICS_AUTO_ADJUST_TIMESTEP == false );

			pane.append( p );
		}

		private function onSliderMouseDown( evt: MouseEvent ): void
		{
			clothmesh.setToWireframe( true );
			sliderDown = true;
		}

		private function onSliderHzMouseDown( evt: MouseEvent ): void
		{
			onSliderMouseDown( evt );
			clothmesh.setToWireframe( false );
		}

		private function onSliderXMouseUp( evt: MouseEvent ): void
		{
			if( sliderDown )
			{
				sliderDown = false;
	
				tesselationX = sliderX.getValue();
				needMeshUpdate = true;
				clothmesh.setToWireframe( false );
			}
		}

		private function onSliderYMouseUp( evt: MouseEvent ): void
		{
			if( sliderDown )
			{
				sliderDown = false;

				tesselationY = sliderY.getValue();
				needMeshUpdate = true;
				clothmesh.setToWireframe( false );
			}
		}

		private function onSliderWMouseUp( evt: MouseEvent ): void
		{
			if( sliderDown )
			{
				sliderDown = false;

				meshWidth = sliderW.getValue();
				needMeshUpdate = true;
				clothmesh.setToWireframe( false );
			}
		}

		private function onSliderHMouseUp( evt: MouseEvent ): void
		{
			if( sliderDown )
			{
				sliderDown = false;

				meshHeight = sliderH.getValue();
				needMeshUpdate = true;
				clothmesh.setToWireframe( false );
			}
		}

		private function onSliderHzMouseUp( evt: MouseEvent ): void
		{
			if( sliderDown )
			{
				sliderDown = false;

				timeStepHz = sliderHz.getValue();
				APEngine.resetTimeAccumulator();
				APEngine.TimeStepHz = timeStepHz;
			}
		}

		private function onAutoAdjustMouseUp( evt: MouseEvent ): void
		{
			autoAdjust = !autoAdjust;
			sliderHz.setEnabled( !autoAdjust );
		}

		private function onSliderHzMouseMove( evt: MouseEvent ): void
		{
				timeStepHz = sliderHz.getValue();
				APEngine.resetTimeAccumulator();
				APEngine.TimeStepHz = timeStepHz;
		}

		private function updateSliderHzClamped( aTimeStepHz: int ): void
		{
			timeStepHz = aTimeStepHz;

			// clamp
			if( timeStepHz < Configuration.PHYSICS_MIN_TIMESTEP_HZ ) { timeStepHz = Configuration.PHYSICS_MIN_TIMESTEP_HZ; }
			if( timeStepHz > Configuration.PHYSICS_MAX_TIMESTEP_HZ ) { timeStepHz = Configuration.PHYSICS_MAX_TIMESTEP_HZ; }
			
			sliderHz.setValue( aTimeStepHz );
			APEngine.resetTimeAccumulator();
			APEngine.TimeStepHz = timeStepHz;
		}

		private function updateMesh(): void
		{
			// detach old if any
			if( clothmesh.clothGroup )
			{
				rootNode.removeChild( clothmesh );
				scene.removeChild(rootNode);

				APEngine.removeGroup( clothmesh.clothGroup );
				clothmesh.clothGroup.removeCollidable( floor );
			}

			position = centerMesh( meshWidth );
			spacingX = Configuration.MESH_PARTICLE_SPACING_X;
			spacingY = Configuration.MESH_PARTICLE_SPACING_Y;
			clothmesh.buildSized( position, tesselationX, tesselationY, meshWidth, meshHeight );
			clothmesh.x = clothmesh.y = 0; clothmesh.z = 1;

			clothmesh.clothGroup.addCollidable( floor );
			APEngine.addGroup( clothmesh.clothGroup );

			pinMesh( tesselationX );

			rootNode.addChild( clothmesh );
			scene.addChild(rootNode);
		}
	}
}