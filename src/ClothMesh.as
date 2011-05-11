package
{
	import flash.events.*;
	import flash.geom.Point;

	import org.papervision3d.objects.Ase;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.cove.ape.Group;
	import org.papervision3d.core.geom.*;
//	import org.cove.ape.AbstractParticle;
	import org.papervision3d.events.FileLoadEvent;
	import org.cove.ape.*;
	import org.papervision3d.core.NumberUV;
	import flash.display.Sprite;
	import flash.display.SpreadMethod;
	import org.papervision3d.materials.WireframeMaterial;
	import org.aswing.Insets;

	public class ClothMesh extends Mesh3D
	{
		private var cloth: ClothGroup = null;
		private var isWireframe: Boolean = false;
		private var particlesVisible: Boolean = false;
		private var originalMaterial: MaterialObject3D = null;

		
		public function ClothMesh( material: MaterialObject3D,
								   position: Point,
								   particleTesselationX: int = Configuration.MESH_TESSELATION_X,
								   particleTesselationY: int = Configuration.MESH_TESSELATION_Y,
								   spacingX: int = Configuration.MESH_PARTICLE_SPACING_X,
								   spacingY: int = Configuration.MESH_PARTICLE_SPACING_Y  )
		{
			super( material, new Array(), new Array(), 'ClothMeshInstance' );
			originalMaterial = material;
		}

		public function get clothGroup(): ClothGroup
		{
			return cloth;
		}

		public function setToWireframe( value: Boolean ): void
		{
			isWireframe = value;
			if( isWireframe )
			{
				material = Resources.wireFrameMaterial;
			}
			else
			{
				material = originalMaterial;
			}
		}
		
		public function isWireFramed(): Boolean
		{
			return isWireframe;
		}
/*
		public function setParticlesVisible( value: Boolean ): void
		{
			particlesVisible = value;
			var s: Sprite = Resources.NullSprite;
			if( value )
			{
				// APE engine will revert to the default particle
				// representation
				s = null;
			}
			
			var i: int = 0;
			var l: int = clothGroup.particles.length;
			var p: Array = clothGroup.particles;
			for( ; i < l; i++ )
			{
				ClothParticle( p[ i ] ).setDisplay( null );
				ClothParticle( p[ i ] ).visible = value;
			}
		}
		
		public function areParticlesVisible(): Boolean
		{
			return particlesVisible;
		}
*/
		private function computeParticles( position: Point, particleTesselationX: int, particleTesselationY: int, spacingX: int, spacingY: int ): ClothGroup
		{
			this.geometry.ready = false;

			var g: ClothGroup = new ClothGroup();

			var cols:int = particleTesselationX;
			var rows:int = particleTesselationY;

			var startX:Number = position.x;
			var startY:Number = position.y;

			var currX:Number = startX;
			var currY:Number = startY;

			var idx: int = 0;
			for (var n:Number = 0; n < rows; n++)
			{
				for (var j:Number = 0; j < cols; j++)
				{
					//var fixed: Boolean = ( n == 0 && Math.random() > .5 );
					
					// setup vertex bindings later
					var ap: ClothParticle = new ClothParticle( null, currX, currY, 4, 4, 0, false, 9, 0, 0 );

					// add particle
					g.addParticle( ap );

					currX += spacingX;
					idx++;
				}

				currX = startX;
				currY += spacingY;
			}

			// v-constraints
			var p2:ClothParticle = null;
			for( n = 0; n < cols; n++ )
			{
				for( j = 0; j < rows; j++ )
				{
					var i: int = cols * j + n;
					var p1:ClothParticle = g.particles[ i ];
//					p1.setDisplay( Resources.NullSprite );

					if (p2 != null)
					{
						var cs: ClothSpring = new ClothSpring( p1, p2 );
						g.addConstraint( cs );
					}

					p2 = p1;
				}
				p2 = null;
			}

			// h-constraints
			p2 = null;
			for( i = 0; i < g.particles.length; i++ )
			{
				p1 = g.particles[i];
				if( ( p2 != null ) && ( i % cols != 0 ) )
				{
					cs = new ClothSpring( p1, p2 );
					g.addConstraint( cs );
				}
				p2 = p1;
			}

			// tl
//			ClothParticle( g.particles[ 0 ] ).fixed = true;

			// tr
//			ClothParticle( g.particles[ cols - 1 ] ).fixed = true;

			// construct 3d faces from particles
			constructFaces( g.particles, rows, cols );

			this.geometry.ready = true;

			return g;
		}

		private function constructFaces( pars: Array, rows: int, cols: int ): void
		{
			var xStep: Number = 1. / (cols-1);
			var yStep: Number = 1. / (rows-1);

			// local utility
			function getpar( x: int, y: int  ): ClothParticle
			{
				return pars[ x + y * cols ];
			}

			// minimum two rows for this algo to work
			if( rows < 2 ) return;

			// empty containers
			this.geometry.faces.length = 0;
			this.geometry.vertices.length = 0;
			
			var zv: Number = 0;
			for( var row: int = 1; row < rows; row++ )
			{
				for( var col: int = 1; col < cols; col++ )
				{
					// start at 1,1
					// so to start constructing from the
					// first call (not state-based)

					// Face3D origin is bottom left
					// array origin is top left
					// loop is array relative

					var p3: ClothParticle = getpar( col-1, row );	// Face3D is 0,0 but array is 0,1
					var p1: ClothParticle = getpar( col-1, row-1 );	//			 0,1			  0,0
					var p4: ClothParticle = getpar( col, row );		//			 1,0			  1,1
					var p2: ClothParticle = getpar( col, row-1 );	//			 1,1              1,0

					var v1: Vertex3D, v2: Vertex3D, v3: Vertex3D, v4: Vertex3D;
					var f1: Face3D, f2: Face3D;

					// vertex<->particle bindings
					this.geometry.vertices.push( v1 = new ParticleVertex( p1, p1.px, -p1.py, zv ) );
					this.geometry.vertices.push( v2 = new ParticleVertex( p2, p2.px, -p2.py, zv ) );
					this.geometry.vertices.push( v3 = new ParticleVertex( p3, p3.px, -p3.py, zv ) );
					this.geometry.vertices.push( v4 = new ParticleVertex( p4, p4.px, -p4.py, zv ) );


					// compute texture coords
					var origin: Point = new Point( xStep * ( col - 1 ), ( rows - 1 ) * yStep - yStep * ( row ) );

					f1 = new ClothFace3D( [v1, v4, v2], null, [ new NumberUV(origin.x, origin.y+yStep), new NumberUV(origin.x+xStep,origin.y), new NumberUV(origin.x+xStep,origin.y+yStep) ] );
					this.geometry.faces.push( f1 );
					f2 = new ClothFace3D( [v1, v3, v4], null, [ new NumberUV(origin.x, origin.y+yStep), new NumberUV(origin.x,origin.y), new NumberUV(origin.x+xStep,origin.y) ] );
					this.geometry.faces.push( f2 );
				}
			}

		}

		public function updateVertexBindings(): void
		{
			// copy cloth to vertices
			for( var c: int = 0; c < this.geometry.vertices.length; c++ )
			{
				var p: ClothParticle;
				var pv: ParticleVertex = ParticleVertex( this.geometry.vertices[ c ] );
				p = pv.getParticle();
				pv.x = p.px;
				pv.y = -p.py;
			}
		}
		
		public function build( position: Point, particleTesselationX: int, particleTesselationY: int, spacingX: int, spacingY: int ): void
		{
			this.geometry.ready = false;

/*
	// TODO			
			// save particles
			var p0: ClothParticle = ClothParticle( cloth.particles[ 0 ] );
			var p1: ClothParticle = ClothParticle( cloth.particles[ particleTesselationX - 1 ] );
			var parTopLeft: Point = p0.position.toPoint();
			var parTopRight: Point = p1.position.toPoint();
*/
			cloth = null;
			cloth = computeParticles( position, particleTesselationX, particleTesselationY, spacingX, spacingY );
			
/*
	// TODO			
			// restore particles
			ClothParticle( cloth.particles[ 0 ] ).position = Vector.fromPoint( parTopLeft );
			ClothParticle( cloth.particles[ particleTesselationX - 1 ] ).position.fromPoint( parTopRight );
*/
		}

		public function buildSized( position: Point, particleTesselationX: int, particleTesselationY: int, desiredWidth: int, desiredHeight: int ): void
		{
			cloth = null;
			
			var sX: int = 0,
				sY: int = 0;

			// compute tesselation from desired width
			sX = int( Number( desiredWidth ) / Number( particleTesselationX ) + .5 );
			sY = int( Number( desiredHeight ) / Number( particleTesselationY ) + .5 );
			
			//sX = sY = Configuration.PARTICLE_SPACING;
			build( position, particleTesselationX, particleTesselationY, sX, sY );
		}

	}
}


import org.papervision3d.core.geom.Vertex3D;
//import org.cove.ape.AbstractParticle;


class ParticleVertex extends Vertex3D
{
	private var particle: ClothParticle = null;
	
	public function getParticle(): ClothParticle
	{
		return particle;
	}
	
	public function ParticleVertex( aParticle: ClothParticle, x: Number = 0, y: Number = 0, z: Number = 0 )
	{
		super( x, y, z );
		particle = aParticle;
		particle.setVertex( this );
	}
}