import stone.FileStorageScene;
import stone.core.Models.Serialize;
import stone.Theme;
import stone.core.Models.Deserialize;
import stone.DesignerScene;
import stone.core.Storage;
import peote.view.Display;
import peote.view.PeoteView;
import stone.core.Engine;
import stone.input.Input;
import stone.LoadingScene;
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

	// var implementation_graphics:Graphics;
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

	var init_layer:GraphicsConstructor;

	public function init(window:Window) {
		var viewport_window:RectangleGeometry = {
			y: 0,
			x: 0,
			width: window.width,
			height: window.height
		}

		peoteview = new PeoteView(window);
		implementation_input = new Input(window);

		init_layer = () -> {
			var display = new Display(0, 0, 800, 640);
			peoteview.addDisplay(display);
			return new Graphics(display, viewport_window, init_layer);
		}

		var storage = new Storage(window);
		var file_list = storage.file_paths();

		if (file_list.length <= 0) {
			var file_name = '${Date.now().to_time_stamp()}.json';

			storage.file_save({
				name: file_name,
				content: Serialize.to_string({
					models: []
				})
			});

			file_list = storage.file_paths();
		} else {
			trace(file_list[0]);
		}

		var start:SceneStart = DESIGN;

		#if testoverview
		start = OVERVIEW;
		#end

		#if testui
		start = TESTUI;
		#end

		#if testfiles
		start = STORAGE;
		#end

		if (file_list.length > 0) {
			var index_end_of_list = file_list.length - 1;
			var file_name = file_list[index_end_of_list];
			var file_latest = storage.file_load(file_name);
			// trace(file_latest.content);
			var has_valid_file = file_latest != null && file_latest.content.length > 0;
			if (has_valid_file) {
				var file = Deserialize.parse_file_contents(file_latest.content);

				var init_scene:Game->Scene = switch start {
					case DESIGN: game -> new DesignerScene(game, viewport_window, Theme.bg_scene, file, file_name);
					case STORAGE: game -> new FileStorageScene(game, viewport_window, Theme.bg_scene);
					case OVERVIEW: game -> new Overview(game, viewport_window, Theme.bg_scene, file);
					case TESTUI: game -> new TestUi(game, viewport_window, Theme.bg_scene);
				};

				var init_scene_loader:Game->Scene = game -> new LoadingScene(preloader, init_scene, game, viewport_window, Theme.bg_scene);

				game = new Game(init_scene_loader, init_layer, implementation_input, storage);
				isReady = true;
			}
			else{
				trace('no valid file to load ');
			}
		}
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

enum SceneStart {
	DESIGN;
	STORAGE;
	OVERVIEW;
	TESTUI;
}
