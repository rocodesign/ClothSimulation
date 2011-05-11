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

	public class PostProcessor implements IConfigurable
	{
		private var ppbmp: Bitmap;
		private var ppbmpData: BitmapData;
		private var ppEnabled: Boolean;
		private var ppInvRatio: Number;
		private var ppRatio: Number;
		private var ppMatrix: Matrix = null;
		private var ppInvMatrix: Matrix = null;
		
		// gui
		private const RATIO_STRING: String = 'Postprocess size ratio: ';
		private var ratioLabel: JLabel;
		private var slider: JSlider;

		public function PostProcessor()
		{
			create();
		}
		
		private function create( aRatio: Number = Configuration.POSTPROCESS_RATIO,
								 enabled: Boolean = Configuration.POSTPROCESS_ENABLED ): void
		{
			ppbmpData = new BitmapData( Configuration.OUTPUT_WIDTH * aRatio,
										Configuration.OUTPUT_HEIGHT * aRatio,
										true, 0 );

			ppbmp = new Bitmap( ppbmpData, PixelSnapping.AUTO, false );
			ppbmp.filters = [];
			
			ppEnabled = enabled;
			ppRatio = aRatio;
			ppInvRatio = 1. / ppRatio;
			
			// rebuild matrixes
			ppMatrix = new Matrix( ppRatio, 0, 0, ppRatio );
			ppInvMatrix = new Matrix( ppInvRatio, 0, 0, ppInvRatio );
		}

		public function draw( source: Bitmap, dest: Bitmap ): void
		{
			if( ppEnabled )
			{
				// blurred output to pp bmp
				Resources.BlurPostProcessor.blurX = Resources.BlurPostProcessor.blurY = Configuration.POSTPROCESS_BLUR_AMOUNT;
				
				ppbmpData.fillRect( ppbmpData.rect, 0 );

				source.filters = [ Resources.BlurPostProcessor ];
					ppbmpData.draw( source, ppMatrix, null, BlendMode.NORMAL );
				source.filters = [];
		
				// blend pp and output bitmaps
				dest.bitmapData.draw( ppbmp, ppInvMatrix, null, BlendMode.HARDLIGHT );
			}
		}

		//
		// accessors
		//
		public function get outputBitmap(): Bitmap
		{
			return ppbmp;
		}
		
		public function get outputBitmapData(): BitmapData
		{
			return ppbmpData;
		}


		//
		// GUI
		//
		
		public function createUI( pane: JPanel ): void
		{
			// this configurable's box
			var p: JPanel = new JPanel( new SoftBoxLayout( SoftBoxLayout.Y_AXIS ) );
			p.setBorder( new TitledBorder( null, 'Post-processing' ) );

			// enable yes/no
			var cb: JCheckBox = new JCheckBox( 'Enabled' );
			cb.setSelected( ppEnabled );
			cb.setHorizontalAlignment( AbstractButton.LEFT );
			cb.setMargin( Resources.marginLeft );
			cb.addEventListener( MouseEvent.MOUSE_UP, onPostProcessEnabled );
			p.append( cb );

			// postprocessing size ratio
			var sbox: JPanel = new JPanel( new SoftBoxLayout( SoftBoxLayout.X_AXIS ) );
			p.append( sbox );
			
			var l: JLabel = new JLabel( RATIO_STRING );
			sbox.append( l );
			ratioLabel = new JLabel( '1:' + ppRatio.toFixed( 2 ) );
			ratioLabel.setHorizontalAlignment( AbstractButton.LEFT );
			var f: ASFont = new ASFont('Tahoma', 11, true );
			ratioLabel.setFont( f );
			sbox.append( ratioLabel );
			
			slider = new JSlider( 0, 1, 100, Configuration.POSTPROCESS_RATIO * 100 );
			slider.setSnapToTicks( true );
			slider.setPaintTicks( true );
			slider.setShowValueTip( true );
			slider.setPreferredWidth( 150 );
			p.append( slider );
			slider.addEventListener( MouseEvent.MOUSE_UP, onSliderChanged );
			slider.setEnabled( ppEnabled );

			pane.append( p  );
		}

		private function onPostProcessEnabled( evt: MouseEvent ): void
		{
			ppEnabled = !ppEnabled;
			slider.setEnabled( ppEnabled );
		}

		private function onSliderChanged( evt: MouseEvent ): void
		{
			var value: Number = Number( slider.getValue() ) / 100.;
			create( value, ppEnabled );
			ratioLabel.setText( '1:' + ppRatio.toFixed( 2 ) );
		}
		
	}
}