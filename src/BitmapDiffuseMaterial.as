package
{
	import flash.display.*;
	import flash.geom.Matrix;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.core.geom.*;
	import org.cove.ape.Vector;
	import org.papervision3d.core.Number3D;
	import flash.filters.BlurFilter;
	
	public class BitmapDiffuseMaterial extends BitmapMaterial
	{
		private var lightDir: Number3D = new Number3D( 0, -.5, -1 );
		
		public function BitmapDiffuseMaterial( asset: *, initObject: Object = null )
		{
			super( asset );
		}
		
		public override function drawFace3D(instance:DisplayObject3D, face3D:Face3D, graphics:Graphics, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D):int
		{
			if(bitmap){
				var map:Matrix = (uvMatrices[face3D] || transformUV(face3D, instance));
				
				var x0:Number = v0.x;
				var y0:Number = v0.y;
				var x1:Number = v1.x;
				var y1:Number = v1.y;
				var x2:Number = v2.x;
				var y2:Number = v2.y;
				
				_triMatrix.a = x1 - x0;
				_triMatrix.b = y1 - y0;
				_triMatrix.c = x2 - x0;
				_triMatrix.d = y2 - y0;
				_triMatrix.tx = x0;
				_triMatrix.ty = y0;
					
				_localMatrix.a = map.a;
				_localMatrix.b = map.b;
				_localMatrix.c = map.c;
				_localMatrix.d = map.d;
				_localMatrix.tx = map.tx;
				_localMatrix.ty = map.ty;
				_localMatrix.concat(_triMatrix);
				
				graphics.beginBitmapFill( bitmap, _localMatrix, true, smooth);
				graphics.moveTo( x0, y0 );
				graphics.lineTo( x1, y1 );
				graphics.lineTo( x2, y2 );
				graphics.lineTo( x0, y0 );
				graphics.endFill();


				//
				// fake shadowing
				//
				//trace( face3D.faceNormal );
				//trace( Number3D.dot( face3D.faceNormal, lightDir ) );

/*
				graphics.beginFill( 0, l );
				graphics.moveTo( x0, y0 );
				graphics.lineTo( x1, y1 );
				graphics.lineTo( x2, y2 );
				graphics.lineTo( x0, y0 );
				graphics.endFill();
*/
			}
			return 1;
		}

	}
}