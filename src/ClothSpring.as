package
{
	import org.cove.ape.AbstractParticle;
	import org.cove.ape.SpringConstraint;
	
	public class ClothSpring extends SpringConstraint
	{
		public function ClothSpring(
				p1:ClothParticle, 
				p2:ClothParticle, 
				stiffness:Number = 1,
				collidable:Boolean = false,
				rectHeight:Number = 1,
				rectScale:Number = 1,
				scaleToLength:Boolean = false)
		{
			super( p1, p2, stiffness, collidable, rectHeight, rectScale, scaleToLength );
		}
		
		// do nothing
		public override function paint(): void {}

	}
}