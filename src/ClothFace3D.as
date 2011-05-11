package
{
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.geom.Face3D;
	import org.papervision3d.core.proto.MaterialObject3D;

	public class ClothFace3D extends Face3D
	{
		public function ClothFace3D( vertices:Array, material:MaterialObject3D=null, uv:Array=null )
		{
			super( vertices, material, uv );
			createNormal();
		}
	}
}