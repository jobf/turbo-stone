package stone;

import lime.utils.Preloader;
import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.text.Text;

class LoadingScene extends Scene {
	var text:Text;
	var test:Word;
	var preloader:Preloader;

	public function new(preloader:Preloader, scene_constructor:Game->Scene, game:Game, bounds:RectangleGeometry, color:RGBA) {
		super(game, bounds, color);
		this.preloader = preloader;
		preloader.onProgress.add((loaded, total) -> trace('loaded $loaded, total $total'));
		preloader.onComplete.add(() -> game.scene_change(scene_constructor));
	}

	public function init() {
		text = new Text(font_load_embedded(), game.graphics_layer_init());
		test = text.word_make(Std.int(bounds.width * 0.5), 200, "LOADING . . .", Theme.drawing_lines, bounds.width);
	}

	public function update(elapsed_seconds:Float) {}

	public function draw() {
		text.draw();
	}

	public function close() {
		test.erase();
	}
}
