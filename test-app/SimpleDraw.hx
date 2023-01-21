import stone.core.Engine.Scene;

class SimpleDraw extends Scene {
	public function init() {
		var line = game.graphics.make_line(100, 100, 300, 300, 0xffffffFF);
	}

	public function update(elapsed_seconds:Float) {}

	public function draw() {}

	public function close() {}
}
