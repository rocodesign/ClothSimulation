package
{
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	
	
	// default settings
	public class Configuration
	{
		// immutable settings
		public static const STAGE_FRAMERATE: int = 200;
		public static const STAGE_WIDTH: Number = 400;
		public static const STAGE_HEIGHT: Number = 600;
		public static const STAGE_COLOR: int = 0xe0e0e0;
		public static const STAGE_SCALEMODE: String = StageScaleMode.SHOW_ALL;
		public static const STAGE_DISPLAYSTATE: String = StageDisplayState.NORMAL;

		public static const OUTPUT_WIDTH: Number = 400;
		public static const OUTPUT_HEIGHT: Number = 300;
		public static const FLOOR_X: Number = -200;
		public static const FLOOR_Y: Number = OUTPUT_HEIGHT * .76;
		public static const LINE_OF_SIGHT: Number = FLOOR_Y;
		public static const FLOOR_W: Number = 1200;
		public static const FLOOR_H: Number = OUTPUT_HEIGHT - ( LINE_OF_SIGHT + SHADOW_OFFSET );
		public static const FLOOR_MASS: Number = 100;
		public static const SHADOW_OFFSET: Number = -3;		// due to vertical blur changing its height
		public static const BACKGROUND_OFFSET: int = -40;


		// simulation settings
		
			// engine settings
			public static const PHYSICS_TIMESTEP_HZ: int = 60;
			public static const PHYSICS_MIN_TIMESTEP_HZ: int = 10;
			public static const PHYSICS_MAX_TIMESTEP_HZ: int = 120;
			public static const PHYSICS_CONSTRAINT_CYCLES: int = 3;
			public static const PHYSICS_AUTO_ADJUST_TIMESTEP: Boolean = true;

			// mesh settings			
			public static const MESH_TESSELATION_X: int = 10;
			public static const MESH_TESSELATION_Y: int = 10;
			public static const MESH_PARTICLE_SPACING_X: int = 7;
			public static const MESH_PARTICLE_SPACING_Y: int = 7;
			public static const MESH_WIDTH: int = 80;
			public static const MESH_HEIGHT: int = 80;


		// presentation settings
				
			// background
			public static const BACKGROUND_COLOR: int = 0xff9f00;	// 0x80fff0;

			// output
			public static const OUTPUT_SCALE_RATIO: Number = 1;

			// effects

				// shadow
				public static const FX_SHADOW_ENABLED: Boolean = true;
			
				// reflection
				public static const FX_REFLECTION_ENABLED: Boolean = true;
				
				// motion blur
				public static const FX_MOTION_BLUR_ENABLED: Boolean = true;
					public static const MOTION_BLUR_MUL: Number = 1.5;
					public static const MOTION_BLUR_DAMP: Number = .2;
					public static const MOTION_BLUR_QUALITY: Number = 2;
					public static const MAX_MOTION_BLUR: int = 20;

	
			// post processing
			public static const	POSTPROCESS_ENABLED: Boolean = true;
			public static const POSTPROCESS_RATIO: Number = .5;
			public static const POSTPROCESS_BLUR_AMOUNT: Number = 24 * POSTPROCESS_RATIO;
			public static const POSTPROCESS_BLUR_QUALITY: Number = 2;
	}
}