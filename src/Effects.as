package
{
	import org.aswing.*;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import org.aswing.border.TitledBorder;
	import flash.filters.BlurFilter;

	public class Effects extends Sprite implements IConfigurable
	{
		public static const PS_BEFORE_DRAW: int = 1 << 1;
		public static const PS_AFTER_DRAW: int = 1 << 2;

		private var simulator: Simulator = null;
		private var reflection: GlassyReflection = null;
		private var clothShadow: ClothShadow = null;
		private var output: Output = null;

		// switches
		private var shadowEnabled: Boolean = Configuration.FX_SHADOW_ENABLED;
		private var motionBlurEnabled: Boolean = Configuration.FX_MOTION_BLUR_ENABLED;
		private var reflectionEnabled: Boolean = Configuration.FX_REFLECTION_ENABLED;

		public function Effects( aSimulator: Simulator, anOutput: Output )
		{
			simulator = aSimulator;
			output = anOutput;
			
			// create shadow
			clothShadow = new ClothShadow( Configuration.LINE_OF_SIGHT, Configuration.OUTPUT_WIDTH );
			addChild( clothShadow );

			// create reflection
			reflection = new GlassyReflection( output );
			addChild( reflection );
			
			updateVisibles();
		}

		private function updateVisibles(): void
		{
			clothShadow.visible = shadowEnabled;
			reflection.visible = reflectionEnabled;
		}

		public function tick( pipelineState: int ): void
		{
			switch( pipelineState )
			{
				case PS_BEFORE_DRAW:
				{

					clothShadow.tick( simulator.particleGroup );
					reflection.clear();
					reflection.tick( simulator, output.outputMatrix );

					if( motionBlurEnabled )
					{
						simulator.filters = [ updateMotionBlur( simulator.getAverageMotion( true ) ) ];
					}
					
					break;
				}
				
				case PS_AFTER_DRAW:
				{
					if( motionBlurEnabled )
					{
						simulator.filters = [];
					}
					break;
				}
			}
		}

		// Try to mimic a directional soft blur by reducing
		// the blur itself on the slowest direction
		//
		// TODO angular motion isn't really simulated, a 3x3 kernel convolution
		//		filter?  
		private function updateMotionBlur( motion: Point ): BlurFilter
		{
			var blurX: Number = motion.x * Configuration.MOTION_BLUR_MUL;
			var blurY: Number = motion.y * Configuration.MOTION_BLUR_MUL;
			if( blurX > blurY )
			{
				blurY *= Configuration.MOTION_BLUR_DAMP;
			}
			else if( blurY > blurX )
			{
				blurX *= Configuration.MOTION_BLUR_DAMP;
			}
			
			blurX = Math.min( blurX, Configuration.MAX_MOTION_BLUR );
			blurY = Math.min( blurY, Configuration.MAX_MOTION_BLUR );
			Resources.BlurEffects.blurX = blurX;
			Resources.BlurEffects.blurY = blurY;
			
			return Resources.BlurEffects;
		}


		//
		// GUI
		//

		public function createUI( pane: JPanel ): void
		{
			// this configurable's box
			var p: JPanel = new JPanel( new SoftBoxLayout( SoftBoxLayout.Y_AXIS ) );
			p.setPreferredWidth( 90 );
			p.setBorder( new TitledBorder( null, 'Fx' ) );

			// output size ratio
			var sbox: JPanel = new JPanel( new GridLayout( 2, 2, 5, 5 ) );
			p.append( sbox );


			// shadow enabled yes/no
			var cb: JCheckBox = new JCheckBox( 'Shadow' );
			cb.setSelected( shadowEnabled );
			cb.setHorizontalAlignment( AbstractButton.LEFT );
			cb.setMargin( Resources.marginLeft );
			cb.addEventListener( MouseEvent.MOUSE_UP, onShadowEnabled );
			sbox.append( cb );

			// reflection enabled yes/no
			cb = new JCheckBox( 'Reflection' );
			cb.setSelected( shadowEnabled );
			cb.setHorizontalAlignment( AbstractButton.LEFT );
			cb.setMargin( Resources.marginLeft );
			cb.addEventListener( MouseEvent.MOUSE_UP, onReflectionEnabled );
			sbox.append( cb );

			// reflection enabled yes/no
			cb = new JCheckBox( 'Motion-blur' );
			cb.setSelected( shadowEnabled );
			cb.setHorizontalAlignment( AbstractButton.LEFT );
			cb.setMargin( Resources.marginLeft );
			cb.addEventListener( MouseEvent.MOUSE_UP, onMotionBlurEnabled );
			sbox.append( cb );
						
			pane.append( p );
		}

		private function onShadowEnabled( evt: MouseEvent ): void
		{
			shadowEnabled = !shadowEnabled;
			updateVisibles();
		}

		private function onReflectionEnabled( evt: MouseEvent ): void
		{
			reflectionEnabled = !reflectionEnabled;
			updateVisibles();
		}

		private function onMotionBlurEnabled( evt: MouseEvent ): void
		{
			motionBlurEnabled = !motionBlurEnabled;
		}

		public function rebuild( anOutput: Output ): void
		{
			// rebuild effects
			if( reflection )
			{
				removeChild( reflection );
				reflection = new GlassyReflection( anOutput );
				addChildAt( reflection, 1 );
			}
		}

	}
}