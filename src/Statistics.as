package
{
	import flash.utils.getTimer;
	import flash.display.Sprite;
	import flash.text.*;
	import flash.system.Capabilities;
	
	public class Statistics extends Sprite
	{
		// general info
		private var textVer: String = 'Magic Carpet ' + VersionInfo.Version;
		private var textFps: String = 'Fps (avg): ';
		private var flashPlayer: String = 'Player version: ' + flash.system.Capabilities.version;

		// vis
		private var textField: TextField;
		private var textFormat: TextFormat;

		// fps
		private var secondsPerFrame: Number = 0;
		private var framesPerSecond: Number = 0;
		private const MAX_SAMPLED_ITEMS: int = 32;
		private var beginTickMs: int = 0;
		private var endTickMs: int = 0;
		private var elapsedMs: int = 0;
		private var totalMs: int = 0;
		private const ONE_ON_THOUSAND: Number = 1. / 1000.;

		private var avsample: AveragedSampleInt = new AveragedSampleInt( MAX_SAMPLED_ITEMS );

		public function Statistics()
		{
			totalMs = getTimer();
			textField = Resources.createTextField( textVer + '\n' + textFps + 'awaiting data...\n' + flashPlayer, 0 );
			textFormat = textField.defaultTextFormat;
			textField.x = textField.y = 0;
			addChild( textField );
		}
		
		public function beginTick(): void
		{
			beginTickMs = getTimer();
		}
		
		public function endTick(): void
		{
			endTickMs = getTimer();
			elapsedMs = endTickMs - beginTickMs;

			avsample.addSlice( elapsedMs );
			
			if( avsample.ready )
			{
				secondsPerFrame = avsample.computeAverage() * ONE_ON_THOUSAND;
				if( secondsPerFrame > 0 )
				{
					framesPerSecond = 1. / secondsPerFrame;
					textField.text = textVer + '\n' + textFps + framesPerSecond.toFixed( 2 ) + ' (' + secondsPerFrame.toFixed( 5 ) + ' secs/frame)\n' + flashPlayer;
				}
				else
				{
					framesPerSecond = 0;
				}
			}
			
			textField.defaultTextFormat = textFormat;
		}

		public function ready(): Boolean
		{
			return avsample.ready;
		}
		
		public function get FramesPerSecond(): Number
		{
			return framesPerSecond;
		}
		
		public function get SecondsPerFrame(): Number
		{
			return secondsPerFrame;
		}
	}
}

class AveragedSampleInt
{
	private var averageOn: Number = 0;
	private var dataBuckets: Array = new Array();
	private var dataReady: Boolean = false;

	public function AveragedSampleInt( itemsToAverage: Number = 16 )
	{
		averageOn = itemsToAverage;
	}
	
	public function addSlice( slice: int ): void
	{
		dataBuckets.push( slice );
		dataReady = ( dataBuckets.length >= averageOn );
		if( dataReady )
		{
			// discard first
			dataBuckets.shift();
		}
	}
	
	public function get ready(): Boolean
	{
		return dataReady;
	}

	public function computeAverage(): Number
	{
		var c: int = 0;
		var l: int = dataBuckets.length;
		var nl: Number = Number( l );
		var result: Number = 0;
		
		for( ; c < l; c++ )
		{
			result += Number( dataBuckets[ c ] );
		}
		
		result /= nl;
		
		return result;
	}

	public function reset(): void
	{
		dataBuckets.length = 0;
	}
}

