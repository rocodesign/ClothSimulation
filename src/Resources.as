package
{
	import flash.text.*;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import org.aswing.Insets;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.WireframeMaterial;
	import flash.display.Stage;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.system.Security;
	import flash.errors.IllegalOperationError;
	
	public class Resources
	{
		[ Embed( source = 'assets/carpet.jpg' ) ]
			public static const materialCloth: Class;

		[ Embed( source = 'c:\\windows\\fonts\\Arial.ttf', fontName = 'arialFont', mimeType = 'application/x-font-truetype' ) ]
			public static const fontArial: Class;

			public static const NullSprite: Sprite = new Sprite();
			
			public static var BlurPostProcessor: BlurFilter = new BlurFilter( 0, 0, Configuration.POSTPROCESS_BLUR_QUALITY );
			public static var BlurEffects: BlurFilter = new BlurFilter( 0, 0, Configuration.MOTION_BLUR_QUALITY );

			public static var marginLeft: Insets = new Insets( 0, 5, 0, 0 );

			public static var wireFrameMaterial: MaterialObject3D = new WireframeMaterial( 0xff0000 );
			
			public static var theStage: Stage = null;
			
			// AT LEAST
			public static var isAug07U3Beta: Boolean = false;

		public function Resources()
		{
		}

		public static function setup( aStage: Stage ): void
		{
			Resources.theStage = aStage;
			
			// detect august 2007 update 3 beta
			var t: Array = flash.system.Capabilities.version.split( ',' );
			var last: int = t.length - 1;
			try
			{
				isAug07U3Beta = ( int( t[ last - 1 ] ) >= 60 &&
								  int( t[ last     ] ) >= 120 );
			} catch( e: IllegalOperationError ) {}
		}


		/**
		 * Utilities
		 */

		public static function createTextField( aLabel: String, aTextColor: int, aTextSize: int = 10, boldText: Boolean = false ): TextField
		{
			var tf: TextField = new TextField();

			tf.visible = true;
			tf.alpha = 1;
			tf.background = false;
			tf.border = false;

			var eFont: Font = new Resources.fontArial();
			var textFormat: TextFormat = new TextFormat();

			textFormat.font = eFont.fontName;
			textFormat.color = aTextColor;
			textFormat.size = aTextSize;
			textFormat.bold = boldText;

			tf.defaultTextFormat = textFormat;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.type = TextFieldType.DYNAMIC;
			tf.gridFitType = GridFitType.SUBPIXEL;
			tf.embedFonts = true;
			tf.selectable = false;

			tf.text = aLabel;
			tf.autoSize = TextFieldAutoSize.LEFT;

			return tf;
		}

	}
		
}