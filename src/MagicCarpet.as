package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import org.aswing.*;

	// metadata
	[ SWF( backgroundColor = '#e0e0e0', width = '400', height = '600' ) ]
	
	public class MagicCarpet extends Sprite
	{
		// background and suspend panel
		private var background: Background = null;
		private var suspendPanel: Sprite = null;

		// the simulator
		private var simulator: Simulator = null;
		
		// the configurator
		private var configurator: Configurator = null;

		// output
		private var output: Output = null;
		private var outbmp: Bitmap = null;
		private var outdata: BitmapData = null;

		// fx
		private var effects: Effects = null;

		// postprocess
		private var postproc: PostProcessor = null;

		// profiling
		private var stats: Statistics = null;


		public function MagicCarpet()
		{
			// setup stage
			stage.scaleMode = Configuration.STAGE_SCALEMODE;
			stage.displayState = Configuration.STAGE_DISPLAYSTATE;
			stage.frameRate = Configuration.STAGE_FRAMERATE;
			stage.stageFocusRect = false;

			// setup global resources
			Resources.setup( stage );

			// create statistics
			stats = new Statistics();

			// create the demo (suspended)			
			createCarpetDemo();

			// create topmost panel
			createPanel();
			addChild( suspendPanel );
			addEventListener(MouseEvent.CLICK,mouseClickHandler)
		}

		private function mouseClickHandler(event:MouseEvent):void {
			trace(simulator.visible);
			simulator.visible = false;
		}
		
		
		private function createPanel(): void
		{
			// create panel
			suspendPanel = new Sprite();
			suspendPanel.buttonMode = true;
			suspendPanel.graphics.clear();
			suspendPanel.graphics.beginFill( 0, .5 );
			suspendPanel.graphics.drawRect( 0, 0, Configuration.STAGE_WIDTH, Configuration.STAGE_HEIGHT );
			suspendPanel.graphics.endFill();

			
			// add label
			var o: InteractiveObject = Resources.createTextField( 'Click to activate', 0xffffff, 30, true );
			o.mouseEnabled = false;
			o.x = ( Configuration.STAGE_WIDTH - o.width ) / 2;
			o.y = 40;

			// setup filters
			o.filters = [ new GlowFilter( 0xff0000, 1, 6, 6, 2, 2 ) ];
			this.filters = [ new BlurFilter( 4, 4, 2 ) ];
			suspendPanel.addChild( o );

			// setup events
			suspendPanel.addEventListener( MouseEvent.MOUSE_UP, this.onStartDemo );
		}

		private function onStartDemo( evt: MouseEvent ): void
		{
			this.filters = [];
			var o: DisplayObject = suspendPanel.getChildAt( 0 );
			o.filters = [];
			suspendPanel.buttonMode = false;
			removeChild( suspendPanel );
			suspendPanel.removeEventListener( MouseEvent.MOUSE_UP, this.onStartDemo );

			prepareAndRun();
		}

		private function createCarpetDemo(): void
		{
			// create the background
			background = new Background( Configuration.OUTPUT_WIDTH, Configuration.OUTPUT_HEIGHT, Configuration.LINE_OF_SIGHT );

			// create the configurator
			configurator = new Configurator( this );

			// create the simulator
			simulator = new Simulator( stats, Configuration.PHYSICS_TIMESTEP_HZ, Configuration.PHYSICS_CONSTRAINT_CYCLES );
			configurator.addConfigurable( simulator );

			// create output
			output = new Output( onOutputReady, onBeforeOutputReady );
			configurator.addConfigurable( output );

			// create effects
			effects = new Effects( simulator, output );
			configurator.addConfigurable( effects );

			// create post processor
			postproc = new PostProcessor();
			configurator.addConfigurable( postproc );

			// setup draw order
			//
			// 0 - output	( see "onOutputReady" callback )
			// 1 - effects
			// 2 - configurator
			// 3 - stats
			addChild( effects );
			addChild( configurator );
			addChild( stats );
		}

		private function prepareAndRun(): void
		{
			// setup events
			stage.addEventListener( MouseEvent.MOUSE_DOWN, simulator.onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, simulator.onMouseUp );
			addEventListener( Event.ENTER_FRAME, tick );
		}

		private function onBeforeOutputReady( output: Output ): void
		{
			// output is going to be rebuilt
			if( output.outputBitmap )
			{
				removeChild( output.outputBitmap );
			}
		}

		private function onOutputReady( output: Output ): void
		{
			// output rebuilt, add it
			addChildAt( output.outputBitmap, 0 );
			
			// rebuild effects if needed
			if( effects )
			{
				effects.rebuild( output );
			}
		}

		private function tick( evt: Event ): void
		{
			// get references to output
			outbmp = output.outputBitmap;
			outdata = output.outputBitmapData;
			
			// begin profiling
			stats.beginTick();

			// clear bitmaps' data
			outdata.fillRect( outdata.rect, 0 );

			// dispatch tick
			simulator.tick( evt );

			// draw background
			outdata.draw( background, output.outputMatrix, null );

			// update effects
			effects.tick( Effects.PS_BEFORE_DRAW );

			// draw simulator to output bitmap
			outdata.draw( simulator, output.outputMatrix, null );

			// update effects
			effects.tick( Effects.PS_AFTER_DRAW );

			// do postprocessing if any
			postproc.draw( outbmp, outbmp );

			// end profiling
			stats.endTick();
		}

	}
}
