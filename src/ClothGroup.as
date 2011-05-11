package
{
	import org.cove.ape.Group;
	import org.cove.ape.AbstractConstraint;
	import flash.geom.Point;
//	import org.cove.ape.AbstractParticle;
	import flash.geom.Rectangle;
	import org.cove.ape.Vector;

	public class ClothGroup extends Group
	{
		function ClothGroup( collideInternal: Boolean = false )
		{
			super( collideInternal );
		}

		public function getAverageMotion( absoluteValues: Boolean = false): Point
		{
			var idx: int = 0;
			var len: int = particles.length;
			var invLen: Number = 1. / Number( len );
			var pt: Point = new Point( 0, 0 );
			for( ; idx < len; idx++ )
			{
				pt.x += ClothParticle( particles[ idx ] ).velocity.x;
				pt.y += ClothParticle( particles[ idx ] ).velocity.y;
			}
			
			pt.x *= invLen;
			pt.y *= invLen;
			
			if( absoluteValues )
			{
				pt.x = Math.abs( pt.x );
				pt.y = Math.abs( pt.y );
			}
			
			return pt;
		}
		
		public function computeBoundingBox( rect: Rectangle ): void
		{
			var idx: int = 0;
			var len: int = particles.length;
			rect.left = rect.right  = ClothParticle( particles[ idx ] ).px;
			rect.top  = rect.bottom = ClothParticle( particles[ idx ] ).py;

			for( ; idx < len; idx++ )
			{
				rect.left   = Math.min( rect.left,   ClothParticle( particles[ idx ] ).px );
				rect.right  = Math.max( rect.right,  ClothParticle( particles[ idx ] ).px );
				rect.bottom = Math.max( rect.bottom, ClothParticle( particles[ idx ] ).py );
				rect.top    = Math.min( rect.top,    ClothParticle( particles[ idx ] ).py );
			}
		}
		
		public function computeBaricenter( aPoint: Point ): void
		{
			var idx: int = particles.length-1;// >> 1;
			var p: ClothParticle = particles[ idx ]
			aPoint.x = p.px;
			aPoint.y = p.py;
			return;
/*
			var p1: ClothParticle = particles[ idx - 2 ],	// assumes the length is big enough
			    p2: ClothParticle = particles[ idx - 1 ],
			    p3: ClothParticle = particles[ idx     ],
			    p4: ClothParticle = particles[ idx + 1 ];
			    
			aPoint.x = ( int( p1.px + p2.px + p3.px + p4.px ) ) >> 2;
			aPoint.y = ( int( p1.py + p2.py + p3.py + p4.py ) ) >> 2;
*/
		}
	}
}