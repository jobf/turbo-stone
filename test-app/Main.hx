import stone.Theme;
import stone.core.Models.Deserialize;
import stone.core.Models.FileModel;
import stone.DesignerScene;
import stone.core.Storage;
import peote.view.Display;
import peote.view.PeoteView;
import stone.core.Engine;
import stone.input.Input;
import stone.LoadingScene;
import stone.FileStorageScene;
import stone.graphics.implementation.Graphics;
import lime.graphics.RenderContext;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

using stone.util.DateExtensions;

class Main extends Application {
	var peoteview:PeoteView;
	var display_main:Display;
	var display_hud:Display;

	var isReady:Bool;
	var time:Float = 0;
	var elapsed_seconds:Float = 0;
	var game:Game;

	var implementation_graphics:Graphics;
	var implementation_input:Input;

	override function onWindowCreate() {
		super.onWindowCreate();

		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					init(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public function init(window:Window) {
		var viewport_window:RectangleGeometry = {
			y: 0,
			x: 0,
			width: window.width,
			height: window.height
		}

		peoteview = new PeoteView(window);
		display_main = new Display(0, 0, 800, 640);
		peoteview.addDisplay(display_main);

		display_hud = new Display(0, 0, window.width, window.height);
		peoteview.addDisplay(display_hud);

		implementation_graphics = new Graphics(display_main, viewport_window);
		implementation_input = new Input(window);
		implementation_graphics.set_color(Theme.bg_scene);
		
		
		var storage = new Storage(window);
		var file_name = 'start.json';
		var file_list = storage.file_paths();
		
		var file:FileModel = {
			models: []
		}
		
		if(file_list.length > 0){
			var index_end_of_list = file_list.length - 1;
			var file_latest = storage.file_load(file_list[index_end_of_list]);
			if(file_latest.content.length > 0){
				file = Deserialize.parse_file_contents(file_latest.content);
			}
		}
		
		var hud_graphics = new Graphics(display_hud, viewport_window);
		var init_scene:Game->Scene = game -> new DesignerScene(hud_graphics, game, viewport_window, Theme.bg_scene, file, file_name);

		#if simple
		init_scene = game -> new SimpleDraw(game, viewport_window, Theme.bg_scene);
		#end
		
		#if testui
		init_scene = game -> new TestUi(game, viewport_window, Theme.bg_scene);
		#end
		#if testfiles
		init_scene = game -> new FileStorageScene(game, viewport_window, Theme.bg_scene);
		#end
		var init_scene_loader:Game->Scene = game -> new LoadingScene(preloader, init_scene, game, viewport_window, Theme.bg_scene);



		game = new Game(init_scene_loader, implementation_graphics, implementation_input, storage);

		isReady = true;
	}

	override function update(deltaTime:Int):Void {
		super.update(deltaTime);

		if (!isReady) {
			return;
		}

		elapsed_seconds = deltaTime / 1000;
		time += elapsed_seconds;
		game.update(elapsed_seconds);
	}

	override function render(context:RenderContext) {
		super.render(context);

		if (!isReady) {
			return;
		}

		game.draw();
	}
}



