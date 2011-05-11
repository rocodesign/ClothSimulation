package
{
	import flash.display.Sprite;
	import org.cove.ape.RectangleParticle;
	import org.papervision3d.core.geom.*;
	
	public class ClothParticle extends RectangleParticle
	{
		private var _boundTo: Vertex3D = null;
		
		public function get Vertex(): Vertex3D
		{
			return _boundTo;
		}

		public function setVertex( aVertex: Vertex3D ): void
		{
			_boundTo = aVertex;
		}
		
		public function ClothParticle(  aVertex: Vertex3D,
										x:Number, 
										y:Number, 
										width:Number, 
										height:Number, 
										rotation:Number = 0, 
										fixed:Boolean = false,
										mass:Number = 1, 
										elasticity:Number = 0.2,
										friction:Number = 0 )
		{
			super( x, y, width, height, rotation, fixed, mass, elasticity, friction );
			_boundTo = aVertex;
		}
	
	}
}

