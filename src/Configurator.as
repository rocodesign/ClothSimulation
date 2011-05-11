package
{
	import org.aswing.*;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import org.cove.ape.Group;
	
	public class Configurator extends Sprite
	{
		private var configurables: Array = new Array();
		private var window: JWindow = null;
		private var pane: JPanel = null;
		private var paneCounters: int = 0;

		public function Configurator( aRoot: DisplayObjectContainer )
		{
			super();
			setupUIManager( aRoot );
		}
		
		private function setupUIManager( aRoot: DisplayObjectContainer ): void
		{
			// setup ui manager
			AsWingManager.initAsStandard( aRoot );

			// setup size and position
			this.graphics.clear();
			this.graphics.lineStyle( 0, 0, 0 );
			this.graphics.drawRect( 0,
									0,
									Configuration.STAGE_WIDTH,
									Configuration.STAGE_HEIGHT - Configuration.OUTPUT_HEIGHT );
			this.graphics.endFill();

			x = 0;
			y = Configuration.STAGE_HEIGHT - height;

			// create window and pane
			window = new JWindow();
			//pane = new JPanel( new SoftBoxLayout( SoftBoxLayout.X_AXIS ) /*new BorderLayout(0, 0)*/ );
			pane = new JPanel( new GridLayout( 2, 2 ) );

			window.setContentPane( pane );
			window.setSizeWH( width, height );
			window.setLocationXY( x, y );
			window.show();
		}

		public function addConfigurable( configurable: IConfigurable ): uint
		{
			configurable.createUI( pane );
			return configurables.push( configurable );
		}
	}
}