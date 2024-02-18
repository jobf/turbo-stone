package stone.time;

@:publicFields
class CountDown {
	var duration:Float;
	var countDown:Float;
	var enabled:Bool = true;
	private var onComplete:() -> Void;
	private var restartWhenComplete:Bool;
	private var isReady:Bool = true;


	function new(durationSeconds:Float, onComplete:Void->Void, restartWhenComplete:Bool = false) {
		this.duration = durationSeconds;
		this.onComplete = onComplete;
		this.restartWhenComplete = restartWhenComplete;
		this.countDown = durationSeconds;
	}

	function update(elapsedSeconds:Float) {
		if(!enabled){
			return;
		}
		countDown -= elapsedSeconds;
		if (isReady && countDown <= 0) {
			isReady = false;
			onComplete();
			if (restartWhenComplete) {
				reset();
			}
		}
	}

	inline function reset(nextDurationSeconds:Float=0) {
		if(nextDurationSeconds > 0){
			duration = nextDurationSeconds;
		}
		countDown = duration;
		isReady = true;
	}

	function stop() {
		// countDown = 0;
		isReady = false;
	}
}