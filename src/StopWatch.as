package
{
	import flash.utils.getTimer;
	
	public class StopWatch
	{
		private var _beginTick: int;
		private var _endTick: int;
		private var _elapsed: int;
		private var _started: Boolean;
		
		public function get isStarted(): Boolean
		{
			return _started;
		}

		public function StopWatch()
		{
			reset();
		}

		public function reset(): void
		{
			_beginTick = _endTick = 0;
			_started = false;
		}
		
		public function start(): void
		{
			_beginTick = getTimer();
			_started = true;
		}

		public function stop(): int
		{
			_endTick = getTimer();
			_elapsed = _endTick - _beginTick;
			_started = false;
			return _elapsed;
		}
		
		public function current(): int
		{
			return( getTimer() - _beginTick );
		}

		public function get elapsedMs(): int
		{
			return _elapsed;
		}
	}
}