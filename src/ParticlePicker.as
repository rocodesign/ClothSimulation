package
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import org.cove.ape.Group;
	import org.cove.ape.AbstractParticle;
	import org.cove.ape.APEngine;
	import flash.geom.Rectangle;
	
	public class ParticlePicker
	{
		private var lastPt: Point;
		private var isDown: Boolean = false;
		private var pGroup: Group;
		
		private var pickedParticle: ClothParticle = null;
		private var lastDistance: Number;
		private var particleWasFixed: Boolean = false;
		private var boundRect: Rectangle = new Rectangle();
		
		public function get currentParticle(): ClothParticle
		{
			return pickedParticle;
		}
		
		public function set boundaries( value: Rectangle ): void
		{
			boundRect = value;
		}
		
		public function get boundaries(): Rectangle
		{
			return boundRect;
		}
		
		/**
		 * Construction
		 */
		public function ParticlePicker( particleGroup: Group )
		{
			pGroup = particleGroup;
		}

		// simple (squared) distance-based particle selection model
		private function selectParticle( evt: MouseEvent ): ClothParticle
		{
			var firstEnter: Boolean = true;
			var minDistance: Number = 0;

			// search particle
			var p: ClothParticle = pGroup.particles[ 0 ];
			var theParticle: ClothParticle = null;
			for( var i: int = 0; i < pGroup.particles.length; i++ )
			{
				p = pGroup.particles[ i ];
				
				// compute distance
				var dx: int = evt.stageX - p.px;
				var dy: int = evt.stageY - p.py;
				var distance: Number = /* Math.sqrt */( dx * dx + dy * dy );
				if( minDistance > distance || firstEnter )
				{
					firstEnter = false;
					minDistance = distance;
					theParticle = p;
				}
			}
			
			lastDistance = minDistance;

			return theParticle;
		}

		public function tick( particleGroup: ClothGroup ): void
		{
			// update particle group
			pGroup = particleGroup;
			
			if( isDown )
			{
				pickedParticle.px = Resources.theStage.mouseX;
				pickedParticle.py = Resources.theStage.mouseY;

				if( pickedParticle.px < boundRect.left ) pickedParticle.px = boundRect.left;
				if( pickedParticle.px > boundRect.right ) pickedParticle.px = boundRect.right;
				if( pickedParticle.py < boundRect.top ) pickedParticle.py = boundRect.top;
				if( pickedParticle.py > boundRect.bottom ) pickedParticle.py = boundRect.bottom;
			}
		}
				
		/**
		 * Mouse events
		 */
		public function onMouseDown( evt: MouseEvent ): void
		{
			if( !isDown && boundRect.containsPoint( new Point( Resources.theStage.mouseX, Resources.theStage.mouseY ) ) )
			{
				// find particle
				pickedParticle = selectParticle( evt );
				particleWasFixed = pickedParticle.fixed;

				pickedParticle.fixed = true;
				
				isDown = true;
			}
		}

		public function onMouseUp( evt: MouseEvent ): void
		{
			if( isDown )
			{
				isDown = false;
				pickedParticle.fixed = particleWasFixed;
				
				// invalidate picked particle
				pickedParticle = null;
			}
		}

	}
}