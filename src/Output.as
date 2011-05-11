package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import org.aswing.*;
	import flash.events.MouseEvent;
	import org.aswing.border.TitledBorder;
	import flash.display.IBitmapDrawable;
	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import org.aswing.event.ReleaseEvent;

	public class Output implements IConfigurable
	{
		private var outMatrix: Matrix = null;
		private var outInvMatrix: Matrix = null;
		private var outRatio: Number;
		private var outInvRatio: Number;
		private var outBmp: Bitmap = null;
		private var outBmpData: BitmapData = null;
		
		// callbacks
		private var onReady: Function = null;
		private var onBeforeReady: Function = null;

		// gui
		private const RATIO_STRING: String = 'Output size ratio: ';
		private var ratioLabel: JLabel;
		private var slider: JSlider;

		public function Output( onReadyHandler: Function, onBeforeReadyHandler: Function )
		{
			onReady = onReadyHandler;
			onBeforeReady = onBeforeReadyHandler;
			create();
		}

		//
		// accessors
		//

		public function get ratio(): Number
		{
			return outRatio;
		}
		
		public function get invRatio(): Number
		{
			return outInvRatio;
		}

		public function get outputBitmap(): Bitmap
		{
			return outBmp;
		}
		
		public function get outputBitmapData(): BitmapData
		{
			return outBmpData;
		}

		public function get outputMatrix(): Matrix
		{
			return outMatrix;
		}
		
		public function get outputInvMatrix(): Matrix
		{
			return outInvMatrix;
		}

		//
		// construction
		//
		private function create( aRatio: Number = Configuration.OUTPUT_SCALE_RATIO ): void
		{
			// dispatch event
			//
			// note:
			// pass the 'this' pointer since this callback could
			// be get called from inside the constructor instead from the
			// user interaction: so, pass the this pointer and use this
			onBeforeReady( this );

			outRatio = aRatio;
			outInvRatio = 1. / outRatio;

			outBmpData = new BitmapData( Configuration.OUTPUT_WIDTH * outRatio,
										 Configuration.OUTPUT_HEIGHT * outRatio,
										 true, 0 );
			outBmp = new Bitmap( outBmpData, PixelSnapping.AUTO, false );

			outBmp.x = outBmp.y = 0;

			// stretch
			outBmp.width = Configuration.OUTPUT_WIDTH;
			outBmp.height = Configuration.OUTPUT_HEIGHT;
			outBmp.filters = [];
			
			// rebuild output matrix
			outMatrix = new Matrix( outRatio, 0, 0, outRatio );
			outInvMatrix = new Matrix( outInvRatio, 0, 0, outInvRatio );
			
			// dispatch event
			//
			// note:
			// pass the 'this' pointer since this callback could
			// be get called from inside the constructor instead from the
			// user interaction: so, pass that and use this
			onReady( this );
		}


		//
		// GUI
		//

		public function createUI( pane: JPanel ): void
		{
			// this configurable's box
			var p: JPanel = new JPanel( new SoftBoxLayout( SoftBoxLayout.Y_AXIS ) );
			p.setPreferredWidth( 150 );
			p.setBorder( new TitledBorder( null, 'Output' ) );

			// output size ratio
			var sbox: JPanel = new JPanel( new SoftBoxLayout( SoftBoxLayout.X_AXIS ) );
			p.append( sbox );

			var l: JLabel = new JLabel( RATIO_STRING );
			sbox.append( l );
			ratioLabel = new JLabel( '1:' + outRatio.toFixed( 2 ) );
			ratioLabel.setHorizontalAlignment( AbstractButton.LEFT );
			var f: ASFont = new ASFont('Tahoma', 11, true );
			ratioLabel.setFont( f );
			sbox.append( ratioLabel );
			
			slider = new JSlider( 0, 1, 100, Configuration.OUTPUT_SCALE_RATIO * 100. );
			slider.setSnapToTicks( true );
			slider.setPaintTicks( true );
			slider.setShowValueTip( true );
			slider.addEventListener( MouseEvent.MOUSE_UP, onSliderMouseUp );
			p.append( slider );

			// full screen enabled only w/ the required player
			var b: JButton = new JButton( 'Full screen (hardware-assisted only)' );
			b.addEventListener( MouseEvent.MOUSE_UP, onFullScreen );
			b.setEnabled( Resources.isAug07U3Beta );
			p.append( b );

			if( !Resources.isAug07U3Beta )
			{
				l = new JLabel( '(no v9.0.60.120+ detected)' );
				p.append( l );
			}

			flash.system.Capabilities.version.split( ',' );
			pane.append( p );
		}

		private function onSliderMouseUp( evt: MouseEvent ): void
		{
			var value: Number = Number( slider.getValue() ) / 100.;
			create( value );
			ratioLabel.setText( '1:' + outRatio.toFixed( 2 ) );
		}

		private function onFullScreen( evt: MouseEvent ): void
		{
			Resources.theStage.fullScreenSourceRect = new Rectangle( 0, 0, Configuration.OUTPUT_WIDTH, Configuration.OUTPUT_HEIGHT );
			Resources.theStage.displayState = StageDisplayState.FULL_SCREEN;
		}
	}
}