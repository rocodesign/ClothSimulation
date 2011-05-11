package
{
	import org.cove.ape.*;
	
	public class Floor extends Group
	{
		public function Floor( xPos: Number, yPos: Number, width: Number, height: Number, mass: Number )
		{
			super( false );
			var p: RectangleParticle = new RectangleParticle( xPos, yPos, width, height, 0, true, mass, 0, 1 );
			addParticle( p );
		}
	}
}