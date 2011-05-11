package
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	public class ClothShadow extends Sprite
	{
		private var clothGroup: ClothGroup = null;
		private var groupBounds: Rectangle = new Rectangle();
		private var lineOfSight: Number = 0;
		private var blur: BlurFilter = new BlurFilter();
		private var invVisibleWidth: Number = 0;
		private var clothBaricenter: Point = new Point();
		
		public function ClothShadow( aLineOfSight: Number, aVisibleWidth: Number )
		{
			lineOfSight = aLineOfSight;
			invVisibleWidth = 1. / aVisibleWidth;

			this.graphics.clear();
			blur.blurY = 3;
			blur.quality = 4;
		}
		
		// returns the x-axis position computed for positioning
		// this object's center in the specified rectangle's center
		private function centerAtCenter( aRectangle: Rectangle ): int
		{
			return 0;
		}
		
		// update position and size according to the
		// cloth particles group
		public function tick( particleGroup: ClothGroup, expectedBaricenter: Point = null ): void
		{
			// TODO
			// opt here
			clothGroup = particleGroup;
			clothGroup.computeBoundingBox( groupBounds );
			clothGroup.computeBaricenter( clothBaricenter );

			var bc: Point = clothBaricenter;
			if( expectedBaricenter )
			{
				bc = expectedBaricenter;
			}

			var w2: int = ( int( groupBounds.width ) >> 1 );
			w2 -= ( w2 >> 1 );


			var c: Number =  ( ( lineOfSight - bc.y ) / ( ( lineOfSight - groupBounds.top ) ) );
			
			// up/down clamp
			if( c < 0 ) c = 0;	if( c > 1 ) c = 1;
			
			var color: int = ( 0x00010101 * int( c * 0x80 ) );

			graphics.clear();
			graphics.lineStyle( 1, color );
			graphics.moveTo( -w2, 0 );
			graphics.lineTo( w2, 0 );

			x = groupBounds.left + ( w2 << 1 );
			y = lineOfSight + Configuration.SHADOW_OFFSET;

			scaleX = (groupBounds.top+10) / lineOfSight + .3;

			blur.blurX = width;
			filters = [ blur ];
			alpha = .8 - ( width * invVisibleWidth );	// .5 alpha due to w2 being halved
		}
	}
}