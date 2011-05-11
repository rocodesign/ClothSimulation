package
{
	import flash.geom.Matrix;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import org.papervision3d.core.geom.Vertex3D;
	
	public class Background extends Sprite
	{
		public const fillColor: int = Configuration.BACKGROUND_COLOR;
		private var theSun: Sprite;
		
		public function get sun(): Sprite
		{
			return theSun;
		}
		
		public function Background( aWidth: Number, anHeight: Number, aLineOfSight: Number )
		{
			createBackground( aWidth, anHeight, aLineOfSight );
		}

		private function createBackground( aWidth: Number, anHeight: Number, aLineOfSight: Number ): void
		{
			var offsetY: Number = Configuration.BACKGROUND_OFFSET;
			var gradientAlpha: Number = 1;

			graphics.clear();

			// top-to-mid
			var w: Number = aWidth;
			var h: Number = aLineOfSight + offsetY;
			var ty: Number = 0;

			var m: Matrix = new Matrix();
			m.createGradientBox( w, h, -Math.PI/2., 0, ty );

			graphics.beginGradientFill( GradientType.LINEAR,
										[ 0xc5c5c5, 0xf3f3f3, 0xf5f5f5, 0xf8f8f8, 0xffffff, 0xefefef ],
										[ gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha ],
										[ 0, 15, 20, 120, 240, 255 ],
										m
									  );

			graphics.drawRect( 0, ty, w, h );
			graphics.endFill();

			graphics.beginFill( fillColor, .12 );
			graphics.drawRect( 0, ty, w, h );
			graphics.endFill();

			// mid-to-bottom
			w = aWidth;
			ty = aLineOfSight + offsetY;
			h = anHeight - ty;

			m.identity();
			m.createGradientBox( w, h, Math.PI/2., 0, ty );
			graphics.beginGradientFill( GradientType.LINEAR,
										[ 0xf2f2f2, 0xe1e1e1, 0xd0d0d0, 0xc5c5c5 ],
										[ gradientAlpha, gradientAlpha, gradientAlpha, gradientAlpha ],
										[ 0, 150, 200, 255 ],
										m
									  );

			graphics.drawRect( 0, ty, w, h );
			graphics.endFill();

			graphics.beginFill( fillColor, .15 );
			graphics.drawRect( 0, ty, w, h );
			graphics.endFill();

/*
			// create sun's mask
			var _mask: Sprite = new Sprite();
			_mask.graphics.clear();
			_mask.graphics.beginFill( 0 );
			_mask.graphics.drawRect( 0, 0, Configuration.WIDTH, Configuration.LINE_OF_SIGHT + offsetY );
			_mask.graphics.endFill();
			
			theSun = new Sun( new Vertex3D( 50, 250, 200 ), _mask );
			addChild( theSun );
*/
		}

	}
}

/*
	import flash.geom.Matrix;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import org.papervision3d.core.geom.Vertex3D;
	import org.cove.ape.Vector;
	import flash.filters.ConvolutionFilter;
	

class Sun extends Sprite
{
	public function Sun( circle: Vertex3D, aMask: Sprite = null )
	{
		super();
		
		mask = aMask;
		addChild( mask );

		// draw sun
		graphics.beginFill( 0xffff60 );
		graphics.drawCircle( circle.x, circle.y, circle.z + 2 );
		graphics.endFill();

		graphics.beginFill( 0xffff80 );
		graphics.drawCircle( circle.x, circle.y, circle.z + 1 );
		graphics.endFill();

		graphics.beginFill( 0xffffff );
		graphics.drawCircle( circle.x, circle.y, circle.z );
		graphics.endFill();
	}
}
*/