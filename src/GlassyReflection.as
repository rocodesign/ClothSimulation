package
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.IBitmapDrawable;
	
	public class GlassyReflection extends Sprite
	{
		private var output: Output;
		private var reflection: Bitmap;
		private var reflectionData: BitmapData;
		private var reflectionMask: Sprite;

		public function GlassyReflection( anOutput: Output )
		{
			output = anOutput;
			createReflection();
		}
		
		public function clear(): void
		{
			reflectionData.fillRect( reflectionData.rect, 0 );
		}

		private function createReflection(): void
		{
			// setup reflection
			reflectionData = new BitmapData( Configuration.OUTPUT_WIDTH * output.ratio,
											 Configuration.OUTPUT_HEIGHT * output.ratio,
											 true, 0 );

			reflection = new Bitmap( reflectionData, PixelSnapping.AUTO, false );
			reflection.cacheAsBitmap = true;
			reflection.x = 0;
			reflection.width = Configuration.OUTPUT_WIDTH;
			reflection.height = Configuration.OUTPUT_HEIGHT;
			reflection.scaleY = -1 * output.invRatio;
			reflection.y = ( Configuration.OUTPUT_HEIGHT + Configuration.OUTPUT_HEIGHT / 2 );
			reflection.alpha = .25;
			addChild( reflection );

			// setup reflection's mask
			var m: Matrix = new Matrix();
			var w: Number = Configuration.FLOOR_W;
			var h: Number = Configuration.FLOOR_H;
			m.createGradientBox( w, h, Math.PI / 2., 0, 0 );

			reflectionMask = new Sprite();
			reflectionMask.graphics.clear();
			reflectionMask.graphics.beginGradientFill( GradientType.LINEAR,
														[ 0, 0 ],
														[ 1, 0 ],
														[ 0, 255 ],
														m );

			reflectionMask.graphics.drawRect( 0, 0, w, h );
			reflectionMask.graphics.endFill();
			reflectionMask.y = Configuration.LINE_OF_SIGHT + Configuration.SHADOW_OFFSET;
			reflectionMask.cacheAsBitmap = true;
			addChild( reflectionMask );

			reflection.mask = reflectionMask;
		}

		public function tick( source: IBitmapDrawable, transformMatrix: Matrix ): void
		{
			reflectionData.draw( source, transformMatrix, null );
		}
	}
}